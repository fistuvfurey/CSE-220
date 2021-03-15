.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"

val_stack : .word 0
op_stack : .word 0

.text
.globl main
main:
  # add code to call and is_digit function
  addi	$a0, $0, '1'			# $a0 = $0 + '2' (initialize arg register to a digit char)  
  jal is_digit # call is_digit
  add		$s0, $v0, $0 		# $s0 = $v0 + $0 (save returned value into $s0)
  


  

end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
