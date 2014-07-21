{$, EditorView, View} = require 'atom'
fs = require 'fs-plus'

module.exports =
class RailsPartialsPromptView extends View
  @attach: -> new RailsPartialsPromptView

  @content: ->
    @div class: 'overlay from-top', =>
      @label class: 'icon', outlet: 'promptText'
      @subview 'promptInput', new EditorView(mini: true)
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: (@delegate={}) ->
    @promptText.addClass(@delegate.iconClass)
    @editor = @delegate.editor
    @promptText.text(@delegate.label)
    @promptInput.setPlaceholderText @delegate.placeholder
    @attach()
    @panelEditor = @promptInput.getEditor()
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @detach()
    @on 'focusout', => @detach()

  attach: ->
    @attached = true
    atom.workspaceView.prependToTop(this)
    @promptInput.focus()

  confirm: ->
    @trigger 'confirm'
    input = @panelEditor.getText()
    #validation of text would go here...
    valid = true
    if input.slice(-1) == '/'
      @showError "Partial can't be a directory (can't end with '/')"
      valid = false
    partialFullPath = @delegate.partialFullPath(input)
    if fs.isFileSync(partialFullPath) && valid
      @showError "#{partialFullPath} already exists."
      valid = false
    if valid
      @delegate.confirm(input)
      @detach()


  detach: ->
    if @attached
      @attached = false
      super
      $('.editor').focus()

  showError: (message='') ->
    @errorMessage.text(message)
    @flashError() if message
