# Scheduler

I took this code from a [Fireship.io](https://fireship.io/) lesson called [Dynamic Scheduled Background Jobs in Firebase](https://fireship.io/lessons/cloud-functions-scheduled-time-trigger/). The [Github repo](https://github.com/fireship-io/181-cloud-functions-task-queue) has the code.

## Setup

To start, create a Firebase project. Run `firebase init functions` and use the new project.

Set the environment variables.

```shell
firebase functions:config:set twilio.sid="value" twilio.auth_token="value" twilio.broadcast_number="value" twilio.board_broadcast_number="value" twilio.notify_sid="value" twilio.board_notify_sid="value"
```

## Database

Create a Cloud Firestore Collection called `tasks`, which have this structure:

```json
{ 
    "options": "map",
    "performAt": "timestamp",
    "status": "string",
    "worker": "string"
}
```

The `status` is one of `scheduled|complete|error` where a new task is `scheduled`.

The `worker` is the function name to execute, with the `options` passed in.

The `performAt` value passed is a JavaScript `new Date()` object.

### The index

Create a composite index or the function won't work. 

```yaml
Collection ID: tasks
Fields indexed: status Ascending performAt Ascending
Query Scope: Collection
```

## Workers

The tasks are methods on the `workers` object, which corresponds with the `worker` field above.

### Example worker

The example below would send a Twilio message.

```javascript
sendMessage: async ({ phoneNumber, body }) => {
    const message = await client.messages.create({
        to: phoneNumber,
        from: broadcast_number,
        body: body
    });
    return message.sid;
},
```

To schedule, add a document to the `tasks` collection with the following fields:

```javascript
{
    "status": "scheduled",
    "worker": "sendMessage",
    "performAt": (new Date('December 17, 1995 03:24:00')),
    "options": {
        "phoneNumber": "+15555555555",
        "body": "Hello world."
    }
}
```

## Create Elm app

From the project root folder, execute these commands.

```shell
create-elm-app elm-client
cd elm-client
firebase init hosting
```

When asked, use `elm-client/build` as the public directory, configure as a single-page app.

With this configuration, `elm-app start` will serve the elm page.

To serve from Firebase dev server, compile with `elm-app build` and serve with `firebase serve --only hosting`.

## Add Firebase to Elm app

```shell
npm init -y
npm install firebase
```

Add a `.env` file to the root of `elm-client` (not in `src`).

Follow [these instructions](https://support.google.com/firebase/answer/7015592?authuser=0) to get the `firebaseConfig` values.