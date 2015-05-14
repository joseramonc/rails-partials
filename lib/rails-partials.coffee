{CompositeDisposable} = require 'atom'
S = require 'string'
Prompt = require './prompt'
PromptHelper = require './prompt-helper'

module.exports =
  config:
    showPartialInNewTab:
      type: 'boolean'
      default: true

  prompt: null

  activate: (state) ->
    @disposables = new CompositeDisposable
    @disposables.add atom.commands.add 'atom-workspace', 'rails-partials:generate': => @showPrompt()

  showPrompt: ->
    @prompt = new Prompt(@)

  generate: (input, partialFullPath, parameters) ->
    editor = atom.workspace.getActiveTextEditor()
    selection = editor.getLastSelection().getText()
    editor.insertText(
              @renderInstruction(
                input,
                parameters
              ),
              autoIndent: atom.config.get('editor.autoIndentOnPaste')
    )
    promise = atom.workspace.open(partialFullPath)
    promise.then (partialEditor) ->
      partialEditor.insertText(selection, autoIndent: atom.config.get('editor.autoIndentOnPaste'))
      partialEditor.saveAs(partialFullPath)
      if !atom.config.get('rails-partials.showPartialInNewTab')
        # close created editor if preference says so
        atom.workspace.destroyActivePaneItem()

  deactivate: ->
    @prompt.close()

  serialize: ->
    prompt: null

  renderInstruction: (partialName, parameters) ->
    params = ''
    if parameters != null
      # prepare params instruction
      params = ", #{S(parameters).replaceAll(' ', ', ').s}"
      params = S(params).replaceAll(':', ': ').s

    fileName = atom.workspace.getActiveTextEditor().getTitle()
    extension = path.extname(fileName)
    if extension is '.haml'
      "= render \"#{partialName}\"#{params}"
    else
      "<%= render \"#{partialName}\"#{params} %>"
