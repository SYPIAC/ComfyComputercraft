This hopefully runs the comfy quarry
The quarry runs on two gantry shafts



Notes: 

gantryZ - back - lever/carrot link
gantryX - left - lever/beetroot link
gearshift - right
clutch - front
gantryZ gantryX gearshift result
0       0       0         moveXforward
0		0		1		  moveXback
0		1		0		  moveZback
0		1		1		  moveZforward
1		1		0		  go down
1		1		1		  go up


order of operations:
return to 0 0 0
	gantry up
	toggle gantry power
	moveXback
	moveZback
go to grid location
	moveXforward
	
	
return back timer 1m:50s