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

  generate: (input, partialFullPath, parameters) ->
    # cut and insert command in original file
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
    refactoredSelection = []
    parameters = S(parameters).parseCSV(' ', null)
    # lines = S(selection).lines()
    # console.log lines
    erbRegex = ///
      <%
        .* # match everything inside an erb block
      %>
    ///
    console.log "Regex: "
    console.log selection.match(erbRegex)
    # we expect parameters to be of the form "var:@value var2:@value_2 var3:@va..."
    # for param in parameters
    #   refactorPair = S(param).parseCSV(':', null)
    #   for line in lines
    #     erbBlocks = line.match(erbRegex)
    #     erbBlocks = [] if erbBlocks is null
    #     console.log "Matching blocks: #{erbBlocks} in line #{line}"
    #     # for every erb block in line
    #     for block in erbBlocks
    #       newBlock = S(block).replaceAll(refactorPair[1], refactorPair[0]).s
    #       console.log "replacing #{block} for #{newBlock}"
    #       refactoredSelection.push S(line).replaceAll(block, newBlock).s
    console.log refactoredSelection
    selection

  renderInstruction: (partialName, parameters) ->
    params = ''
    if parameters != null
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
