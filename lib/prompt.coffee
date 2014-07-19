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
    @div class: 'mini', =>
      @div class: 'rails-partials-prompt__input', =>
        @div class: 'feedback hide', =>
          @p class: 'error', 'Already exists'
        @subview 'panelInput', new EditorView(mini: true)

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
    @panelInput.setText('')
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
      console.log 'exists poo poo face'
      @showError 'File already exists'

  cancel: ->
    @trigger 'cancel'
    method(@delegate, 'cancel')()
    @detach()

  detach: ->
    super
    @trigger 'detach'
    method(@delegate, 'hide')()
  
  showError: (message='') ->
    @panelInput.find('.feedback').show()
