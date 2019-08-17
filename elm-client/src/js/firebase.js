import * as dotenv from 'dotenv';
import * as firebase from 'firebase/app';
import 'firebase/auth';
import 'firebase/firestore';

dotenv.config();

const config = {
  apiKey: process.env.API_KEY,
  authDomain: process.env.AUTH_DOMAIN,
  databaseURL: process.env.DATABASE_URL,
  projectId: process.env.PROJECT_ID,
  storageBucket: process.env.STORAGE_BUCKET,
  messagingSenderId: process.env.MESSAGING_SENDER_ID,
  appId: process.env.APP_ID,
};

export const JacksNumber = process.env.JACKS_NUMBER;
export const NicolesNumber = process.env.NICOLES_NUMBER;

firebase.initializeApp(config);

export default firebase;
export const { firestore } = firebase;

export const auth = firebase.auth();

export const signIn = () => auth.signInWithRedirect(new firebase.auth.GoogleAuthProvider());

export const signOut = () => auth.signOut();

export const tasks = firestore().collection('tasks');

export const sendMessage = ({ dateString, phoneNumber, body }) => {
  const worker = 'sendMessage';
  return addTask(dateString, worker, { phoneNumber, body });
};

export const sendBoardMessage = ({ dateString, phoneNumber, body }) => {
  const worker = 'sendBoardMessage';
  return addTask(dateString, worker, { phoneNumber, body });
};

export const sendNotification = ({ dateString, body }) => {
  const worker = 'sendNotification';
  return addTask(dateString, worker, { body });
};

export const sendBoardNotification = ({ dateString, body }) => {
  const worker = 'sendBoardNotification';
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
      status: 'scheduled',
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

export const scheduledTasksQuery = () => tasks.where('status', '==', 'scheduled').orderBy('performAt');

export const completeTasksQuery = () => tasks
  .where('status', '==', 'complete')
  .orderBy('performAt', 'desc')
  .limit(25);

export const getAdmins = () => firestore()
  .collection('admins')
  .get();
