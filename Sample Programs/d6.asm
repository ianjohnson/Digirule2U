	;; Electronic 6 die for Digirule 2U
	org 0

	speed 5
	
start	initsp

	;; Seed LFSR
	call lfsr_init

	;; Display some start bling
	call flash_leds

	;; Wait for the 8 button to be pressed
wait_loop_press
	;; Has bit 7 data button been pressed?
	btstsc 7,_br
	jump wait_loop_unpress
	jump wait_loop_press
wait_loop_unpress
	btstss 7,_br
	jump roll_die
	jump wait_loop_unpress

	;; Roll the die
roll_die
  	copylr 0x3f,_dr
	call get_number
	call display_number
	jump wait_loop_press

display_number
	copylr 1,counter
display_number_loop
	decrjz number
	jump display_number_fwd
	jump display_number_finish
display_number_fwd
	shiftrl counter
	jump display_number_loop
display_number_finish
	copyrr counter,_dr
	return

	;; Random number 1 to 6
get_number
	copylr 0,number
	copylr 5,counter
get_number_load_loop
	call lfsr_shift
	shiftrl number
	decrjz counter
	jump get_number_load_loop
 	; Number contains a decimal from [0,0.96875]
  	bclr _c,_sr
   	copyla 0
    	; Multiply number by 6
    	addra number
     	addra number
      	addra number
      	addra number
      	addra number
      	addra number
       	; Shift out decimal part
        	andla 0xe0
         	copyar number
	shiftrr number
 	shiftrr number
  	shiftrr number
   	shiftrr number
    	shiftrr number
	incr number
	return

	;; LFSR  routines
lfsr_init
	randa
	copyar lfsr
	randa
	copyar lfsr+1
	randa
	copyar lfsr+2
	randa
	copyar lfsr+3
	randa
	copyar lfsr+4
	randa
	copyar lfsr+5
	randa
	copyar lfsr+6
	randa
	copyar lfsr+7
	return

	;; Taps at 64, 63, 61, 60
	;; (see https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf)
lfsr_shift
	copyrr lfsr+7,lfsr_ws
	copyra lfsr_ws
 	;; Bit 60
 	shiftrl lfsr_ws
  	shiftrl lfsr_ws
   	shiftrl lfsr_ws
 	xorra lfsr_ws
  	;; Bit 61
   	shiftrl lfsr_ws
    	xorra lfsr_ws
     	;; Bit 63
      	shiftrl lfsr_ws
       	shiftrl lfsr_ws
        	xorra lfsr_ws
	;; Bit 64
 	shiftrl lfsr_ws
  	xorra lfsr_ws
	andla 0x01
	;; Shift the register
	shiftrr lfsr+7
	shiftrr lfsr+6
	shiftrr lfsr+5
	shiftrr lfsr+4
	shiftrr lfsr+3
	shiftrr lfsr+2
	shiftrr lfsr+1
	shiftrr lfsr
	xorra lfsr
	copyar lfsr
	return

flash_leds
	copylr 6,counter
flash_leds_loop
	copylr 0,_dr
	nop
	nop
	nop
	nop
 	nop
	nop
	nop
	nop
 	nop
	nop
	nop
	nop
  	nop
	nop
	nop
	nop
 	nop
  	nop
	nop
	nop
	nop
	copylr 0x3f,_dr
	nop
	nop
	nop
	nop
 	nop
	nop
	nop
	nop
 	nop
	nop
	nop
	nop
  	nop
	nop
	nop
	nop
 	nop
  	nop
	nop
	nop
	nop
	decrjz counter
	jump flash_leds_loop
	return

	;; Variables
	org 240

	;; The random number [1, 6]
number	space 1

	;; 64-bit LFSR state
lfsr    space 8
lfsr_ws space 1

	;; Counter
counter space 1

	end start
