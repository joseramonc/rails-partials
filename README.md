# rails-partials package

An Atom package to easily create partials for your ruby on rails application.

## Features
* Support for `.erb` and `.haml` files.
* Support for partials in other directories, when a partial is created with a name with slashes for example 'shared/footer', the partial is going to be created at `app/views/shared/_footer.html.yourext`

## Installation

In Atom, open Preferences > Packages, search for rails-partials package. Once it found, click Install button to install package.

## Manual installation

You can install the latest rails-partials version manually from console:

    cd ~/.atom/packages
    git clone https://github.com/joseramonc/rails-partials
    cd rails-partials
    npm install
    # Then restart Atom editor.

![Demo](http://cl.ly/image/0b1j3t0c1T1k/railsdemo.gif)

You can trigger the extension by:

* Right clicking with a selection and selecting the command (.gif)

* <kbd>⌃⌥P</kbd>: The default keybinding, of course, which can be changed with your favorite for your simplicity.

Please report any problems or suggestions at [issue tracker](https://github.com/joseramonc/rails-partials/issues/new).
