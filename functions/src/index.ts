import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();
const db = admin.firestore();

const {
  sid,
  auth_token,
  broadcast_number,
  board_broadcast_number,
  notify_sid,
  board_notify_sid
} = functions.config().twilio;
import * as twilio from "twilio";

const client = twilio(sid, auth_token);
const notifyAll = client.notify.services(notify_sid);
const notifyBoard = client.notify.services(board_notify_sid);

// Optional interface, all worker functions should return Promise.
interface Workers {
  [key: string]: (options: any) => Promise<any>;
}

// Business logic for named tasks. Function name should match worker field on task document.
const workers: Workers = {
  helloWorld: () => db.collection("logs").add({ hello: "world" }),

  sendMessage: async ({ phoneNumber, body }) => {
    const message = await client.messages.create({
      to: phoneNumber,
      from: broadcast_number,
      body: body
    });

    console.log(message.toJSON());

    return message.sid;
  },
  sendBoardMessage: async ({ phoneNumber, body }) => {
    const message = await client.messages.create({
      to: phoneNumber,
      from: board_broadcast_number,
      body: body
    });

    console.log(message.toJSON());

    return message.sid;
  },
  sendNotification: async ({ body }) => {
    // TODO: Typescript requires `tag` to be `string[]`, but sample uses `string`.
    const message = await notifyAll.notifications.create({
      tag: ["all"],
      body: body
    });

    console.log(message.toJSON());

    return message.sid;
  },
  sendBoardNotification: async ({ body }) => {
    // TODO: Typescript requires `tag` to be `string[]`, but sample uses `string`.
    const message = await notifyBoard.notifications.create({
      tag: ["all"],
      body: body
    });

    console.log(message.toJSON());

    return message.sid;
  }
};

export const taskRunner = functions
  .runWith({ memory: "2GB" })
  .pubsub.schedule("* * * * *")
  .onRun(async context => {
    // Consistent timestamp
    const now = admin.firestore.Timestamp.now();

    // Query all documents ready to perform
    const query = db
      .collection("tasks")
      .where("performAt", "<=", now)
      .where("status", "==", "scheduled");

    const tasks = await query.get();

    // Jobs to execute concurrently.
    const jobs: Promise<any>[] = [];

    // Loop over documents and push job.
    tasks.forEach(snapshot => {
      const { worker, options } = snapshot.data();

      const job = workers[worker](options)

        // Update doc with status on success or error
        .then(() => snapshot.ref.update({ status: "complete" }))
        .catch(err => snapshot.ref.update({ status: "error" }));

      jobs.push(job);
    });

    // Execute all jobs concurrently
    return await Promise.all(jobs);
  });
