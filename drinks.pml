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

#define a (Machine@chosen)

ltl prop1 { <> a }

