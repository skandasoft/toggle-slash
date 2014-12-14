{Point, Range}= require "atom"
module.exports =
  replace: (slash)->
    @editor = atom.workspaceView.getActivePaneItem()
    cursor = @editor.cursors[0].getBufferPosition()
    startRange = new Range new Point(cursor.row,0), cursor
    @editor.buffer.backwardsScanInRange /['|"]/g, startRange, (obj)=>
      @p1 = obj.range.start
      obj.stop()
    endRange = new Range cursor, new Point(cursor.row,Infinity)
    @editor.scanInBufferRange /['|"]/g, endRange, (obj)=>
      @p2 = obj.range.end
      r1 = new Range(@p1,@p2)
      text = @editor.getTextInBufferRange(r1)
      if slash is '\\'
        if text.indexOf('\\\\') isnt -1
          text = text.replace(/\\\\/g,'\\')
        else if text.indexOf('\\') isnt -1
          text = text.replace(/\\/g,'\\\\')
        else
          text = text.replace(/\//g,'\\')

      else if slash is '/'
        if text.indexOf('//') isnt -1
          text = text.replace(/\/\//g,'/')
        else if text.indexOf('/') isnt -1
          text = text.replace(/\//g,'//')
        else
          text = text.replace(/\\/g,'/')
      @editor.setTextInBufferRange r1,text
      @editor.cursors[0].setBufferPosition(cursor)
      obj.stop()

  activate: (state) ->
    atom.workspaceView.command 'toggle-slash:back', '.editor', =>
      @replace('\\')
    atom.workspaceView.command 'toggle-slash:forward', '.editor', =>
      @replace('/')
