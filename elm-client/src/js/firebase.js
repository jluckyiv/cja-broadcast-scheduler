import * as dotenv from "dotenv";
import * as firebase from "firebase/app";
import "firebase/auth";
import "firebase/firestore";

dotenv.config({ path: "../.env" });

const config = {
  apiKey: process.env.API_KEY,
  authDomain: process.env.AUTH_DOMAIN,
  databaseURL: process.env.DATABASE_URL,
  projectId: process.env.PROJECT_ID,
  storageBucket: process.env.STORAGE_BUCKET,
  messagingSenderId: process.env.MESSAGING_SENDER_ID,
  appId: process.env.APP_ID
};

firebase.initializeApp(config);

export default firebase;
export const { firestore } = firebase;
export const auth = firebase.auth();

export const JacksNumber = process.env.JACKS_NUMBER;
export const NicolesNumber = process.env.NICOLES_NUMBER;

const Admins = "admins";
const Complete = "complete";
const Descending = "desc";
const Equals = "==";
const PerformAt = "performAt";
const Scheduled = "scheduled";
const SendBoardMessage = "sendBoardMessage";
const SendBoardNotification = "sendBoardNotification";
const SendMessage = "sendMessage";
const SendNotification = "sendNotification";
const Status = "status";
const Tasks = "tasks";

export const signIn = () =>
  auth.signInWithRedirect(new firebase.auth.GoogleAuthProvider());

export const signOut = () => auth.signOut();

export const tasks = firestore().collection(Tasks);

export const sendMessage = ({ localeString, phoneNumber, body }, onError) => {
  const worker = SendMessage;
  return addTask(localeString, worker, { phoneNumber, body }, onError);
};

export const sendBoardMessage = ({
  localeString,
  phoneNumber,
  body,
  onError
}) => {
  const worker = SendBoardMessage;
  return addTask(localeString, worker, { phoneNumber, body, onError });
};

export const sendNotification = ({ localeString, body }, onError) => {
  const worker = SendNotification;
  return addTask(localeString, worker, { body }, onError);
};

export const sendBoardNotification = ({ localeString, body }, onError) => {
  const worker = SendBoardNotification;
  return addTask(localeString, worker, { body }, onError);
};

export const deleteTask = id => tasks.doc(id).delete();

const addTask = (localeString, worker, options) => {
  const performAt = firestore.Timestamp.fromDate(new Date(localeString));
  return tasks.add({
    status: Scheduled,
    performAt,
    worker,
    options
  });
};

export const scheduledTasksQuery = () =>
  tasks.where(Status, Equals, Scheduled).orderBy(PerformAt);

export const completeTasksQuery = () =>
  tasks
    .where(Status, Equals, Complete)
    .orderBy(PerformAt, Descending)
    .limit(25);

export const getAdmins = () =>
  firestore()
    .collection(Admins)
    .get();
