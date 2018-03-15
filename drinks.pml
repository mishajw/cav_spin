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

proctype Customer() {
	do :: true
		c ! coin ;
		c ! press1 ;
		c ? serve
	od
}

init {
	run Machine() ; run Customer()
}

// `Machine@chosen` is set to true when the machine has finished serving a drink
// i.e. a `coin` and a `press*` command was recieved
ltl prop1 { <> Machine@chosen }

// Checks if a drink is chosen infinitely often
ltl q1d { [] <> Machine@chosen }

