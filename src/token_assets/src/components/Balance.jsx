import React, { useState } from "react";

import { token } from "../../../declarations/token";
// import the classes from mutoku on the front end
// this comes from javascript npm package => @ denotes a scoped package, way of grouping similar packages together
import { Principal } from "@dfinity/principal";

function Balance() {
  const [inputValue, setInput] = useState("");
  const [balanceResult, setBalance] = useState("");
  const [cryptoSymbol, setCryptoSymbol] = useState("");
  const [isHidden, setHidden] = useState(true);

  async function handleClick() {
    // converting to Principal Type so that our method can understand / take the input value as arg.
    // * same methods like in motoku module/ classes but only written in javaScript
    const principal = Principal.fromText(inputValue);
    const balance = await token.balanceOf(principal);
    const cryptoSymbol = await token.getSymbol();
    // change nat to string => number to formatted number
    setBalance(balance.toLocaleString());
    // or setCryptoSymbol(await token.getSymbol());
    setCryptoSymbol(cryptoSymbol);
    setHidden(false);
  }

  return (
    <div className="window white">
      <label>Check account token balance:</label>
      <p>
        <input
          id="balance-principal-id"
          type="text"
          placeholder="Enter a Principal ID"
          // single source of truth
          value={inputValue}
          onChange={(e) => setInput(e.target.value)}
        />
      </p>
      <p className="trade-buttons">
        <button id="btn-request-balance" onClick={handleClick}>
          Check Balance
        </button>
      </p>
      <p hidden={isHidden}>
        This account has a balance of: {balanceResult}
        {cryptoSymbol}.
      </p>
    </div>
  );
}

export default Balance;
