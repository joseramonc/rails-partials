{WorkspaceView} = require 'atom'
RailsPartials = require '../lib/rails-partials'
path = require 'path'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RailsPartials", ->
  [activationPromise, activeEditor, selection] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView()
    atom.project.setPath(path.join(__dirname, 'fixtures'))
    atom.workspaceView.attachToDom()
    activationPromise = atom.packages.activatePackage('rails-partials')

  describe "when the rails-partials:generate event is triggered", ->
    it "attaches the prompt", ->
      partialDialog = null

      waitsForPromise ->
        atom.workspace.open(__dirname + 'index.html.erb').then (layoutEditor) ->
          activeEditor = layoutEditor
          activeEditor.setCursorScreenPosition([7, 5])
          activeEditor.selectDown(2)
          atom.workspaceView.trigger 'rails-partials:generate'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.packages.isPackageActive('rails-partials')).toBe true
        partialDialog = atom.workspaceView.find(".rails-partials-prompt").view()
        expect(partialDialog).toExist()

        # treeView = atom.workspaceView.find(".rails-partials-prompt").view()
        # atom.workspaceView.trigger 'rails-partials:generate'
      #   atom.workspaceView.trigger 'rails-partials:generate'
      #   expect(atom.workspaceView.find('.rails-partials')).toExist()
