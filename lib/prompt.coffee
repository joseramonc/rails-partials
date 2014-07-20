{$, EditorView, View} = require 'atom'
S = require 'string'
fs = require 'fs-plus'

noop = ->

method = (delegate, method) ->
  delegate?[method]?.bind(delegate) or noop

module.exports =
class PromptView extends View
  @attach: -> new PromptView

  @content: ->
    @div class: 'overlay from-top', =>
      @div class: 'rails-partials-prompt__input', =>
        @subview 'panelInput', new EditorView(mini: true)
        @div class: 'error-message', outlet: 'errorMessage'

  initialize: () ->
    @panelEditor = @panelInput.getEditor()
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @cancel()

  show: (@delegate={}) ->
    @editor = @delegate.editor
    @editorView = @delegate.editorView
    @panelInput.setPlaceholderText @delegate.label
    @attach()

  attach: ->
    @attached = true
    @previouslyFocusedElement = $(':focus')
    # atom.workspaceView.append(this)
    atom.workspaceView.prependToBottom(this)
    @panelInput.focus()
    @trigger 'attach'
    method(@delegate, 'show')()

  confirm: ->
    @trigger 'confirm'
    text = @panelEditor.getText()
    #validation of text would go here...
    directory = @delegate.fileDirectory(text)
    fileName = @delegate.fileName(text)
    partialName = "_#{fileName}.html#{@delegate.editorExtension()}"
    fileFullPath = "#{directory}/#{partialName}"
    unless fs.isFileSync(fileFullPath)
      method(@delegate, 'confirm')(text)
      @detach()
    else
      @showError 'File already exists'

  cancel: ->
    @trigger 'cancel'
    method(@delegate, 'cancel')()
    @detach()

  detach: ->
    @panelInput.setText('')
    super
    @showError ''
    @trigger 'detach'
    method(@delegate, 'hide')()

  showError: (message='') ->
    @errorMessage.text(message)
    @flashError() if message
