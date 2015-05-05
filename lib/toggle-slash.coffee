module.exports =
  replace: (slash)->
    editor = atom.workspace.getActiveTextEditor()
    cursor = editor.cursors[0].getBufferPosition()
    if text = editor.getSelectedText()
      range = editor.getSelectedBufferRange()
    else
     {text, range} = @getText(editor)
    return unless ( text or range )
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
    editor.setTextInBufferRange range,text
    editor.cursors[0].setBufferPosition(cursor)

  getText: (ed)->
    cursor = ed.cursors[0]
    regx = /[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
    range = ed.displayBuffer.bufferRangeForScopeAtPosition '.string.quoted',cursor.getBufferPosition()
    if range
      text = ed.getTextInBufferRange(range)
    else
      text = ed.getWordUnderCursor wordRegex:regx
      range = cursor.getCurrentWordBufferRange wordRegex:regx if text
    {range,text}

  activate: (state) ->
    atom.commands.add 'atom-text-editor','toggle-slash:back',  =>
      @replace('\\')
    atom.commands.add 'atom-text-editor','toggle-slash:forward', =>
      @replace('/')
