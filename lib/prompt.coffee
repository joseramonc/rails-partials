{$, TextEditorView, View} = require 'atom-space-pen-views'
fs = require 'fs-plus'
PromptHelper = require './prompt-helper'

module.exports =
class RailsPartialsPromptView extends View
  @content: ({prompt} = {}) ->
    #rails-partials-prompt class is for specs
    @div class: 'rails-partials-prompt overlay', =>
      @label outlet: 'promptText'
      @subview 'promptInput', new TextEditorView(mini: true, placeholderText: 'layouts/navbar')
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: (railsPartials) ->
    @delegate = railsPartials
    @promptText.addClass 'icon-file-add'
    @promptText.text 'Name of the new partial'
    @attach()
    atom.commands.add @element, 'core:confirm', => @confirm()
    atom.commands.add @element, 'core:cancel', => @delegate.deactivate()
    @promptInput.on 'blur', => @delegate.deactivate()
    @promptInput.on 'focusout', => @delegate.deactivate()

  close: ->
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()
    atom.workspace.getActivePane().activate()

  attach: ->
    @panel = atom.workspace.addModalPanel(item: @element)
    @promptInput.focus()

  confirm: ->
    input = @promptInput.getModel().getText()

    valid = true
    # validation of the input

    fileNamePath = PromptHelper.extractNamePath(input)
    parameters = PromptHelper.extractParameters(input)

    if PromptHelper.isDirectory(fileNamePath)
      @showError "Partial can't be a directory (can't end with '/')"
      valid = false

    partialFullPath = PromptHelper.partialFullPath(fileNamePath)
    if fs.isFileSync(partialFullPath) and valid
      @showError "#{partialFullPath} already exists."
      valid = false

    if valid
      @delegate.generate(fileNamePath, partialFullPath, parameters)
      @detach()

  showError: (message) ->
    @errorMessage.text(message)
    @flashError()
