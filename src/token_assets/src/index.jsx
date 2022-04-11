import ReactDOM from "react-dom";
import React from "react";
import App from "./components/App";
import { AuthClient } from "@dfinity/auth-client";

const init = async () => {
  // ---------- TRIGGER FRONTEND LOGIN -------------
  // authClient object
  const authClient = await AuthClient.create();

  // ----------  AUTHENTICATED ---------
  // * check if we're already authenticated / information is stored in the cache - MEMORY
  if (await authClient.isAuthenticated()) {
    handleAuthenticated(authClient);
  } else {
    // ---------- NOT AUTHENTICATED ---------
    await authClient.login({
      // *  WHO THE IDENTITY PROVIDER IS : dfinity identity service on internet computer
      // provide the frontend for the login purposes
      // ! REDIRECT
      identityProvider: "https://identity.ic0.app/#authorize",
      // what should happen once the login was successful
      onSuccess: () => {
        // Move user to main app
        handleAuthenticated(authClient);
      },
    });
  }

  async function handleAuthenticated(authClient) {
    // * NAVIGATE USER TO APP
    const identity = authClient.getIdentity();
    // convert that principal which is in array form to string
    const userPrincipal = identity._principal.toString();
    ReactDOM.render(
      <App loggedInPrincipal={userPrincipal} />,
      document.getElementById("root")
    );
  }
};

init();
