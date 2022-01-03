.global _start

x_limit: .word 319		// 319 > 255 cannot be used directly in MOV and CMP
grid_limit: .word 263
last_line: .word 259

background_color: .word 0x42F4
grid_color: .word 0xB61C

data: .space 4, 0xff
grid: .space 36, 0x0f  // used to store 1 or 2 to indicate the player

// VGA pixel buffer
.equ PIXEL_MEMORY, 0xC8000000
// Character Buffer
.equ CHAR_MEMORY, 0xC9000000
// PS/2 Port
.equ PS2_MEMORY, 0xFF200100

_start:

	PUSH {LR}
	BL VGA_clear_pixelbuff_ASM
	POP {LR}

	PUSH {LR}
	BL VGA_clear_charbuff_ASM
	POP {LR}
	
	PUSH {R0, R1, R2, R3, LR}
	BL VGA_fill_ASM
	POP {R0, R1, R2, R3, LR}
	
	PUSH {R0, R1, R2, R3, LR}
	BL draw_grid_ASM
	POP {R0, R1, R2, R3, LR}

	
// read PS2 and wait for 0
wait:
	LDR R0, =data		// R0 holds the desired address to store ps2 data
	PUSH {LR}
	BL read_PS2_data_ASM
	POP {LR}
	
	CMP R0, #0
	BEQ wait			// if RVALID is 0, data is not ready, continue to read
	
	LDRB R0, data		// load the data value into R0
	CMP R0, #0x45		// 45 is MAKE value for 0 on keyboard
	BNE wait			// if data is not 0 (start signal), read again
	BEQ begin			// otherwise, game begins
	
