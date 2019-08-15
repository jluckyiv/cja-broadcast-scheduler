import {
  JacksNumber,
  NicolesNumber,
  admins,
  auth,
  completeTasksQuery,
  deleteTask,
  firestore,
  getAdmins,
  gotCompleteTasks,
  scheduledTasksQuery,
  sendBoardNotification,
  sendMessage,
  sendNotification,
  signIn,
  signOut,
  tasks,
} from './firebase';
import { Elm } from '../Main.elm';

// Setup and helpers
const StorageKey = 'AwaitingSignInResponse';
const getSignInResponseStatus = () => localStorage.getItem(StorageKey);
const setSignInResponseStatus = value => localStorage.setItem(StorageKey, value);

const formatDoc = doc => formatPayload(doc.data(), doc.id);
const formatPayload = (task, id) => ({
  id,
  options: task.options,
  performAt: task.performAt.toDate().toLocaleString('en-US'),
  status: task.status,
  worker: task.worker,
});

// Elm app
const flags = {
  status: getSignInResponseStatus(),
  dateString: new Date().toLocaleString('en-US'),
};

const app = Elm.Main.init({
  node: document.getElementById('app'),
  flags,
});

// Ports
const DeleteTask = 'DeleteTask';
const GetAdmins = 'GetAdmins';
const GetComplete = 'GetComplete';
const GetScheduled = 'GetScheduled';
const GotAdmins = 'GotAdmins';
const GotComplete = 'GotComplete';
const GotScheduled = 'GotScheduled';
const Login = 'Login';
const Logout = 'Logout';
const Pending = 'Pending';
const SendJackMessage = 'SendJackMessage';
const SendNicoleMessage = 'SendNicoleMessage';
const SendBoardNotification = 'SendBoardNotification';
const SendGeneralNotification = 'SendGeneralNotification';

app.ports.dataFromElm.subscribe(({ tag, payload }) => {
  switch (tag) {
    case GetAdmins:
      getAdmins()
        .then(data => dataToElm(GotAdmins, data.docs.map(doc => doc.id)))
        .catch(err => console.error(err));
      break;
    case Login:
      setSignInResponseStatus(Pending);
      signIn();
      break;
    case Logout:
      signOut();
      break;
    case SendJackMessage:
      sendMessage({
        dateString: payload.dateString,
        phoneNumber: JacksNumber,
        body: payload.body,
      });
      break;
    case SendNicoleMessage:
      sendMessage({
        dateString: payload.dateString,
        phoneNumber: NicolesNumber,
        body: payload.body,
      });
      break;
    case SendGeneralNotification:
      console.log('SendGeneralNotification:', payload);
      sendNotification({
        dateString: payload.dateString,
        body: payload.body,
      });
      break;
    case SendBoardNotification:
      console.log('SendBoardNotification:', payload);
      sendBoardNotification({
        dateString: payload.dateString,
        body: payload.body,
      });
      break;
    case DeleteTask:
      deleteTask(payload);
      break;
    default:
      console.error(`Unrecognized tag: ${tag}, with payload:`, payload);
      break;
  }
});

const dataToElm = (tag, payload) => {
  app.ports.dataToElm.send({ tag, payload });
};

let unsubscribeScheduled;
let unsubscribeComplete;
auth.onAuthStateChanged((user) => {
  setSignInResponseStatus(null);
  if (user) {
    unsubscribeScheduled = scheduledTasksQuery().onSnapshot(
      (data) => {
        dataToElm(GotScheduled, data.docs.map(doc => formatDoc(doc)));
      },
      error => console.error('Scheduled snapshot error', error),
    );

    unsubscribeComplete = completeTasksQuery().onSnapshot(
      (data) => {
        dataToElm(GotComplete, data.docs.map(doc => formatDoc(doc)));
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
