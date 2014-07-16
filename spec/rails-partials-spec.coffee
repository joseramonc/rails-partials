{WorkspaceView} = require 'atom'
RailsPartials = require '../lib/rails-partials'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RailsPartials", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('rails-partials')

  describe "when the rails-partials:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.rails-partials')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'rails-partials:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.rails-partials')).toExist()
        atom.workspaceView.trigger 'rails-partials:toggle'
        expect(atom.workspaceView.find('.rails-partials')).not.toExist()
