fs = require 'fs'
path = require 'path'

module.exports =
  railsPartialsView: null

  activate: (state) ->
    atom.workspaceView.command "rails-partials:generate", => @generate()

  generate: ->
    editor = atom.workspace.getActiveEditor()
    selection = editor.getSelection().getText()
    editor_path path.dirname(editor.getPath())
    # partial_name = 
    fs.open("#{editor_path}/file.txt", 'wx')
