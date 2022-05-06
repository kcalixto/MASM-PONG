STACK SEGMENT PARA STACK
	db 64 DUP (' ')

STACK ENDS

DATA SEGMENT PARA 'DATA'

	BALL_X dw 0Ah ; X position (column) of the ball 
	BALL_Y dw 0Ah ; Y position (line) of the ball
	BALL_SIZE dw 04h ; size of the ball (pixels in width and height)

DATA ENDS

CODE SEGMENT PARA 'CODE'

	MAIN PROC FAR
	ASSUME CS:CODE, DS:DATA, SS:STACK 	;assume as code, data and stack segments their respective registers
	PUSH ds								;push to the stack the DS (data segment) segment
	SUB ax, ax 							;clean ax
	PUSH ax 							;push ax to the stack
	mov ax, data 						;save ib the ax register the content of data segment
	mov ds, ax							;save on the DS segment the content of ax
	pop ax								;release top item from the stack to the ax register
	pop ax
	;good practice thing, if not do it, the game probably will crash, because you push DS and AX
	
	
		mov ah, 00h ;set the configuration to video mode
		mov al, 13h ;choose the video mode
		int 10h ;int = interruption, 10h = video service interruption execute
		
		;Background config
		mov ah, 0Bh ; set the configuration...
		mov bh, 00h ; to Background color
		
		mov bl, 00h ; choose color
		int 10h    ; executes
	
		call DRAW_BALL ; call procedure
	
		RET ;ret = final de func 
	MAIN ENDP
	
	DRAW_BALL PROC NEAR
		
		mov cx, BALL_X ; set the initial column (X) to 10 
		mov dx, BALL_Y ; set the initial line (Y) to 10
		
		DRAW_BALL_HORIZONTAL:
			;draw the pixel
			mov ah, 0Ch ; set the config to writing pixel
			mov al, 0Fh ; set the color 
			mov bh, 00h ; set the page number
			int 10h 	; execute
			
			;INCREMENT COLUMNS
			inc cx 		;cx = cx + 1 / Increment
			mov ax, cx	;cx - BALL_X > BALL_SIZE (Y - We go to the next line, F - We continue to the next column)
			sub ax, BALL_X ; subtraction
			CMP ax, BALL_SIZE ; Compare
			JNG DRAW_BALL_HORIZONTAL ; Jump if Not Greater
			
			;RESET CX
			mov cx, BALL_X ; cx register go back to the initial column (THIS CODE BLOCK ONLY RUNS IF JNG IS FALSE)
			
			;INCREMENT LINES
			inc dx ;advance one line ;increment dx
			mov ax, dx;dx - BALL_Y > BALL_SIZE (Y -> we exit this procedure, F -> we continue to the next line)
			sub ax, BALL_Y
			CMP ax, BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
		
		RET
	DRAW_BALL ENDP
	

CODE ENDS
END