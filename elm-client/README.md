# CJA Twilio Notification Scheduler

This app uses Firebase Hosting to schedule Twilio jobs. Twilio setup is separate.

## Getting Started

Get values for `.env` from Firebase. Instructions are [here](https://firebase.google.com/docs/web/setup?authuser=0#add-sdks-initialize).

### Install Dependencies

`yarn install`

### Running Locally

`yarn start`

Will compile your app and serve it from http://localhost:1234/
Changes to your source code will trigger a hot-reload in the browser, which
will also show compiler errors on build failures.

### Running Tests

`yarn test`

or

`yarn run autotest`

To re-run tests when files change.

### Production build

`yarn run build`

Will generate a production-ready build of your app in the `dist` folder.

### Elm Commands

Elm binaries can be found in `node_modules/.bin`. They can be run from within
your project via `yarn run`

To install new Elm packages, run:

`yarn run elm install <packageName>`

## Libraries & Tools

These are the main libraries and tools used to build elm-client. If you're not
sure how something works, getting more familiar with these might help.

### [Elm](https://elm-lang.org)

Elm is a delightful language for creating reliable webapps. It guarantees no
runtime exceptions, and provides excellent performance. If you're not familiar
with it, [the official guide](https://guide.elm-lang.org) is a great place to get
started, and the folks on [Slack](https://elmlang.herokuapp.com) and
[Discourse](https://discourse.elm-lang.org) are friendly and helpful if you get
stuck.

### [Elm Test](https://package.elm-lang.org/packages/elm-exploration/test/latest)

This is the standard testing library for Elm. In addition to being useful for
traditional fixed-input unit tests, it also supports property-based testing
where random data is used to validate behavior over a large input space. It's
really useful!

### [Parcel](https://parceljs.org)

Parcel build and bundles the application's assets into individual HTML, CSS, and
JavaScript files. It also runs the live-server used during development.