initialize:
// initialize grid
	PUSH {LR}
	BL VGA_clear_pixelbuff_ASM
	POP {LR}

	PUSH {LR}
	BL VGA_clear_charbuff_ASM
	POP {LR}
	
	PUSH {R0, R1, R2, R3, LR}
	BL VGA_fill_ASM
	POP {R0, R1, R2, R3, LR}
	
	PUSH {R0, R1, R2, R3, LR}
	BL draw_grid_ASM
	POP {R0, R1, R2, R3, LR}
	
	// reset the grid array
	PUSH {R1, R2}
	MOV R1, #0x0f
	LDR R2, =grid
	STR R1, [R2]
	STR R1, [R2, #4]
	STR R1, [R2, #8]
	STR R1, [R2, #12]
	STR R1, [R2, #16]
	STR R1, [R2, #20]
	STR R1, [R2, #24]
	STR R1, [R2, #28]
	STR R1, [R2, #32]	
	POP {R1, R2}
	
	MOV R10, #0			// R10 keeps count of #turns
	MOV R11, #0			// R11 keeps track of the current player
						// by default player-1 makes the first move
begin:
	MOV R0, R11
	
	PUSH {LR}
	BL Player_turn_ASM	// display turn 
	POP {LR}
	
read:
	LDR R0, =data		// R0 holds the desired address to store ps2 data
	PUSH {LR}
	BL read_PS2_data_ASM
	POP {LR}
	
	CMP R0, #0
	BEQ read			// if RVALID is 0, data is not ready, continue to read
	
	LDRB R0, data		// load the data value into R0
	
	CMP R0, #0x45
	BEQ initialize		// press 0 to restart the game at any time
	
	grid1:
	CMP R0, #0x16		// press 1
	BNE grid2
	PUSH {R0, R1, R2, R3}
	LDR R2, =grid
	LDRB R3, [R2]
	CMP R3, #0xf
	BNE read			// cannot mark a space that already contains something
	STR R11, [R2]		// store the current player into the grid array
	MOV R0, #92
	MOV R1, #68
	CMP R11, #0			// if the current player is player-1
	BNE c1
	s1:
	PUSH {LR}
	BL draw_square_ASM
	POP {LR}
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	c1:
	PUSH {LR}
	BL draw_plus_ASM
	POP {LR}	
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
		
	grid2:
	CMP R0, #0x1e		// press 2
	BNE grid3
	PUSH {R0, R1, R2, R3}
	LDR R2, =grid
	LDRB R3, [R2, #4]
	CMP R3, #0xf
	BNE read			// cannot mark a space that already contains something
	STR R11, [R2, #4]		// store the current player into the grid array
	MOV R0, #159
	MOV R1, #68
	CMP R11, #0			// if the current player is player-1
	BNE c2
	s2:
	PUSH {LR}
	BL draw_square_ASM
	POP {LR}
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	c2:
	PUSH {LR}
	BL draw_plus_ASM
	POP {LR}	
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	
	grid3:
	CMP R0, #0x26		// 3
	BNE grid4
	PUSH {R0, R1, R2, R3}
	LDR R2, =grid
	LDRB R3, [R2, #8]
	CMP R3, #0xf
	BNE read			// cannot mark a space that already contains something
	STR R11, [R2, #8]		// store the current player into the grid array
	MOV R0, #227
	MOV R1, #68
	CMP R11, #0			// if the current player is player-1
	BNE c3
	s3:
	PUSH {LR}
	BL draw_square_ASM
	POP {LR}
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	c3:
	PUSH {LR}
	BL draw_plus_ASM
	POP {LR}	
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	
	grid4:
	CMP R0, #0x25		// 4
	BNE grid5
	PUSH {R0, R1, R2, R3}
	LDR R2, =grid
	LDRB R3, [R2, #12]
	CMP R3, #0xf
	BNE read			// cannot mark a space that already contains something
	STR R11, [R2, #12]		// store the current player into the grid array
	MOV R0, #92
	MOV R1, #135
	CMP R11, #0			// if the current player is player-1
	BNE c4
	s4:
	PUSH {LR}
	BL draw_square_ASM
	POP {LR}
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	c4:
	PUSH {LR}
	BL draw_plus_ASM
	POP {LR}	
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	
	grid5:
	CMP R0, #0x2e		// 5
	BNE grid6
	PUSH {R0, R1, R2, R3}
	LDR R2, =grid
	LDRB R3, [R2, #16]
	CMP R3, #0xf
	BNE read			// cannot mark a space that already contains something
	STR R11, [R2, #16]		// store the current player into the grid array
	MOV R0, #159
	MOV R1, #135
	CMP R11, #0			// if the current player is player-1
	BNE c5
	s5:
	PUSH {LR}
	BL draw_square_ASM
	POP {LR}
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	c5:
	PUSH {LR}
	BL draw_plus_ASM
	POP {LR}	
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	
	grid6:
	CMP R0, #0x36		// 6
	BNE grid7
	PUSH {R0, R1, R2, R3}
	LDR R2, =grid
	LDRB R3, [R2, #20]
	CMP R3, #0xf
	BNE read			// cannot mark a space that already contains something
	STR R11, [R2, #20]		// store the current player into the grid array
	MOV R0, #227
	MOV R1, #135
	CMP R11, #0			// if the current player is player-1
	BNE c6
	s6:
	PUSH {LR}
	BL draw_square_ASM
	POP {LR}
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	c6:
	PUSH {LR}
	BL draw_plus_ASM
	POP {LR}	
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	
	grid7:
	CMP R0, #0x3d		// 7
	BNE grid8
	PUSH {R0, R1, R2, R3}
	LDR R2, =grid
	LDRB R3, [R2, #24]
	CMP R3, #0xf
	BNE read			// cannot mark a space that already contains something
	STR R11, [R2, #24]		// store the current player into the grid array
	MOV R0, #92
	MOV R1, #203
	CMP R11, #0			// if the current player is player-1
	BNE c7
	s7:
	PUSH {LR}
	BL draw_square_ASM
	POP {LR}
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	c7:
	PUSH {LR}
	BL draw_plus_ASM
	POP {LR}	
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	
	grid8:
	CMP R0, #0x3e		// 8
	BNE grid9
	PUSH {R0, R1, R2, R3}
	LDR R2, =grid
	LDRB R3, [R2, #28]
	CMP R3, #0xf
	BNE read			// cannot mark a space that already contains something
	STR R11, [R2, #28]		// store the current player into the grid array
	MOV R0, #159
	MOV R1, #203
	CMP R11, #0			// if the current player is player-1
	BNE c8
	s8:
	PUSH {LR}
	BL draw_square_ASM
	POP {LR}
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	c8:
	PUSH {LR}
	BL draw_plus_ASM
	POP {LR}	
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	
	grid9:
	CMP R0, #0x46		// 9
	BNE read
	PUSH {R0, R1, R2, R3}
	LDR R2, =grid
	LDRB R3, [R2, #32]
	CMP R3, #0xf
	BNE read			// cannot mark a space that already contains something
	STR R11, [R2, #32]		// store the current player into the grid array
	MOV R0, #227
	MOV R1, #203
	CMP R11, #0			// if the current player is player-1
	BNE c9
	s9:
	PUSH {LR}
	BL draw_square_ASM
	POP {LR}
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	c9:
	PUSH {LR}
	BL draw_plus_ASM
	POP {LR}	
	POP {R0, R1, R2, R3}
	ADD R10, #1
	B check_winner
	
check_winner:
	PUSH {LR}
	BL find_winner		// R0 now holds the winner or #2
	POP {LR}
	CMP R0, #0
	BEQ player_win
	CMP R0, #1
	BEQ player_win
	B switch	
	
switch:		
	CMP R10, #9			
	BGE draw			
	
	CMP R11, #0			// if the current player is player-1
	MOVEQ R11, #1		// the player for next turn is player-2
	BEQ begin
	CMP R11, #1			// if the current player is player-2
	MOVEQ R11, #0		// the player for next turn is player-1
	BEQ begin
	
	B end
	
end: B end

draw:
	PUSH {LR}
	BL VGA_clear_charbuff_ASM
	POP {LR}
	MOVGE R0, #2		// if turn goes to 9 or over, set R0 to something else than 0 and 1
	PUSH {LR}
	BL result_ASM		// declare the result
	POP {LR}
	B wait				// wait for restart
	
player_win:
	PUSH {LR}
	BL result_ASM
	POP {LR}
	B wait	

find_winner:
// return R0 storing the winner
// 0 : player-1
// 1 : player-2
// 2 : no winner
	PUSH {R1,R2,R3,R4,R5,R6,R7,R8,R9}
	LDR R0, =grid		// access the grid array
	LDRB R1, [R0]		// R1 stores the player of the first box
	LDRB R2, [R0, #4]	// R2 stores the player of the second box
	LDRB R3, [R0, #8]	// ...
	LDRB R4, [R0, #12]
	LDRB R5, [R0, #16]
	LDRB R6, [R0, #20]
	LDRB R7, [R0, #24]
	LDRB R8, [R0, #28]
	LDRB R9, [R0, #32]
	// check winning conditions: 8 in total
	// checking order:
	// 123->147->159->258->357->369->456->789
b1:	CMP R1, R11			// if player-1 fill the first box
	BEQ b12				// check 123
						// else start from the second box and check 258
b2:	CMP R2, R11
	BEQ b25				// check 258
						// else check 357 or 369
b3:	CMP R3, R11
	BEQ b35				// check 357
						// else check 456
b4:	CMP R4, R11
	BEQ b45				// check 456
						// else check 789
b7:	CMP R7, R11
	BEQ b78				// check 789
	BNE no_winner		// no winner found

b12:CMP R2, R11
	BEQ b123			// check 123
						// else check 147
b14:CMP R4, R11
	BEQ b147			// check 147
						// else check 159
b15:CMP R5, R11
	BEQ	b159			// check 159
	BNE b2				// else check 258
	
b25:CMP R5, R11
	BEQ b258			// check 258
	BNE b3				// else check 357 or 369
	
b35:CMP R5, R11
	BEQ b357			// check 357
						// else check 369
b36:CMP R6, R11
	BEQ b369			// check 369
	BNE b4				// else check 456
	
b45:CMP R5, R11
	BEQ b456			// check 456
	BNE b7				// else check 789
	
b78:CMP R8, R11
	BEQ b789			// check 789
	BNE	no_winner		// no winner found

b123:	CMP R3, R11
		BEQ has_winner			// 123 wins
		BNE b14				// check 147
b147:	CMP R7, R11
		BEQ has_winner			// 147 wins
		BNE b15				// check 159
b159:	CMP R9, R11
		BEQ has_winner			// 159 wins
		BNE b2				// check 258

b258:	CMP R8, R11
		BEQ has_winner			// 258 wins
		BNE b3				// check 357 or 369

b357:	CMP R7, R11
		BEQ has_winner			// 357 wins
		BNE b36				// check 369
b369:	CMP R9, R11
		BEQ has_winner			// 369 wins
		BNE b4				// check 456

b456:	CMP R6, R11
		BEQ has_winner			// 456 wins
		BNE b7				// check 789

b789:	CMP R9, R11
		BEQ has_winner			// 789 wins
		BNE no_winner		// all winning conditions are checked but no winner found
	
	has_winner:
	MOV R0, R11
	B return5
	no_winner:
	MOV R0, #2
	return5:
	POP {R1,R2,R3,R4,R5,R6,R7,R8,R9}
	BX LR

// PS2
read_PS2_data_ASM:	
	PUSH {R4, R5, R6, R7}
	LDR R4, =PS2_MEMORY			// load PS2 address
	LDR R6, [R4]				// load PS2_data into R6
	LSR R5, R6, #15				// shift PS2_data 15 bits to the right
	AND R5, R5, #0x1			// extract the lowest bit
	
	CMP R5, #0
	MOVEQ R0, #0				// return 0
	BEQ return					// if RVALID is 0, do nothing and return R0 as 0
	
	LDRB R7, [R4]				// load the last 8 bits of PS2_data into R7
	STRB R7, [R0]				// store the data into the given address
	MOV R0, #1					// return 1
	
	return:
	POP {R4, R5, R6, R7}
	BX LR

// VGA char
VGA_write_char_ASM:
// R0 = int x
// R1 = int y
// R2 = char c (ASCII)
	PUSH {R0, R1, R2, R3}
	// check if x anf y are in valid range
	CMP R0, #0
	BXLT LR
	CMP R0, #79
	BXGT LR
	CMP R1, #0
	BXLT LR
	CMP R1, #59
	BXGT LR
	// write into memory if x and y are valid
	LDR R3, =CHAR_MEMORY
	ADD R3, R3, R0				// set the x coordinate
	ADD R3, R3, R1, LSL#7		// set the y coordinate
	STRB R2, [R3]
	POP {R0, R1, R2, R3}
	BX LR
	
result_ASM:
// R0 : the result 
// '0' for player-1 Wins, '1' for player-2 Wins 
// otherwise for Draw
	CMP R0, #0
	BEQ winner
	CMP R0, #1
	BEQ winner
//Draw
	//D
	MOV R0, #38
	MOV R1, #4
	MOV R2, #68
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	//r
	MOV R0, #39
	MOV R1, #4
	MOV R2, #114
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	//a
	MOV R0, #40
	MOV R1, #4
	MOV R2, #97
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	//w
	MOV R0, #41
	MOV R1, #4
	MOV R2, #119
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	B return4
	
	winner:
	//Player-x
	PUSH {LR}
	BL write_player
	POP {LR}
	// Wins
	PUSH {LR}
	BL write_wins
	POP {LR}
	return4:
	BX LR

Player_turn_ASM:
// R0 : the player’s turn 
// ('0' for player-1 and '1' for player-2)
	PUSH {R0, R1, R2}
	PUSH {LR}
	BL write_player
	POP {LR}
	POP {R0, R1, R2}
	BX LR
	
write_wins:
//Wins
	PUSH {R0, R1, R2}	
	//" "
	MOV R0, #44
	MOV R1, #4
	MOV R2, #32
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	//W
	MOV R0, #45
	MOV R1, #4
	MOV R2, #87
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	//i
	MOV R0, #46
	MOV R1, #4
	MOV R2, #105
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	//n
	MOV R0, #47
	MOV R1, #4
	MOV R2, #110
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	//s
	MOV R0, #48
	MOV R1, #4
	MOV R2, #115
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	POP {R0, R1, R2}
	BX LR
	
	
write_player:
//Player-x
	PUSH {R0, R1, R2}
	// P
	MOV R0, #36
	MOV R1, #4
	MOV R2, #80
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	// l
	MOV R0, #37
	MOV R1, #4
	MOV R2, #108
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	// a
	MOV R0, #38
	MOV R1, #4
	MOV R2, #97
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	// y
	MOV R0, #39
	MOV R1, #4
	MOV R2, #121
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	// e
	MOV R0, #40
	MOV R1, #4
	MOV R2, #101
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	// r
	MOV R0, #41
	MOV R1, #4
	MOV R2, #114
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	// -
	MOV R0, #42
	MOV R1, #4
	MOV R2, #45
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	POP {R0, R1, R2}	
	// determine which play to display
	CMP R0, #0
	BEQ player1
	CMP R0, #1
	BEQ player2
player1:
	// 1
	MOV R0, #43
	MOV R1, #4
	MOV R2, #49
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
	B return3
player2:
	// 2
	MOV R0, #43
	MOV R1, #4
	MOV R2, #50
	PUSH {LR}
	BL  VGA_write_char_ASM
	POP {LR}
return3:
	BX LR

VGA_clear_charbuff_ASM:
	MOV R0, #0				// x coordinate
	MOV R1, #0				// y coordinate
	MOV R2, #0				// clear: set char to 0 
	char_loop_x:
		CMP R0, #79
		BXGT LR	
		B char_loop_y
		
	char_loop_y:
		CMP R1, #59
		MOVGT R1, #0
		ADDGT R0, #1		// increment x coordinate by 1
		BGT char_loop_x
 		
		PUSH {LR}
		BL VGA_write_char_ASM
		POP {LR}
		
		ADD R1, #1			// increment y coordinate by 1
		B char_loop_y
		
// VGA pixel
draw_square_ASM:
// (R0, R1) = center coordinate (x,y)
	PUSH {R4, R5, R6, R7, R8, R9}
	LDR R2, grid_color		// set mark color to be the same as the grid

// draw the first horizontal line
	SUB R4, R0, #16			// x floor
	ADD R5, R0, #16			// x ceiling
	SUB R6, R1, #16			// y floor
	SUB R7, R1, #12			// y ceiling	
	PUSH {LR}
	BL draw_horizontal
	POP {LR}		
// draw the second horizontal line
	SUB R4, R0, #16			// x floor
	ADD R5, R0, #16			// x ceiling
	ADD R6, R1, #12			// y floor
	ADD R7, R1, #16			// y ceiling	
	PUSH {LR}
	BL draw_horizontal
	POP {LR}
	B vertical1

draw_horizontal:
	PUSH {R8, R9}
	MOV R8, R4				// x coordinate counter
	MOV R9, R6				// y coordinate counter
	loop_x_squ_h:
		CMP R8, R5
		POPGT {R8, R9}
		BXGT LR
		B loop_y_squ_h
	loop_y_squ_h:
		CMP R9, R7
		MOVGT R9, R6
		ADDGT R8, #1		// increment x coordinate by 1
		BGT loop_x_squ_h
		PUSH {R0, R1, LR}
		MOV R0, R8			// set the coordinate of the pixel to fill
		MOV R1, R9			// using R8 & R9 then pass them into R0 & R1
		BL VGA_draw_point_ASM
		POP {R0, R1, LR}		
		ADD R9, #1			// increment y coordinate by 1
		B loop_y_squ_h
		
vertical1:
// draw the first vertical line
	SUB R4, R0, #16			// x floor
	SUB R5, R0, #12			// x ceiling
	SUB R6, R1, #16			// y floor
	ADD R7, R1, #16			// y ceiling
	PUSH {LR}
	BL draw_vertical
	POP {LR}	
// draw the second vertical line
	ADD R4, R0, #12			// x floor
	ADD R5, R0, #16			// x ceiling
	SUB R6, R1, #16			// y floor
	ADD R7, R1, #16			// y ceiling
	PUSH {LR}
	BL draw_vertical
	POP {LR}
	POP {R4, R5, R6, R7, R8, R9}
	BX LR
	
draw_vertical:
	PUSH {R8, R9}
	MOV R8, R4				// x coordinate counter
	MOV R9, R6				// y coordinate counter
	loop_x_squ_v:
		CMP R8, R5
		POPGT {R8, R9}
		BXGT LR
		B loop_y_squ_v
	loop_y_squ_v:
		CMP R9, R7
		MOVGT R9, R6
		ADDGT R8, #1		// increment x coordinate by 1
		BGT loop_x_squ_v
		PUSH {R0, R1, LR}
		MOV R0, R8			// set the coordinate of the pixel to fill
		MOV R1, R9			// using R8 & R9 then pass them into R0 & R1
		BL VGA_draw_point_ASM
		POP {R0, R1, LR}		
		ADD R9, #1			// increment y coordinate by 1
		B loop_y_squ_v
	
draw_plus_ASM:
// (R0, R1) = center coordinate (x,y)
	PUSH {R4, R5, R6, R7, R8, R9}
	LDR R2, grid_color		// set mark color to be the same as the grid
vertical:	
	SUB R4, R0, #2			// x floor
	ADD R5, R0, #2			// x ceiling
	SUB R6, R1, #16			// y floor
	ADD R7, R1, #16			// y ceiling
	
	MOV R8, R4				// x coordinate counter
	MOV R9, R6				// y coordinate counter
	loop_x_cross_v:
		CMP R8, R5
		BGT horizontal
		B loop_y_cross_v	
	loop_y_cross_v:
		CMP R9, R7
		MOVGT R9, R6
		ADDGT R8, #1		// increment x coordinate by 1
		BGT loop_x_cross_v		
		PUSH {R0, R1, LR}
		MOV R0, R8			// set the coordinate of the pixel to fill
		MOV R1, R9			// using R8 & R9 then pass them into R0 & R1
		BL VGA_draw_point_ASM
		POP {R0, R1, LR}		
		ADD R9, #1			// increment y coordinate by 1
		B loop_y_cross_v	
		
horizontal:
	SUB R4, R0, #16			// x floor
	ADD R5, R0, #16			// x ceiling
	SUB R6, R1, #2			// y floor
	ADD R7, R1, #2			// y ceiling
	
	MOV R8, R4				// x coordinate counter
	MOV R9, R6				// y coordinate counter
	loop_x_cross_h:
		CMP R8, R5
		BGT return1
		B loop_y_cross_h	
	loop_y_cross_h:
		CMP R9, R7
		MOVGT R9, R6
		ADDGT R8, #1		// increment x coordinate by 1
		BGT loop_x_cross_h	
		PUSH {R0, R1, LR}
		MOV R0, R8			// set the coordinate of the pixel to fill
		MOV R1, R9			// using R8 & R9 then pass them into R0 & R1
		BL VGA_draw_point_ASM
		POP {R0, R1, LR}		
		ADD R9, #1			// increment y coordinate by 1
		B loop_y_cross_h
return1:
	POP {R4, R5, R6, R7, R8, R9}
	BX LR

VGA_draw_point_ASM:
// R0 = int x
// R1 = int y
// R2 = short c
	PUSH {R0, R1, R2, R3}
	LDR R3, =PIXEL_MEMORY
	ADD R3, R3, R0, LSL#1		// set the x coordinate
	ADD R3, R3, R1, LSL#10		// set the y coordinate
	STRH R2, [R3]				// pixel value is half word (16 bytes)
	POP {R0, R1, R2, R3}
	BX LR

VGA_fill_ASM:
	MOV R0, #0					// x coordinate
	MOV R1, #0					// y coordinate	
	LDR R2, background_color	// set background color to the given RGB value
	LDR R3, x_limit				// R3 = 319	
	fill_loop_x:
		CMP R0, R3
		BXGT LR	
		B fill_loop_y
		
	fill_loop_y:
		CMP R1, #239
		MOVGT R1, #0
		ADDGT R0, #1		// increment x coordinate by 1
		BGT fill_loop_x
 		
		PUSH {LR}
		BL VGA_draw_point_ASM
		POP {LR}
		
		ADD R1, #1			// increment y coordinate by 1
		B fill_loop_y

draw_grid_ASM:
	LDR R2, grid_color			// set grid color to the given RGB value
	LDR R3, grid_limit			// R3 = 319
	
	v1:
	MOV R0, #56					// x coordinate
	MOV R1, #32					// y coordinate		
	grid_loop_x_1:
		CMP R0, #60
		BGT v2		
		B grid_loop_y_1		
	grid_loop_y_1:
		CMP R1, #239
		MOVGT R1, #32
		ADDGT R0, #1		// increment x coordinate by 1
		BGT grid_loop_x_1		
		PUSH {LR}
		BL VGA_draw_point_ASM
		POP {LR}		
		ADD R1, #1			// increment y coordinate by 1
		B grid_loop_y_1
		
	v2:
	MOV R0, #124				// x coordinate
	MOV R1, #32					// y coordinate		
	grid_loop_x_2:
		CMP R0, #128
		BGT v3		
		B grid_loop_y_2		
	grid_loop_y_2:
		CMP R1, #239
		MOVGT R1, #32
		ADDGT R0, #1		// increment x coordinate by 1
		BGT grid_loop_x_2		
		PUSH {LR}
		BL VGA_draw_point_ASM
		POP {LR}		
		ADD R1, #1			// increment y coordinate by 1
		B grid_loop_y_2
		
	v3:
	MOV R0, #191				// x coordinate
	MOV R1, #32					// y coordinate		
	grid_loop_x_3:
		CMP R0, #195
		BGT v4		
		B grid_loop_y_3		
	grid_loop_y_3:
		CMP R1, #239
		MOVGT R1, #32
		ADDGT R0, #1		// increment x coordinate by 1
		BGT grid_loop_x_3		
		PUSH {LR}
		BL VGA_draw_point_ASM
		POP {LR}		
		ADD R1, #1			// increment y coordinate by 1
		B grid_loop_y_3
		
	v4:
	LDR R0, last_line				// x coordinate
	MOV R1, #32					// y coordinate		
	grid_loop_x_4:
		CMP R0, R3
		BGT h5		
		B grid_loop_y_4		
	grid_loop_y_4:
		CMP R1, #239
		MOVGT R1, #32
		ADDGT R0, #1		// increment x coordinate by 1
		BGT grid_loop_x_4		
		PUSH {LR}
		BL VGA_draw_point_ASM
		POP {LR}		
		ADD R1, #1			// increment y coordinate by 1
		B grid_loop_y_4
		
	h5:
	MOV R0, #56					// x coordinate
	MOV R1, #32					// y coordinate		
	grid_loop_x_5:
		CMP R0, R3				// R3 = 263
		BGT h6		
		B grid_loop_y_5		
	grid_loop_y_5:
		CMP R1, #36
		MOVGT R1, #32
		ADDGT R0, #1		// increment x coordinate by 1
		BGT grid_loop_x_5		
		PUSH {LR}
		BL VGA_draw_point_ASM
		POP {LR}		
		ADD R1, #1			// increment y coordinate by 1
		B grid_loop_y_5
		
	h6:
	MOV R0, #56					// x coordinate
	MOV R1, #100					// y coordinate		
	grid_loop_x_6:
		CMP R0, R3				// R3 = 263
		BGT h7		
		B grid_loop_y_6		
	grid_loop_y_6:
		CMP R1, #104
		MOVGT R1, #100
		ADDGT R0, #1		// increment x coordinate by 1
		BGT grid_loop_x_6		
		PUSH {LR}
		BL VGA_draw_point_ASM
		POP {LR}		
		ADD R1, #1			// increment y coordinate by 1
		B grid_loop_y_6
		
	h7:
	MOV R0, #56					// x coordinate
	MOV R1, #167					// y coordinate		
	grid_loop_x_7:
		CMP R0, R3				// R3 = 263
		BGT h8		
		B grid_loop_y_7	
	grid_loop_y_7:
		CMP R1, #171
		MOVGT R1, #167
		ADDGT R0, #1		// increment x coordinate by 1
		BGT grid_loop_x_7		
		PUSH {LR}
		BL VGA_draw_point_ASM
		POP {LR}		
		ADD R1, #1			// increment y coordinate by 1
		B grid_loop_y_7

	h8:
	MOV R0, #56					// x coordinate
	MOV R1, #235					// y coordinate		
	grid_loop_x_8:
		CMP R0, R3
		BXGT LR		
		B grid_loop_y_8	
	grid_loop_y_8:
		CMP R1, #239
		MOVGT R1, #235
		ADDGT R0, #1		// increment x coordinate by 1
		BGT grid_loop_x_8		
		PUSH {LR}
		BL VGA_draw_point_ASM
		POP {LR}		
		ADD R1, #1			// increment y coordinate by 1
		B grid_loop_y_8
	
VGA_clear_pixelbuff_ASM:	
	MOV R0, #0				// x coordinate
	MOV R1, #0				// y coordinate
	MOV R2, #0				// clear: set pixel to 0 
	LDR R3, x_limit			// R3 = 319
	loop_x:
		CMP R0, R3
		BXGT LR	
		B loop_y
		
	loop_y:
		CMP R1, #239
		MOVGT R1, #0
		ADDGT R0, #1		// increment x coordinate by 1
		BGT loop_x
 		
		PUSH {LR}
		BL VGA_draw_point_ASM
		POP {LR}
		
		ADD R1, #1			// increment y coordinate by 1
		B loop_y