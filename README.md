# ServerDeck

Your Linux servers, from your phone, over plain SSH.

ServerDeck is a mobile app for looking after a handful of servers: how they are
doing, which services are up, what the logs say, and the one command you need
to run right now. It talks to each server over SSH and nothing else, so there
is no agent to install and nothing new listening on the server.

Written in Flutter. Built and tested on Android; the same code compiles for
iOS, and CI checks that it does.

Work in progress: the app is being built now, and this README will describe it
properly once it does what it promises.

## Building

Flutter 3.47 or later.

```
flutter pub get
flutter run
```

## License

MIT, see [LICENSE](LICENSE).
