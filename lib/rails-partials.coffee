path = require 'path'
S = require 'string'

PromptView = require './prompt'
prompt = new PromptView()
RAILS_VIEWS_PATH = 'app/views'

module.exports =
  railsPartialsView: null

  activate: (state) ->
    atom.workspaceView.command "rails-partials:generate", => @generate()

  generate: ->
    editor = atom.workspace.getActiveEditor()
    selection = editor.getSelection().getText()
    prompt.show
      label: 'Partial Name (No _ at the begginng or file extensions)',
      editor: editor,
      removeUnusefulSymbols: @removeUnusefulSymbols,
      editorExtension: @editorExtension,
      renderInstruction: @renderInstruction,
      inputPath: @inputPath,
      fileDirectory: @fileDirectory,
      fileName: @fileName,
      editorView: editor.editorView,
      confirm: (input) ->
        directory = @fileDirectory(input)
        fileName = @fileName(input)
        partialName = "_#{fileName}.html#{@editorExtension()}"
        editor.insertText(@renderInstruction(@inputPath(input)), autoIndent: true)
        promise = atom.workspace.open "#{directory}/#{partialName}"
        promise.then (partialEditor) ->
          partialEditor.insertText(selection, autoIndent: true)
          partialEditor.saveAs("#{directory}/#{partialName}")

  fileDirectory: (input) ->
    if S(input).contains('/')
      # when input is a path we generate the file in
      # the RAILS_VIEWS_PATH direcotry + input
      inputPath = S(input).chompLeft('/').chompRight('/').s #remove prefix and suffix '/'
      path.dirname(path.resolve(atom.project.path, RAILS_VIEWS_PATH, inputPath))
    else
      # generate file on the same directory
      path.dirname(atom.workspace.getActiveEditor().getPath())

  inputPath: (input) ->
    if S(input).contains('/')
      S(input).chompLeft('/').chompRight('/').s #remove prefix and suffix '/'
    else
      input

  fileName: (input) ->
    if S(input).contains('/')
      inputPath = S(input).chompLeft('/').chompRight('/').s #remove prefix and suffix '/'
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
