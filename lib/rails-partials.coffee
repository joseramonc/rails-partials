{CompositeDisposable} = require 'atom'
S = require 'string'
Prompt = require './prompt'
path = require 'path'

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

  # expects:
  #   input: 'shared/layout' or 'partial_name'
  #   partialFullPath: '/Users/....../rails/app/views/layouts/_navbar.html.erb' as given by atom
  #   parameters: 'f:f user:@user...'
  generate: (input, partialFullPath, parameters) ->
    # replace selection for command in original file
    editor = atom.workspace.getActiveTextEditor()
    selection = editor.getLastSelection().getText()
    editor.insertText(
              @renderInstruction(
                input,
                parameters
              ),
              autoIndent: atom.config.get('editor.autoIndentOnPaste')
    ) # insert render command in active file

    # create partial file with selected text
    selection = @refactorParameters(selection, parameters)
    console.log selection
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

  refactorParameters: (selection, parameters) ->
    return selection if parameters is null
    refactoredSelection = selection
    parameters = S(parameters).parseCSV(' ', null)
    erbRegex = ///
      <%
        .* # match everything inside an erb block
      %>
    ///g

    erbBlocks = []
    match = erbRegex.exec(selection)
    while match isnt null
      erbBlocks.push(match)
      match = erbRegex.exec(selection)

    # we expect parameters to be of the form "var:@value var2:@value_2 var3:@va..."
    for param in parameters
      refactorPair = S(param).parseCSV(':', null)
      for block in erbBlocks
        newBlock = S(block).replaceAll(refactorPair[1], refactorPair[0]).s
        console.log "replacing #{newBlock}"
        refactoredSelection = S(refactoredSelection).replaceAll(block, newBlock).s
    refactoredSelection

  renderInstruction: (partialName, parameters) ->
    params = ''
    if parameters isnt null
      # prepare params for instruction
      params = ", #{S(parameters).replaceAll(' ', ', ').s}"
      params = S(params).replaceAll(':', ': ').s

    fileName = atom.workspace.getActiveTextEditor().getTitle()
    extension = path.extname(fileName)
    switch extension
      when '.scss'
        return "@import \"#{partialName}\";"
      when '.sass'
        return "@import #{partialName}"
      when '.haml'
        return "= render '#{partialName}'#{params}"
      when '.slim'
        return "== render '#{partialName}'#{params}"
      else
        return "<%= render '#{partialName}'#{params} %>"
