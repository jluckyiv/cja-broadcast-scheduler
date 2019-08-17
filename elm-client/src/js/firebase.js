import * as dotenv from 'dotenv';
import * as firebase from 'firebase/app';
import 'firebase/auth';
import 'firebase/firestore';

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

export default firebase;
export const { firestore } = firebase;
export const auth = firebase.auth();

export const JacksNumber = process.env.JACKS_NUMBER;
export const NicolesNumber = process.env.NICOLES_NUMBER;

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

export const signIn = () => auth.signInWithRedirect(new firebase.auth.GoogleAuthProvider());

export const signOut = () => auth.signOut();

export const tasks = firestore().collection(Tasks);

export const sendMessage = ({ dateString, phoneNumber, body }) => {
  const worker = SendMessage;
  return addTask(dateString, worker, { phoneNumber, body });
};

export const sendBoardMessage = ({ dateString, phoneNumber, body }) => {
  const worker = SendBoardMessage;
  return addTask(dateString, worker, { phoneNumber, body });
};

export const sendNotification = ({ dateString, body }) => {
  const worker = SendNotification;
  return addTask(dateString, worker, { body });
};

export const sendBoardNotification = ({ dateString, body }) => {
  const worker = SendBoardNotification;
  return addTask(dateString, worker, { body });
};

export const deleteTask = id => tasks
  .doc(id)
  .delete()
  .then(() => {
    console.log('Document deleted with id:', id);
  })
  .catch((error) => {
    console.error('Error deleting document:', error);
  });

const addTask = (dateString, worker, options) => {
  const performAt = firestore.Timestamp.fromDate(new Date(dateString));
  return tasks
    .add({
      status: Scheduled,
      performAt,
      worker,
      options,
    })
    .then((docRef) => {
      console.log('Document written with id:', docRef.id);
    })
    .catch((error) => {
      console.error('Error adding document:', error);
    });
};

export const scheduledTasksQuery = () => tasks.where(Status, Equals, Scheduled).orderBy(PerformAt);

export const completeTasksQuery = () => tasks
  .where(Status, Equals, Complete)
  .orderBy(PerformAt, Descending)
  .limit(25);

export const getAdmins = () => firestore()
  .collection(Admins)
  .get();
