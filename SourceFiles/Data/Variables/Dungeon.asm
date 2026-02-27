section .bss
DungeonNumber 		resb 1
Difficulty 			resb 1

CurrentMonster:
	.status: 		resb 1
	.type: 			resb 1
	.x: 			resb 1
	.y: 			resb 1
	.distance_x:	resb 1
	.distance_y:	resb 1
	.range: 		resw 1
	.hit:			resb 1
	
CurrentDungeon:		resb 625