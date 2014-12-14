{WorkspaceView} = require 'atom'
ToggleSlash = require '../lib/toggle-slash'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "ToggleSlash", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('toggle-slash')

  describe "when the toggle-slash:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.toggle-slash')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch atom.workspaceView.element, 'toggle-slash:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.toggle-slash')).toExist()
        atom.commands.dispatch atom.workspaceView.element, 'toggle-slash:toggle'
        expect(atom.workspaceView.find('.toggle-slash')).not.toExist()
