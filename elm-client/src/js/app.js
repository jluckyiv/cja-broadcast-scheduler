import {
  JacksNumber,
  NicolesNumber,
  auth,
  completeTasksQuery,
  deleteTask,
  getAdmins,
  scheduledTasksQuery,
  sendBoardNotification,
  sendMessage,
  sendNotification,
  signIn,
  signOut
} from "./firebase";
import { Elm } from "../Main.elm";

// Setup and helpers
const StorageKey = "AwaitingSignInResponse";
const getSignInResponseStatus = () => localStorage.getItem(StorageKey);
const setSignInResponseStatus = value =>
  localStorage.setItem(StorageKey, value);

const formatDoc = doc => formatPayload(doc.data(), doc.id);
const formatPayload = (task, id) => ({
  id,
  options: task.options,
  performAt: task.performAt.toDate().toLocaleString("en-US"),
  status: task.status,
  worker: task.worker
});

// Elm app
const flags = {
  status: getSignInResponseStatus(),
  localeString: new Date().toLocaleString("en-US")
};

const app = Elm.Main.init({
  node: document.getElementById("app"),
  flags
});

// Ports
const ConsoleError = "ConsoleError";
const ConsoleInfo = "ConsoleInfo";
const ConsoleLog = "ConsoleLog";
const DeleteTask = "DeleteTask";
const GetAdmins = "GetAdmins";
const GotAdmins = "GotAdmins";
const GotComplete = "GotComplete";
const GotScheduled = "GotScheduled";
const Pending = "Pending";
const SendBoardNotification = "SendBoardNotification";
const SendGeneralNotification = "SendGeneralNotification";
const SendJackMessage = "SendJackMessage";
const SendNicoleMessage = "SendNicoleMessage";
const SignIn = "SignIn";
const SignOut = "SignOut";

app.ports.dataFromElm.subscribe(({ tag, payload }) => {
  console.log(tag, payload);
  switch (tag) {
    case ConsoleError:
      console.error(payload);
    case ConsoleInfo:
      console.info(payload);
    case ConsoleLog:
      console.log(payload);
    case DeleteTask:
      deleteTask(payload);
      break;
    case GetAdmins:
      getAdmins()
        .then(data => dataToElm(GotAdmins, data.docs.map(doc => doc.id)))
        .catch(err => console.error(err));
      break;
    case SendJackMessage:
      sendMessage({
        localeString: payload.localeString,
        phoneNumber: JacksNumber,
        body: payload.body
      });
      break;
    case SendNicoleMessage:
      sendMessage({
        localeString: payload.localeString,
        phoneNumber: NicolesNumber,
        body: payload.body
      });
      break;
    case SendGeneralNotification:
      console.log("SendGeneralNotification:", payload);
      sendNotification({
        localeString: payload.localeString,
        body: payload.body
      });
      break;
    case SendBoardNotification:
      console.log("SendBoardNotification:", payload);
      sendBoardNotification({
        localeString: payload.localeString,
        body: payload.body
      });
      break;
    case SignIn:
      setSignInResponseStatus(Pending);
      signIn();
      break;
    case SignOut:
      signOut();
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
auth.onAuthStateChanged(user => {
  setSignInResponseStatus(null);
  if (user) {
    unsubscribeScheduled = scheduledTasksQuery().onSnapshot(
      data => {
        dataToElm(GotScheduled, data.docs.map(doc => formatDoc(doc)));
      },
      error => console.error("Scheduled snapshot error", error)
    );

    unsubscribeComplete = completeTasksQuery().onSnapshot(
      data => {
        dataToElm(GotComplete, data.docs.map(doc => formatDoc(doc)));
      },
      error => console.error("Complete snapshot error", error)
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
