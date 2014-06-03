Contributing
-------------

Pull requests of all sizes are very much appreciated, below is a quick guide on how you can help:

1. Fork the repository

2. minicron uses [Git Flow](https://github.com/nvie/gitflow) so preferably make sure you have that installed,
   [here](https://www.youtube.com/watch?v=I-73cssiVC4) is a good explanation of how to use it

3. Check out the `develop` branch, `git flow init` (w/ default prompt values), and start a feature `git flow feature start yourfeature`.

3. Install a local copy of minicron like so: ````bundle```` & ````rake install````

4. Run the tests to be sure everything is working before you begin like so: ````rake spec````

5. Make your changes.

6. With the exception of documentation changes, any changes should ideally have accompanying tests.

7. Finish your feature `git flow feature finish`

8. Submit your pull request from your `develop` branch to minicron's `develop` branch

Where possible I'm trying to adhere to the [Ruby Community Styleguide](https://github.com/bbatsov/ruby-style-guide "Ruby Community Styleguide") so please try to do so when making your changes. Install a plugin for [EditorConfig](http://editorconfig.org) and your IDE should do a lot of this for you automatically!

Thanks!
