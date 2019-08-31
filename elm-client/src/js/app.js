import { Api } from './api';
import { Elm } from '../Main.elm';

// Setup
const logSuccess = message => dataToElm(tag.GotFirebaseSuccess, message);
const logError = message => dataToElm(tag.GotFirebaseError, message);

const StorageKey = 'AwaitingSignInResponse';
const setSignInResponseStatus = value => localStorage.setItem(StorageKey, value);

// Elm app
const flags = {
  status: localStorage.getItem(StorageKey),
  localeString: new Date().toLocaleString('en-US'),
};

const app = Elm.Main.init({
  node: document.getElementById('app'),
  flags,
});

// Ports
const dataToElm = (tag, payload) => {
  app.ports.dataToElm.send({ tag, payload });
};

app.ports.dataFromElm.subscribe(({ tag, payload }) => {
  const fun = api[tag];
  if (fun && typeof fun === 'function') {
    fun(payload);
  } else {
    logError(`Unrecognized tag: ${tag}, with payload:`, payload);
  }
});

// Api
const tag = {
  GotAdmins: 'GotAdmins',
  GotComplete: 'GotComplete',
  GotFirebaseError: 'GotFirebaseError',
  GotFirebaseSuccess: 'GotFirebaseSuccess',
  GotScheduled: 'GotScheduled',
  Pending: 'Pending',
};

const api = {
  ConsoleError: payload => console.error(payload),
  ConsoleInfo: payload => console.info(payload),
  ConsoleLog: payload => console.log(payload),
  DeleteTask: (payload) => {
    Api.deleteTask(payload)
      .then(() => {
        logSuccess(`Firestore document deleted: ${payload}.`);
      })
      .catch((error) => {
        logError(`Error deleting Firestore document ${payload} with error ${error}.`);
      });
  },
  GetAdmins: () => {
    Api.getAdmins()
      .then(data => dataToElm(tag.GotAdmins, data.docs.map(doc => doc.id)))
      .catch((error) => {
        logError(`Error fetching admins from Firestore: ${error}.`);
      });
  },
  SendBoardNotification: (payload) => {
    Api.sendBoardNotification({
      localeString: payload.localeString,
      body: payload.body,
    })
      .then((docRef) => {
        logSuccess(`Firestore document written: ${docRef.id}.`);
      })
      .catch((error) => {
        logError(`Error adding Firestore document: ${error}.`);
      });
  },
  SendGeneralNotification: (payload) => {
    Api.sendNotification({
      localeString: payload.localeString,
      body: payload.body,
    })
      .then((docRef) => {
        logSuccess(`Firestore document written: ${docRef.id}.`);
      })
      .catch((error) => {
        logError(`Error adding Firestore document: ${error}.`);
      });
  },
  SendJackMessage: (payload) => {
    Api.sendMessage({
      localeString: payload.localeString,
      phoneNumber: Api.JacksNumber,
      body: payload.body,
    })
      .then((docRef) => {
        logSuccess(`Firestore document written: ${docRef.id}.`);
      })
      .catch((error) => {
        logError(`Error adding Firestore document: ${error}.`);
      });
  },
  SendNicoleMessage: (payload) => {
    sendMessage({
      localeString: payload.localeString,
      phoneNumber: Api.NicolesNumber,
      body: payload.body,
    })
      .then((docRef) => {
        logSuccess(`Firestore document written: ${docRef.id}.`);
      })
      .catch((error) => {
        logError(`Error adding Firestore document: ${error}.`);
      });
  },
  SignIn: () => {
    setSignInResponseStatus(tag.Pending);
    Api.signIn();
  },
  SignOut: () => {
    Api.signOut();
  },
};

// Listeners
let unsubscribeScheduled;
let unsubscribeComplete;

Api.auth.onAuthStateChanged((user) => {
  setSignInResponseStatus(null);
  if (user) {
    unsubscribeScheduled = Api.scheduledTasksQuery().onSnapshot(
      (data) => {
        dataToElm(tag.GotScheduled, data.docs.map(doc => formatDoc(doc)));
      },
      error => console.error('Scheduled snapshot error', error),
    );

    unsubscribeComplete = Api.completeTasksQuery().onSnapshot(
      (data) => {
        dataToElm(tag.GotComplete, data.docs.map(doc => formatDoc(doc)));
      },
      error => console.error('Complete snapshot error', error),
    );
  } else {
    if (unsubscribeComplete) {
      unsubscribeComplete();
    }
    if (unsubscribeScheduled) {
      unsubscribeScheduled();
    }
  }
  app.ports.authStateChanged.send(user);
});

// Helpers
const formatDoc = doc => formatPayload(doc.data(), doc.id);
const formatPayload = (task, id) => ({
  id,
  options: task.options,
  performAt: task.performAt.toDate().toLocaleString('en-US'),
  status: task.status,
  worker: task.worker,
});
