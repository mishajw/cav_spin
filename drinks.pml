mtype = { coin, press1, press2, press3, serve };

int drink = 0;
chan c = [0] of { mtype };

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
	do :: true
		paid: c ! coin ;
		c ! press1 ;
		c ? serve
	od
}

// We don't have to put a mutex on `Machine` to stop the two customers from
// using the machine simultaneously because `Machine` passes through three
// states none of which can be interrupted by the other customer before the
// transaction is finished
proctype Customer2() {
	do :: true
    c ! coin
    if
      :: c ! press2
      :: c ! press3
    fi
    c ? serve
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

