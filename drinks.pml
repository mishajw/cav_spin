#define CUSTOMER_BUDGET 5
mtype = { coin, press1, press2, press3, serve };

int drink = 0;
chan c = [0] of { mtype };
chan coin_chan = [0] of { int };

proctype Machine() {
	do :: true ->
		c ? coin ;
		if
      :: c ? press1 ; drink = 1
      :: c ? press2 ; drink = 2
      // If drink 3 is chosen, non-deterministically chose drink 2 or 3
      :: c ? press3 ; drink = 2
      :: c ? press3 ; drink = 3
		fi ;
		chosen: c ! serve
	od
}

proctype Customer1() {
  int num_coins = CUSTOMER_BUDGET;
	do :: true
    if
    // Either buy a drink...
    :: num_coins > 0 ->
      // Pay for the drink
      c ! coin;
      paid: num_coins = num_coins - 1;
      // Always request drink 1
      c ! press1;
      c ? serve;
    // ..or recieve a coin from `Customer2`
    ::
      coin_chan ? 1;
      num_coins = num_coins + 1;
    fi
	od
}

// We don't have to put a mutex on `Machine` to stop the two customers from
// using the machine simultaneously because `Machine` passes through three
// states none of which can be interrupted by the other customer before the
// transaction is finished
proctype Customer2() {
  int num_coins = CUSTOMER_BUDGET
	do :: true
    if
    // Either buy a drink...
    :: num_coins > 0 ->
      // Pay for the drink
      c ! coin;
      paid: num_coins = num_coins - 1;
      if
        // Either request drink 2 or 3
        :: c ! press2;
        :: c ! press3;
      fi
      c ? serve
    // ...or send a coin to `Customer1`
    :: num_coins > 0 ->
      coin_chan ! 1;
      num_coins = num_coins - 1;
    fi
	od
}

init {
	run Machine() ; run Customer1() ; run Customer2()
}

// `Machine@chosen` is set to true when the machine has finished serving a drink
// i.e. a `coin` and a `press*` command was recieved
ltl prop1 { <> Machine@chosen }

// Checks if a drink is chosen infinitely often
ltl q1d { [] <> Machine@chosen }

// Checks if when a customer pays, a drink is eventually chosen
ltl q1e { [] (Customer1@paid -> (<> Machine@chosen)) }

// Checks if drink 1 is chosen infinitely often (doesn't evaluate to true)
ltl q2a { [] <> (Machine@chosen && drink == 1) }

// Used to show a cycle where drink 1 is chosen infinitely often
ltl q2b { <> [] !(Machine@chosen && drink == 1) }

// Used to show a cycle where both customers pay infinitely often
ltl q3a { (<> [] !Customer1@paid) || (<> [] !Customer2@paid) }

// Used to show a case where the customer 1 has all the coins
ltl q3b { [] ! (Customer1:num_coins == CUSTOMER_BUDGET * 2) }

