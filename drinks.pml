mtype = { coin, press1, press2, serve };

int drink = 0;
chan c = [0] of { mtype };

proctype Machine() {
	do :: true ->
		c ? coin ;
		if
      :: c ? press1 ; drink = 1
      :: c ? press2 ; drink = 2
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

