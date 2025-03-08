import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";

// Configuração do Firebase
const firebaseConfig = {
  apiKey: "AIzaSyB3RQPKIltjUB2KISZY1jBBFM30QgUjG0Y",
  authDomain: "ufabcarona.firebaseapp.com",
  projectId: "ufabcarona",
  storageBucket: "ufabcarona.firebasestorage.app",
  messagingSenderId: "874462379219",
  appId: "1:874462379219:android:b33ac577c27834f9eba826"
};

// Inicializa o Firebase e o Auth
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

export { app, auth };