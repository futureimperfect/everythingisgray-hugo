# everythingisgray-hugo

My blog. Powered by [Hugo](https://gohugo.io/).

## Building locally

Requires Hugo extended (0.170+) and [Dart Sass](https://gohugo.io/functions/css/sass/#dart-sass) on your `PATH`:

```sh
# Homebrew requires third-party taps to be added and trusted explicitly. The
# Sass formula depends on the Dart SDK from the dart-lang/dart tap.
brew tap dart-lang/dart
brew trust dart-lang/dart
brew tap sass/sass
brew install hugo sass/sass/sass
make serve
```
