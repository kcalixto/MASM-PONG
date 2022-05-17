STACK SEGMENT PARA STACK
	db 64 DUP (' ')

STACK ENDS

DATA SEGMENT PARA 'DATA'

	WINDOW_WIDTH DW 140h ;; the width of the window (320px)
	WINDOW_HEIGHT DW 0C8h ;; the height of the window (200px)
	WINDOW_BOUNDS DW 6		;; variable used to check colisions earlier

	TIME_AUX db 0 ;; variable used when checking if the time has changed 

	BALL_X dw 0Ah ;; X position (column) of the ball 
	BALL_Y dw 0Ah ;; Y position (line) of the ball
	BALL_SIZE dw 04h ;; size of the ball (pixels in width and height)
	BALL_VELOCITY_X DW 02H ;; X (horizontal) velocity of the ball
	BALL_VELOCITY_Y DW 02H ;; Y (vertical) velocity of the ball

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
		JL NEG_VELOCITY_X  		;; if BALL_X < 0 (Y -> collided)
								;; JL -> jump if is Less
		MOV AX, WINDOW_WIDTH	;; getting windows_width
		SUB AX, BALL_SIZE		;; reducing ball_size in space
		SUB AX, WINDOW_BOUNDS	;; reducing our margin
		CMP BALL_X, AX			;; if BALL_X > WINDOW_WIDTH - BALL_SIZE - WINDOW_BOUNDS (X -> collided)
		JG NEG_VELOCITY_X 		;; JG -> jump if greater
									
		
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
		
		NEG_VELOCITY_X:
			NEG BALL_VELOCITY_X ;;BALL_VELOCITY_X = !BALL_VELOCITY_X
			RET
			
		NEG_VELOCITY_Y:
			NEG BALL_VELOCITY_Y ;;BALL_VELOCITY_Y = !BALL_VELOCITY_Y
			RET
			
	MOVE_BALL ENDP
	
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
			
			;; INCREMENT LINES
			inc dx ;; advance one line ;increment dx
			mov ax, dx ;; dx - BALL_Y > BALL_SIZE (Y -> we exit this procedure, F -> we continue to the next line)
			sub ax, BALL_Y
			CMP ax, BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
		
		RET
	DRAW_BALL ENDP
	
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