	;; Electronic 6 die for Digirule 2U
	org 0

counter equ 0xfb
number  equ 0xfa
tmp	equ 0xf9
seed	equ 0xf8	

	initsp

	speed 128

	;; Read the "seed" from the button register
	;; TODO: Can we implement a 24 bit LFSR?
	copyrr _br,seed

	;; Display some start bling
	call n_shuffle_leds

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
	call get_number
	call n_shuffle_leds
	call display_number
	jump wait_loop_press

display_number
	copylr 1,tmp
	decrjz number
	jump display_number_fwd
	jump display_number_finish
display_number_fwd
	shiftrl tmp
	jump display_number
display_number_finish
	copyrr tmp,_dr
	return

	;; Random number 1 to 6
	;;
	;; get_number:
	;;   r := get random number
	;;   number := (r_{high nibble} ^ r_{low nibble}) & 0x07
	;;   If number < 2 goto get_number
	;;   number := number - 1
	;;   return
get_number
	randa
	xorra seed
	copyar number
	shiftrr number
	shiftrr number
	shiftrr number
	shiftrr number
	xorra number
	andla 0x07
	copyar number
	subla 2
	btstsc _c,_sr
	jump get_number
	decr number
	return

n_shuffle_leds
	copyli 0x08,counter
	call shuffle_leds
	decrjz counter
	jump n_shuffle_leds
	return

shuffle_leds
	copyli 0x01,_dr
shuffle_leds_loop
	shiftrl _dr
	btstss 6,_dr
	jump shuffle_leds_loop
	return
	end
