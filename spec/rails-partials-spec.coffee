{WorkspaceView} = require 'atom'
RailsPartials = require '../lib/rails-partials'
path = require 'path'
fs = require 'fs-plus'
# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RailsPartials", ->
  [activationPromise] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView()
    atom.workspaceView.attachToDom()
    activationPromise = atom.packages.activatePackage('rails-partials')

    waitsForPromise ->
      atom.packages.activatePackage('language-ruby')

  describe "when the rails-partials:generate event is triggered", ->
    it "attaches the prompt", ->
      waitsForPromise ->
        atom.workspace.open(__dirname + 'index.html.erb').then (layoutEditor) ->
          atom.workspaceView.trigger 'rails-partials:generate'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.packages.isPackageActive('rails-partials')).toBe true
        partialPrompt = atom.workspaceView.find(".rails-partials-prompt").view()
        expect(partialPrompt).toExist()

    describe "when the input is the name of the file", ->
      describe "when .erb extension", ->
        [mainEditor, partialPrompt, selection] = []
        beforeEach ->
          mainEditor = null
          partialPrompt = null

          waitsForPromise ->
            atom.workspace.open(__dirname + '/fixtures/index.html.erb').then (erbEditor) ->
              mainEditor = erbEditor
              mainEditor.setCursorScreenPosition([5, 4])
              mainEditor.selectDown(2)
              mainEditor.selectToEndOfLine()
              selection = mainEditor.getSelectedText()
              atom.workspaceView.trigger 'rails-partials:generate'
              partialPrompt = atom.workspaceView.find(".rails-partials-prompt").view()
              expect(partialPrompt).toExist()

          runs ->
            partialPrompt.promptInput.insertText('awesome_erb_partial')
            partialPrompt.trigger('core:confirm')


        it "puts the render instruction in file", ->
          expect(mainEditor.getText()).toContain('<%= render "awesome_erb_partial" %>')

        it "generates the partial with the correct name and in same directory", ->
          runs ->
            waitsForPromise ->
              atom.workspace.open(__dirname + '/fixtures/_awesome_erb_partial.html.erb').then (secondErbEditor) ->
                expect(secondErbEditor.getText()).toContain(selection)
                fs.removeSync(secondErbEditor.getPath())

      describe "when .haml extension", ->
        [mainEditor, partialPrompt, selection] = []
        beforeEach ->
          mainEditor = null
          partialPrompt = null

          waitsForPromise ->
            atom.workspace.open(__dirname + '/fixtures/index.html.haml').then (hamlEditor) ->
              mainEditor = hamlEditor
              mainEditor.setCursorScreenPosition([5, 6])
              mainEditor.selectDown(3)
              mainEditor.selectToEndOfLine()
              selection = mainEditor.getSelectedText()
              atom.workspaceView.trigger 'rails-partials:generate'
              partialPrompt = atom.workspaceView.find(".rails-partials-prompt").view()
              expect(partialPrompt).toExist()

          runs ->
            partialPrompt.promptInput.insertText('awesome_haml_partial')
            partialPrompt.trigger('core:confirm')

        it "puts the render instruction in file", ->
          expect(mainEditor.getText()).toContain('= render "awesome_haml_partial"')

        it "generates the partial with the correct name and in same directory", ->
          runs ->
            waitsForPromise ->
              atom.workspace.open(__dirname + '/fixtures/_awesome_haml_partial.html.haml').then (secondHamlEditor) ->
                expect(secondHamlEditor.getText()).toContain(selection)
                fs.removeSync(secondHamlEditor.getPath())


    describe "when there's a input with directories", ->
      [mainEditor, partialEditor, selection, partialPrompt] = []
      beforeEach ->
        mainEditor = null
        partialPrompt = null
        selection = null

        waitsForPromise ->
          atom.workspace.open(__dirname + '/fixtures/index.html.erb').then (erbEditor) ->
            mainEditor = erbEditor
            mainEditor.setCursorScreenPosition([5, 4])
            mainEditor.selectDown(2)
            mainEditor.selectToEndOfLine()
            selection = mainEditor.getSelectedText()
            atom.workspaceView.trigger 'rails-partials:generate'
            partialPrompt = atom.workspaceView.find(".rails-partials-prompt").view()

        runs ->
          partialPrompt.promptInput.insertText('shared/nested/partial')
          partialPrompt.trigger('core:confirm')

      it "generate the partial rendering the correct path", ->
        expect(mainEditor.getText()).toContain('<%= render "shared/nested/partial" %>')

      describe "when the file alredy exists", ->
        it "it shouldn't generate a partial and should show error message", ->
          atom.workspaceView.trigger 'rails-partials:generate'
          partialPrompt = atom.workspaceView.find(".rails-partials-prompt").view()
          partialPrompt.promptInput.insertText('shared/nested/partial')
          partialPrompt.trigger('core:confirm')
          expect(partialPrompt).toExist()
          expect(partialPrompt.errorMessage.text()).toContain('already exists')
          expect(partialPrompt).toHaveClass('error')
          expect(partialPrompt.hasParent()).toBeTruthy()

      it "generate the partial with the correct content and name in app/views/shared/nested/ directory", ->
        runs ->
          waitsForPromise ->
            atom.workspace.open(__dirname + '/fixtures/app/views/shared/nested/_partial.html.erb').then (secondErbEditor) ->
              expect(secondErbEditor.getText()).toContain(selection)
              fs.removeSync(__dirname + '/fixtures/app')

    describe "when the input is a directory", ->
      [partialPrompt] = []
      waitsForPromise ->
        atom.workspace.open(__dirname + '/fixtures/index.html.erb').then (erbEditor) ->
          mainEditor = erbEditor
          mainEditor.setCursorScreenPosition([5, 4])
          atom.workspaceView.trigger 'rails-partials:generate'
          partialPrompt = atom.workspaceView.find(".rails-partials-prompt").view()
      runs ->
        partialPrompt.promptInput.insertText('a/directory/path/')
        partialPrompt.trigger('core:confirm')

      it "should display the directory error message", ->
        runs ->
          expect(partialPrompt).toExist()
          expect(partialPrompt.errorMessage.text()).toContain("can't be a directory")
          expect(partialPrompt).toHaveClass('error')
