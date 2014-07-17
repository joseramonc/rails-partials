fs = require 'fs'
path = require 'path'
S = require 'string'

PromptView = require './prompt'
prompt = new PromptView()

module.exports =
  railsPartialsView: null

  activate: (state) ->
    atom.workspaceView.command "rails-partials:generate", => @generate()

  generate: ->
    editor = atom.workspace.getActiveEditor()
    selection = editor.getSelection().getText()
    editorPath = path.dirname(editor.getPath())
    that = @
    prompt.show
      label: 'Partial Name (No _ at the begginng or file extensions)',
      editor: editor,
      editorView: editor.editorView,
      confirm: (partialName) ->
        partialName = that.removeUnusefulSymbols(partialName)
        # console.log 'file name: _' + partialName + '.html.erb'
        fs.open "#{editorPath}/_#{partialName}.html#{that.partialExtension()}", 'wx', (err, fd) ->
          fs.write fd, selection
        editor.insertText(that.renderInstruction(partialName))

  partialExtension: ->
    fileName = atom.workspace.getActiveEditor().getTitle()
    console.log(path.extname(fileName))
    path.extname fileName

  removeUnusefulSymbols: (text) ->
    text = S(text).chompLeft '_' # starting underscore
    # remove present known extensions
    text = S(text).chompLeft '.erb'
    text = S(text).chompLeft '.haml'
    # html
    text = S(text).chompRight '.html'
    text.s

  renderInstruction: (partialName) ->
    if @partialExtension() == ".haml"
      "= render \"#{partialName}\""
    else
      "<%= render \"#{partialName}\" %>"
