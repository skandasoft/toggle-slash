{Range} = require 'atom'

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
    # range = ed.displayBuffer.bufferRangeForScopeAtPosition '.string.quoted',cursor.getBufferPosition()
    # if range
    #   text = ed.getTextInBufferRange(range)
    range = @getQuoteRange(cursor,ed)
    if range
      text = ed.getTextInBufferRange(range)
    unless text
      text = ed.getWordUnderCursor wordRegex:regx
      range = cursor.getCurrentWordBufferRange wordRegex:regx if text
    {range,text}

  activate: (state) ->
    atom.commands.add 'atom-text-editor','toggle-slash:back',  =>
      @replace('\\')
    atom.commands.add 'atom-text-editor','toggle-slash:forward', =>
      @replace('/')

  getQuoteRange: (cursor,ed)->
    closing = @getClosingQuotePosition(cursor,ed)
    return false unless closing?
    opening = @getOpeningQuotePosition(cursor,ed)
    return false unless opening?
    new Range opening, closing

  getOpeningQuotePosition: (cursor,ed) ->
    range = cursor.getCurrentLineBufferRange()
    range.end.column = cursor.getScreenPosition().column
    quote = false
    ed.buffer.backwardsScanInRange /[`|'|"]/g, range, (obj) =>
      return false unless @quoteType
      obj.stop() if obj.matchText is @quoteType
      quote = obj.range.end
    quote

  getClosingQuotePosition: (cursor,ed) ->
    range = cursor.getCurrentLineBufferRange()
    range.start.column = cursor.getScreenPosition().column
    quote = false
    delete @quoteType
    ed.buffer.scanInRange /[`|'|"]/g, range, (obj) =>
      @quoteType = obj.matchText
      obj.stop()
      quote = obj.range.start
    quote
