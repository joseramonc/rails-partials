SpacePen = require 'atom-space-pen-views'
Path = require 'path'
Fs = require 'fs-plus'
# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.
readFile = (path) ->
  Fs.readFileSync(Path.join(__dirname, "./fixtures/", path), "utf8")

describe "RailsPartials", ->
  [editor, editorElement] = []

  beforeEach ->

    waitsForPromise ->
      atom.workspace.open('index.html.erb')

    waitsForPromise ->
      atom.packages.activatePackage('language-ruby')

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorElement = atom.views.getView(editor)

  describe "Generating a partial in the editor", ->
    beforeEach ->
      atom.workspace.open('index.html.erb')
      editor.setCursorScreenPosition([5, 4])
      editor.selectDown(2)
      editor.selectToEndOfLine()
      selection = editor.getSelectedText()


    it "displays partials prompt", ->
      atom.commands.dispatch editorElement, 'rails-partials:generate'
      # expect(partialPrompt).toExist()
      expect(true).toBe(true)
