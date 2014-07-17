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
    prompt.show
      label: 'Partial Name (No _ at the begginng or file extensions)',
      editor: editor,
      removeUnusefulSymbols: @removeUnusefulSymbols,
      editorExtension: @editorExtension,
      renderInstruction: @renderInstruction,
      editorView: editor.editorView,
      confirm: (input) ->
        fileName = @removeUnusefulSymbols(input)
        partialName = "_#{fileName}.html#{@editorExtension()}"
        fs.open "#{editorPath}/#{partialName}", 'wx', (err, fd) ->
          fs.write fd, selection
        editor.insertText(@renderInstruction(fileName), autoIndent: true)
        partialEditor = atom.workspace.open "#{editorPath}/#{partialName}"
        # open is async so we have to wait for it to open to select all and indent
        # partialEditor.selectAll()
        # partialEditor.IndentSelection()

  editorExtension: ->
    fileName = atom.workspace.getActiveEditor().getTitle()
    path.extname fileName

  removeUnusefulSymbols: (text) ->
    text = S(text).chompLeft '_' # starting underscore
    # remove present known extensions
    text = S(text).chompRight '.erb'
    text = S(text).chompRight '.haml'
    text = S(text).chompRight '.html'
    text.s

  renderInstruction: (partialName) ->
    if @editorExtension() == ".haml"
      "= render \"#{partialName}\""
    else
      "<%= render \"#{partialName}\" %>"
