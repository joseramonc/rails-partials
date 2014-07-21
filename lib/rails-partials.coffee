path = require 'path'
S = require 'string'

RailsPartialsPromptView = require './prompt'
RAILS_VIEWS_PATH = 'app/views'

module.exports =
  railsPartialsView: null

  activate: (state) ->
    atom.workspaceView.command "rails-partials:generate", => @generate()

  generate: ->
    editor = atom.workspace.getActiveEditor()
    selection = editor.getSelection().getText()
    new RailsPartialsPromptView(
      label: 'Partial Name (No _ at the begginng or file extensions required)',
      placeholder: 'partial name wihtout underscore and without extensions',
      iconClass: 'icon-file-add',
      editor: editor,
      editorExtension: @editorExtension,
      renderInstruction: @renderInstruction,
      inputPath: @inputPath,
      fileDirectory: @fileDirectory,
      getFileName: @getFileName,
      partialName: @partialName,
      removeUnusefulSymbols: @removeUnusefulSymbols,
      partialFullPath: @partialFullPath,
      confirm: (input) ->
        editor.insertText(@renderInstruction(@inputPath(input)), autoIndent: true)
        partialFullPath = @partialFullPath(input)
        promise = atom.workspace.open(partialFullPath)
        promise.then (partialEditor) ->
          partialEditor.insertText(selection, autoIndent: true)
          partialEditor.saveAs(partialFullPath)
    )


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
