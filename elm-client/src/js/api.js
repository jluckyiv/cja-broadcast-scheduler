import * as dotenv from 'dotenv';
import * as firebase from 'firebase/app';
import 'firebase/auth';
import 'firebase/firestore';

// Config

dotenv.config({ path: '../.env' });

const config = {
  apiKey: process.env.API_KEY,
  authDomain: process.env.AUTH_DOMAIN,
  databaseURL: process.env.DATABASE_URL,
  projectId: process.env.PROJECT_ID,
  storageBucket: process.env.STORAGE_BUCKET,
  messagingSenderId: process.env.MESSAGING_SENDER_ID,
  appId: process.env.APP_ID,
};

firebase.initializeApp(config);

const { firestore } = firebase;

// Helpers

const Admins = 'admins';
const Complete = 'complete';
const Descending = 'desc';
const Equals = '==';
const PerformAt = 'performAt';
const Scheduled = 'scheduled';
const SendBoardMessage = 'sendBoardMessage';
const SendBoardNotification = 'sendBoardNotification';
const SendMessage = 'sendMessage';
const SendNotification = 'sendNotification';
const Status = 'status';
const Tasks = 'tasks';

const tasks = firestore().collection(Tasks);

const addTask = (localeString, worker, options) => {
  const performAt = firestore.Timestamp.fromDate(new Date(localeString));
  return tasks.add({
    status: Scheduled,
    performAt,
    worker,
    options,
  });
};

const provider = new firebase.auth.GoogleAuthProvider();

// API

const JacksNumber = process.env.JACKS_NUMBER;
const NicolesNumber = process.env.NICOLES_NUMBER;

const auth = firebase.auth();

const completeTasksQuery = () => tasks
  .where(Status, Equals, Complete)
  .orderBy(PerformAt, Descending)
  .limit(25);

const deleteTask = id => tasks.doc(id).delete();

const getAdmins = () => firestore()
  .collection(Admins)
  .get();

const scheduledTasksQuery = () => tasks.where(Status, Equals, Scheduled).orderBy(PerformAt);

const sendBoardMessage = ({ localeString, phoneNumber, body }) => addTask(localeString, SendBoardMessage, { phoneNumber, body });

const sendBoardNotification = ({ localeString, body }) => addTask(localeString, SendBoardNotification, { body });

const sendMessage = ({ localeString, phoneNumber, body }) => addTask(localeString, SendMessage, { phoneNumber, body });

const sendNotification = ({ localeString, body }) => addTask(localeString, SendNotification, { body });

const signIn = () => auth.signInWithRedirect(provider);

const signOut = () => auth.signOut();

export const Api = {
  JacksNumber,
  NicolesNumber,
  auth,
  completeTasksQuery,
  deleteTask,
  getAdmins,
  scheduledTasksQuery,
  sendBoardMessage,
  sendBoardNotification,
  sendMessage,
  sendNotification,
  signIn,
  signOut,
};
