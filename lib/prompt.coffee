{$, TextEditorView, View} = require 'atom-space-pen-views'
fs = require 'fs-plus'

module.exports =
class RailsPartialsPromptView extends View
  @attach: -> new RailsPartialsPromptView()

  @content: ->
    #rails-partials-prompt class is for specs
    @div class: 'rails-partials-prompt overlay', =>
      @label outlet: 'promptText'
      @subview 'promptInput', new TextEditorView(mini: true, placeholderText: 'layouts/navbar')
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: (serializeState, railsPartials) ->
    @delegate = railsPartials
    @promptText.addClass 'icon-file-add'
    @editor = atom.workspace.getActiveEditor()
    @promptText.text 'partial name to be rendered'
    @attach()
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @destroy()
    @promptInput.on 'focusout', => @remove()

  serialize: ->

  destroy: ->
    @remove()
    $('atom-text-editor').focus()

  attach: ->
    # console.log 'attaching'
    atom.workspace.addTopPanel(item: @, visible: true)
    @promptInput.focus()

  confirm: ->
    input = @promptInput.getModel().getText()
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
