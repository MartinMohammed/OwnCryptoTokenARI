import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter  "mo:base/Iter";

// --------------- ASSIGN AMOUNT OF TOKENS TO A USER - OWNER ------------
actor Token {
    let owner : Principal = Principal.fromText("iijjg-t5hrn-pefjo-pmkp6-r5gma-45kuv-kcfcn-kdp7l-t4v47-3cpwb-iae");
    // mint this amount of tokens / limited
    let totalSupply : Nat = 1000000000;
    // Token Name
    let symbol : Text = "ARI";

    // * -----------------------------  CREATE OUR PERSISTANT LEDGER -----------------------------
    /* 
    * Array "our temporary variable for our ledger data"
    ! DISADVANTAGE: SERIALIZED DATA TYPE = must be iterated to find given item = expensive : computation 
    * ADVATAGE: STABLE DATATYPE : ORTHOGONAL PERSITANT
    WHAT IS INISIDE: Tuples (Principal, Nat)
    */
    private stable var balanceEntries: [(Principal, Nat)] = [];


    /* 
    * HASHMAP (NO EXPLICIT DATATYPE REQUIRED) similar to dictionary in JS > mapping key to value (key gets hashed) : 
    * store it into a location in the memory of the computer 
    ! DISADVANTAGE: NON-STABLE TYPE

    WHAT IS INSIDE: Key is a principal (id of user / canister) and the amount 
    INIT HASHMAP> 3 ARGS: (init size of the hashmap, how to check for the equality of keys, how it should hash those keys)
    in order to equalize: the key that we give to our balance matches the principle that is stored (reference by value?) 
    */
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);

    // * ----------- (INITIAL DEPLOY = INITIAL PHASE) ≠ CANISTER UPGRADE  --------
    if(balances.size() < 1){      
        // insert the value v at key k. Overwrites an existing entry with key k.
        balances.put(owner, totalSupply);
    };

    // * passing the id of the person we're checking
    // ! expected format: principal "iijjg-t5hrn-pefjo-pmkp6-r5gma-45kuv-kcfcn-kdp7l-t4v47-3cpwb-iae"
    public query func balanceOf(who: Principal) : async Nat{
        /* Option Datatype: ?Nat (typesafe null)
        * Switch case statement on Hashmap: Check if result is either constructed null or a value (with retained datatype)
        case (matching value) returnValue for balance 
        */
        let balance : Nat = switch (balances.get(who)){
            // if entity is not in the hashmap / ledger 
            case null 0;
            // ? signalizes for a optional datatype
            case (?result) result; 
        };
        return balance; 
    };

    public query func getSymbol() : async Text{
        return symbol; 
    };

    // --------------------------- FAUCET -----------------------------
    /* ABOUT MSG.CALLER / SHARED FUNCTION 
    * shared function / allows methods declared inside an actor to be called by other actors. 
    * public > by default shared

    ! if browser (frontend) calls => anonymous caller id.
    msg.caller depends on who calls the funciton 
    ! advantage we can identify the principal ID of the entity that called a particular function.
    * msg.caller => my principal id when i call function from terminal in the panel 
    * who is the caller when a functions gets called by a function within the same actor - canister / actor id 
    */
    public shared(msg) func payOut() : async Text{
        // only gift user 10,000 ARI if he hasn't got already = not in the hashmap 
        // if key does not exist => return null else ?Type option
        Debug.print(debug_show(msg.caller));
        if(balances.get(msg.caller) == null){
            let amount = 10000; 
            let result = await transfer(msg.caller, amount);
            return result;
        } else{
            return "Already Claimed";
        };
    };

    // ------------------------ ONLY METHOD THAT IS MODIFYING THE BALANCES HASHMAP -------------
    public shared(msg) func transfer(to: Principal, amount: Nat) : async Text {
        /* 
            1. Transfer from A to B = Substract from A the amount and add it to B 
        */
        let fromBalance = await balanceOf(msg.caller); 
        if(fromBalance > amount){
            let newFromBalance : Nat = fromBalance - amount; 
            // overrwrite the key / replace entry 
            balances.put(msg.caller, newFromBalance);

            // if user/ entity does not exist his balance will be 0; 
            let toBalance = await balanceOf(to); 
            let newToBalance = toBalance + amount; 

            // if user/ entity does not exist PUT HIM NEW INTO LEDGER with added balance 
            balances.put(to, newToBalance); 
            return "Sucess"; 
        }else{
            return "Insufficent Funds"; 
        };
    };


    // --------------- SOLVING ISSUE WITH PERSISTANCE ------------
    // * -- similar to lifecycle methods of a application 
    // *  before code gets upgraded, we transfer the data into the tmp. variable 
    system func preupgrade(){
        // ! Iter.toArray() iterates through a iterable and returns an array 
        // entries method will iterate through the hasmap and return a Iterable for toArray()
        // after upgrade: balances will be wiped out to intial value 
        balanceEntries := Iter.toArray(balances.entries());
    };
    // * after upgrade of canister, we transfer the data back into the hashmap 
    system func postupgrade(){
        // ! <Array>.val() is a way to get a Iter datatype back from the tuple datatypes 
        // + initializing parameters
        balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);

        // * empty balances / owner not assigned the full amount of tokens
        if(balances.size() < 1){      
            // insert the value v at key k. Overwrites an existing entry with key k.
            balances.put(owner, totalSupply);
        }
    };
}