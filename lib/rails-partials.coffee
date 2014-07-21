path = require 'path'
S = require 'string'

Prompt = require './prompt'
RAILS_VIEWS_PATH = 'app/views'

module.exports =
  railsPartialsView: null

  activate: (state) ->
    editor = atom.workspace.getActiveEditor()
    selection = editor.getSelection().getText()
    atom.workspaceView.command "rails-partials:generate", => @showPrompt(state)
    console.log 'activating'

  showPrompt: (state) ->
    @railsPartialsView = new Prompt(state.railsPartialsPromptState, @)

  generate: (input, partialFullPath) ->
    editor = atom.workspace.getActiveEditor()
    selection = editor.getSelection().getText()
    editor.insertText(@renderInstruction(@inputPath(input)), autoIndent: true)
    promise = atom.workspace.open(partialFullPath)
    promise.then (partialEditor) ->
      partialEditor.insertText(selection, autoIndent: true)
      partialEditor.saveAs(partialFullPath)

  deactivate: ->
    console.log 'deactiving'
    @railsPartialsView.destroy()

  serialize: ->
    console.log 'requesting serailize view'
    railsPartialsView: @railsPartialsView.serialize()

  fileDirectory: (input) ->
    if S(input).contains('/')
      # when input is a path we generate the file in
      # the RAILS_VIEWS_PATH direcotry + input
      inputPath = S(input).chompLeft('/').s #remove prefix '/'
      path.dirname(path.resolve(atom.project.path, RAILS_VIEWS_PATH, inputPath))
    else
      # generate file on the same directory
      path.dirname(atom.workspace.getActiveEditor().getPath())

  inputPath: (input) ->
    if S(input).contains('/')
      S(input).chompLeft('/').s #remove prefix '/'
    else
      input

  partialName: (fileNameWithoutExtensions) ->
    "_#{fileNameWithoutExtensions}.html#{@editorExtension()}"

  partialFullPath: (input) ->
    directory = @fileDirectory(input)
    fileName = @getFileName(input)
    partialName = @partialName(fileName)
    return "#{directory}/#{partialName}"

  getFileName: (input) ->
    if S(input).contains('/')
      inputPath = S(input).chompLeft('/').s #remove prefix '/'
      inputArray = S(input).parseCSV('/', null)
      fileName = inputArray.pop() # the last element is the file name
    else
      fileName = input
    @removeUnusefulSymbols(fileName)

  editorExtension: ->
    fileName = atom.workspace.getActiveEditor().getTitle()
    path.extname fileName

  removeUnusefulSymbols: (fileName) ->
    fileName = S(fileName).chompLeft '_' # remove starting underscore
    # remove present known extensions
    fileName = S(fileName).chompRight '.erb'
    fileName = S(fileName).chompRight '.haml'
    fileName = S(fileName).chompRight '.html'
    fileName.s

  renderInstruction: (partialName) ->
    if @editorExtension() == ".haml"
      "= render \"#{partialName}\""
    else
      "<%= render \"#{partialName}\" %>"

  isDirectory: (input) ->
    if input.slice(-1) == '/'
      true
    else
      false
