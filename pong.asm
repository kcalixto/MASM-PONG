STACK SEGMENT PARA STACK
	db 64 DUP (' ')

STACK ENDS

DATA SEGMENT PARA 'DATA'

	WINDOW_WIDTH DW 140h ;; the width of the window (320px)
	WINDOW_HEIGHT DW 0C8h ;; the height of the window (200px)
	WINDOW_BOUNDS DW 6		;; variable used to check colisions earlier

	TIME_AUX db 0 ;; variable used when checking if the time has changed 

	BALL_ORIGINAL_X DW 0A0h ;; middle of screen
	BALL_ORIGINAL_Y DW 64h
	BALL_X dw 0A0h ;; X position (column) of the ball 
	BALL_Y dw 0Ah ;; Y position (line) of the ball
	BALL_SIZE dw 04h ;; size of the ball (pixels in width and height)
	BALL_VELOCITY_X DW 02H ;; X (horizontal) velocity of the ball
	BALL_VELOCITY_Y DW 02H ;; Y (vertical) velocity of the ball

	PADDLE_LEFT_X DW 0Ah
	PADDLE_LEFT_Y DW 0Ah
	
	PADDLE_RIGHT_X DW 130h
	PADDLE_RIGHT_Y DW 0Ah

	PADDLE_WIDTH DW 05h
	PADDLE_HEIGHT DW 1Fh
	
	PADDLE_VELOCITY DW 05h

DATA ENDS

