import React, { useState } from "react";
// FROM INDEX.JS
import { token, canisterId, createActor } from "../../../declarations/token";
import { AuthClient } from "@dfinity/auth-client";

function Faucet(props) {
  const [isDisabled, setDisable] = useState(false);
  const [buttonText, setButtonText] = useState("Gimme gimme");

  async function handleClick(event) {
    setDisable(true);
    // ! --------------------- TO MAKE THIS ALL WORK: LIVE SESSION ... > DEPLOY PROJECT onto the live internet computer blockchain
    const authClient = await AuthClient.create();
    // identity from the authentication process
    // * IDENTITY OBJECT CONTAINS: principalid of the loggedInUser : can be converted to string
    const identity = await authClient.getIdentity();

    // use this identity to create a actor
    // canisterid = env variable that contains the principal id of the canister / agent options (supply identity)

    // CREATE AN INSTANCE OF THE ACTOR but with specified identity : principal id ?
    const authenticatedCanister = createActor(canisterId, {
      // options we want to set
      agentOptions: {
        identity,
      },
    });

    // so in the authenticatedCanister the msg.caller will be the principal id of the authenticated user
    // now authenticated user gets transfered the tokens
    const result = await authenticatedCanister.payOut();
    setButtonText(result);
  }

  return (
    <div className="blue window">
      <h2>
        <span role="img" aria-label="tap emoji">
          🚰
        </span>
        Faucet
      </h2>
      <label>
        Get your free ARI tokens here! Claim 10,000 ARI tokens to{" "}
        {props.userPrincipal}.
      </label>
      <p className="trade-buttons">
        <button id="btn-payout" onClick={handleClick} disabled={isDisabled}>
          {buttonText}
        </button>
      </p>
    </div>
  );
}

export default Faucet;
