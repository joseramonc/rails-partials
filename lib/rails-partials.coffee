{CompositeDisposable} = require 'atom'
path = require 'path'
S = require 'string'

Prompt = require './prompt'
RAILS_VIEWS_PATH = 'app/views'

module.exports =
  configDefaults:
    showPartialInNewTab: true

  railsPartialsView: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'rails-partials:generate': => @showPrompt(state)

  showPrompt: (state) ->
    @railsPartialsView = new Prompt(state.railsPartialsPromptState, @)

  generate: (input, partialFullPath) ->
    editor = atom.workspace.getActiveTextEditor()
    selection = editor.getLastSelection().getText()
    editor.insertText(@renderInstruction(@inputPath(input)), autoIndent: true)
    promise = atom.workspace.open(partialFullPath)
    promise.then (partialEditor) ->
      partialEditor.insertText(selection, autoIndent: true)
      partialEditor.saveAs(partialFullPath)
      if !atom.config.get('rails-partials.showPartialInNewTab')
        # close created editor if preference says so
        atom.workspace.destroyActivePaneItem()

  deactivate: ->
    @railsPartialsView.destroy()

  serialize: ->
    railsPartialsView: @railsPartialsView.serialize()

  fileDirectory: (input) ->
    if S(input).contains('/')
      # when input is a path we generate the file in
      # the RAILS_VIEWS_PATH direcotry + input
      inputPath = S(input).chompLeft('/').s # remove prefix '/'
      projectPath = atom.project.getPaths(atom.workspace.getActiveTextEditor())[0]
      path.dirname(path.resolve(projectPath, RAILS_VIEWS_PATH, inputPath))
    else
      # generate file on the same directory
      path.dirname(atom.workspace.getActiveTextEditor().getPath())

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
    fileName = atom.workspace.getActiveTextEditor().getTitle()
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
