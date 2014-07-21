{$, EditorView, View} = require 'atom'
fs = require 'fs-plus'

module.exports =
class RailsPartialsPromptView extends View
  @attach: -> new RailsPartialsPromptView()

  @content: ->
    #rails-partials-prompt class is for specs
    @div class: 'rails-partials-prompt overlay from-top', =>
      @label class: 'icon', outlet: 'promptText'
      @subview 'promptInput', new EditorView(mini: true)
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: (serializeState, railsPartials) ->
    @delegate = railsPartials
    console.log 'initializing'
    @promptText.addClass 'icon-file-add'
    @editor = atom.workspace.getActiveEditor()
    @promptText.text "Partial Name (No _ at the begginng or file extensions required)"
    @promptInput.setPlaceholderText 'partial name wihtout underscore and without extensions'
    @attach()
    @inputEditor = @promptInput.getEditor()
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @destroy()
    @promptInput.hiddenInput.on 'focusout', => @remove()

  serialize: ->

  destroy: ->
    @remove()
    $('.editor').focus()

  attach: ->
    # console.log 'attaching'
    @attached = true
    atom.workspaceView.append(this)
    @promptInput.focus()

  confirm: ->
    input = @inputEditor.getText()
    #validation of text would go here...
    valid = true
    if @delegate.isDirectory(input)
      @showError "Partial can't be a directory (can't end with '/')"
      valid = false
    partialFullPath = @delegate.partialFullPath(input)
    if fs.isFileSync(partialFullPath) && valid
      @showError "#{partialFullPath} already exists."
      valid = false
    if valid
      @delegate.generate(input, partialFullPath)
      @destroy()

  showError: (message='') ->
    @errorMessage.text(message)
    @flashError() if message