CODE SEGMENT PARA 'CODE'

	MAIN PROC FAR
	ASSUME CS:CODE, DS:DATA, SS:STACK 	;; assume as code, data and stack segments their respective registers
	PUSH ds								;; push to the stack the DS (data segment) segment
	SUB ax, ax 							;; clean ax
	PUSH ax 							;; push ax to the stack
	mov ax, data 						;; save ib the ax register the content of data segment
	mov ds, ax							;; save on the DS segment the content of ax
	pop ax								;; release top item from the stack to the ax register
	pop ax
	;;good practice thing, if not do it, the game probably will crash, because you push DS and AX
	
		CALL CLEAR_SCREEN ;;clear screen procedure
	
		CHECK_TIME:
			mov ah, 2ch ;; Function GetSystemTime code
			int 21h     ;; CH = hour CL = minute DH = second DL = 1/100 seconds
		
			cmp DL,TIME_AUX	;; is the current time == previous one (TIME_AUX) ?
			JE CHECK_TIME	;; if its the same, check again
			
			;; if it's different, then draw, move, etc.
			mov TIME_AUX, DL ;; update previous time
			
			CALL CLEAR_SCREEN ;; clear screen procedure
			
			CALL MOVE_BALL ;; move ball procedure
			CALL DRAW_BALL ;; call procedure
			
			CALL MOVE_PADDLES
			CALL DRAW_PADDLES
			
			JMP CHECK_TIME ;; After everything, check time again
	
		RET ;; ret = final de func 
	MAIN ENDP
	
	MOVE_BALL PROC NEAR
		;; Incrementing our velocity
		MOV AX, BALL_VELOCITY_X 
		ADD BALL_X, AX 		;; move the ball horizontally
		
								;; checking colision 
		MOV AX, WINDOW_BOUNDS	;; saving window_bounds to use later
		CMP BALL_X, AX			;; Comparing agains our defined bounds (like a margin)
		JL RESET_POSITION  		;; if BALL_X < 0 (Y -> collided)
								;; JL -> jump if is Less
		MOV AX, WINDOW_WIDTH	;; getting windows_width
		SUB AX, BALL_SIZE		;; reducing ball_size in space
		SUB AX, WINDOW_BOUNDS	;; reducing our margin
		CMP BALL_X, AX			;; if BALL_X > WINDOW_WIDTH - BALL_SIZE - WINDOW_BOUNDS (X -> collided)
		JG RESET_POSITION 		;; JG -> jump if greater
									
		
		MOV AX, BALL_VELOCITY_Y
		ADD BALL_Y, AX 		;; move the ball vertically
		
								;;checking colision 
		MOV AX, WINDOW_BOUNDS
		CMP BALL_Y, AX
		JL NEG_VELOCITY_Y  			;; BALL_Y < 0 (Y -> collided)
									;; JL -> jump if is Less
		MOV AX, WINDOW_HEIGHT
		SUB AX, BALL_SIZE
		SUB AX, WINDOW_BOUNDS
		CMP BALL_Y, AX				;; BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS (Y -> collided)
		JG NEG_VELOCITY_Y 			;; JG -> jump if greater	
				
		RET
		
		RESET_POSITION:
			CALL RESET_BALL_POSITION
			RET
		
		NEG_VELOCITY_X:
			NEG BALL_VELOCITY_X ;;BALL_VELOCITY_X = !BALL_VELOCITY_X
			RET
			
		NEG_VELOCITY_Y:
			NEG BALL_VELOCITY_Y ;;BALL_VELOCITY_Y = !BALL_VELOCITY_Y
			RET
			
	MOVE_BALL ENDP
	
	MOVE_PADDLES PROC NEAR
	
		;;left paddle movement
		
		;;check if any key has been pressed(if not check the other paddle)
		MOV AH, 01h ;; calling interruption to read keyboard press
		INT 16h
		JZ CHECK_RIGHT_PADDLE_MOVEMENT ;; IF = 1, JZ -> Jump if Zero
		
		;;check wich key is beeing pressed
		
		MOV AH, 00h ;; calling int to read key pressed
		INT 16h
		
		;;if it is 'w' or 'W' move up
		CMP AL, 57h ;; 57h = W in ASCI
		JE MOVE_LEFT_PADDLE_UP ;; je -> jump if equal
		CMP AL, 77h ;; 77h = w in ASCI
		JE MOVE_LEFT_PADDLE_UP ;; je -> jump if equal
		
		;;if it is 's' or 'S' move down
		
		CMP AL, 53h ;; 53h = S in ASCI
		JE MOVE_LEFT_PADDLE_DOWN ;; je -> jump if equal
		CMP AL, 73h ;; 73h = s in ASCI
		JE MOVE_LEFT_PADDLE_DOWN ;; je -> jump if equal
		JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		MOVE_LEFT_PADDLE_UP:
			MOV AX, PADDLE_VELOCITY
			SUB PADDLE_LEFT_Y, AX
			
			MOV AX, WINDOW_BOUNDS
			CMP PADDLE_LEFT_Y, AX
			JL FIX_PADDLE_LEFT_TOP_POSITION
			
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_TOP_POSITION:
				MOV AX, WINDOW_BOUNDS
				MOV PADDLE_LEFT_Y, AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
				RET
			
			RET
			
		MOVE_LEFT_PADDLE_DOWN:
			MOV AX, PADDLE_VELOCITY
			ADD PADDLE_LEFT_Y, AX
			MOV AX, WINDOW_HEIGHT
			SUB AX, WINDOW_BOUNDS
			SUB AX, PADDLE_HEIGHT
			CMP PADDLE_LEFT_Y, AX
			JG FIX_PADDLE_LEFT_BOTTOM_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_BOTTOM_POSITION:
				MOV PADDLE_LEFT_Y, AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
				RET
			
			RET
		;;
		
		;;right paddle movement
		CHECK_RIGHT_PADDLE_MOVEMENT:
			RET
	
		;;check if any key has been pressed(if notexit procedure)
		
		;;check wich key is beeing pressed
		
		;;if it is 'o' or 'O' move up
		
		;;if it is 'l' or 'L' move down
		
	
		RET
	MOVE_PADDLES ENDP
	
	RESET_BALL_POSITION PROC NEAR
		
		MOV AX, BALL_ORIGINAL_X
		MOV BALL_X, AX
		
		MOV AX, BALL_ORIGINAL_Y
		MOV BALL_Y, AX
		
		RET
	RESET_BALL_POSITION ENDP
	
	DRAW_BALL PROC NEAR
		
		mov cx, BALL_X ;; set the initial column (X) to 10 
		mov dx, BALL_Y ;; set the initial line (Y) to 10
		
		DRAW_BALL_HORIZONTAL:
			;; draw the pixel
			mov ah, 0Ch ;; set the config to writing pixel
			mov al, 0Fh ;; set the color 
			mov bh, 00h ;; set the page number
			int 10h 	;; execute
			
			;; INCREMENT COLUMNS
			inc cx 		;; cx = cx + 1 / Increment
			mov ax, cx	;; cx - BALL_X > BALL_SIZE (Y - We go to the next line, F - We continue to the next column)
			sub ax, BALL_X ;; subtraction
			CMP ax, BALL_SIZE ;; Compare
			JNG DRAW_BALL_HORIZONTAL ;; Jump if Not Greater
			
			;; RESET CX
			mov cx, BALL_X ;; cx register go back to the initial column (THIS CODE BLOCK ONLY RUNS IF JNG IS FALSE)
			inc dx ;; advance one line ;increment dx
			
			;; INCREMENT LINES
			mov ax, dx ;; dx - BALL_Y > BALL_SIZE (Y -> we exit this procedure, F -> we continue to the next line)
			sub ax, BALL_Y
			CMP ax, BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
		
		RET
	DRAW_BALL ENDP
	
	DRAW_PADDLES PROC NEAR
		MOV CX, PADDLE_LEFT_X ;; set the initial column (X) to 10 
		MOV DX, PADDLE_LEFT_Y ;; set the initial line (Y) to 10
		
		DRAW_PADDLE_LEFT_HORIZONTAL:
			MOV AH, 0Ch ;; set the config to writing pixel
			MOV AL, 0Fh ;; set the color 
			MOV BH, 00h ;; set the page number
			INT 10h 	;; execute
			
			INC CX 		;; cx = cx + 1 / Increment
			MOV AX, CX	;; cx - PADDLE_LEFT_X > PADDLE_LEFT_WIDTH (Y - We go to the next line, F - We continue to the next column)
			SUB AX, PADDLE_LEFT_X ;; subtraction
			CMP AX, PADDLE_WIDTH ;; Compare
			JNG DRAW_PADDLE_LEFT_HORIZONTAL ;; Jump if Not Greater
		
			;; RESET CX
			MOV CX, PADDLE_LEFT_X ;; cx register go back to the initial column (THIS CODE BLOCK ONLY RUNS IF JNG IS FALSE)
			INC DX ;; advance one line ;increment dx
			
			;; INCREMENT LINES
			MOV AX, DX ;; dx - PADDLE_LEFT_Y > PADDLE_HEIGHT (Y -> we exit this procedure, F -> we continue to the next line)
			SUB AX, PADDLE_LEFT_Y
			CMP AX, PADDLE_HEIGHT
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
		
		;;right paddle
		MOV CX, PADDLE_RIGHT_X ;; set the initial column (X) to 10 
		MOV DX, PADDLE_RIGHT_Y ;; set the initial line (Y) to 10
		
		DRAW_PADDLE_RIGHT_HORIZONTAL:
			MOV AH, 0Ch ;; set the config to writing pixel
			MOV AL, 0Fh ;; set the color 
			MOV BH, 00h ;; set the page number
			INT 10h 	;; execute
			
			INC CX 		;; cx = cx + 1 / Increment
			MOV AX, CX	;; cx - PADDLE_RIGHT_X > PADDLE_RIGHT_WIDTH (Y - We go to the next line, F - We continue to the next column)
			SUB AX, PADDLE_RIGHT_X ;; subtraction
			CMP AX, PADDLE_WIDTH ;; Compare
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL ;; Jump if Not Greater
		
			;; RESET CX
			MOV CX, PADDLE_RIGHT_X ;; cx register go back to the initial column (THIS CODE BLOCK ONLY RUNS IF JNG IS FALSE)
			INC DX ;; advance one line ;increment dx
			
			;; INCREMENT LINES
			MOV AX, DX ;; dx - PADDLE_RIGHT_Y > PADDLE_HEIGHT (Y -> we exit this procedure, F -> we continue to the next line)
			SUB AX, PADDLE_RIGHT_Y
			CMP AX, PADDLE_HEIGHT
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
		
		RET
	DRAW_PADDLES ENDP
	
	CLEAR_SCREEN PROC NEAR
		;; Painting the screen to black
		mov ah, 00h ;; set the configuration to video mode
		mov al, 0Dh ;; choose the video mode
		int 10h ;; int = interruption, 10h = video service interruption execute
		
		;; Background config
		mov ah, 0Bh ;; set the configuration...
		mov bh, 00h ;; to Background color
		
		mov bl, 00h ;; choose color
		int 10h    ;; executes
		;;end of painting
		
		RET
	CLEAR_SCREEN ENDP
	

CODE ENDS
END