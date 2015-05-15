# rails-partials package

An [Atom package](https://atom.io/packages/rails-partials) to easily create partials for your ruby on rails application.

## Features
* Support for `.erb`, `.haml` and `.slim` files.
* Support for `.scss` and `.sass` files.
* Support for partials in other directories, when a partial is created with a name with slashes for example 'shared/footer', the partial is going to be created at `app/views/shared/_footer.html.yourext`
* Support to send parameters into partials, 'shared/footer user:@user var:@var' generates <%= render 'shared/footer', user: @user, var: @var %>
* Support for refactor variables into partials.
* Configuration to show or not show the generated partial in a new tab (defaults to true)

## Installation

In Atom, open Preferences > Packages, search for rails-partials package. Once it found, click Install button to install package.

![Demo](https://s3.amazonaws.com/f.cl.ly/items/000H3H0E2E110Q01370z/rails-partials-demo.gif)

![Demo Refactor](http://cl.ly/image/46111i0C2t1T/rails-partials-refactor.gif)

You can trigger the extension by:

* Right clicking with a selection and selecting the command (.gif)

* <kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>P</kbd>: The default keybinding (darwin), can be changed with your favorite.

* <kbd>shift</kbd> + <kbd>alt</kbd> + <kbd>P</kbd>: The default keybinding (linux / windows), can be changed with your favorite.

Please report any problems or suggestions at [issue tracker](https://github.com/joseramonc/rails-partials/issues/new).
