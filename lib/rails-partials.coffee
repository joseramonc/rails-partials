fs = require 'fs'
path = require 'path'

PromptView = require './prompt'
prompt = new PromptView()

module.exports =
  railsPartialsView: null
  partial_name: ''

  activate: (state) ->
    atom.workspaceView.command "rails-partials:generate", => @generate()

  generate: ->
    editor = atom.workspace.getActiveEditor()
    selection = editor.getSelection().getText()
    editor_path = path.dirname(editor.getPath())

    prompt.show
      label: 'Partial Name (No _ at the begginng or extensions needed)',
      editor: editor,
      editorView: editor.editorView,
      confirm: (text) ->
        # console.log 'file name: _' + text + '.html.erb'
        fs.open "#{editor_path}/_#{text}.html.erb", 'wx', (err, fd)->
          fs.write fd, selection
          editor.open
        editor.deleteToEndOfLine()
