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
  # add code to call and test stack_push function
  la		$a2, val_stack		# load address of stack into $a2
  li		$a0, 3		# $a0 = 2 (load element to push onto the stack)
  li		$a1, 4		# $a1 = 0 (load current top of the stack)
  jal		stack_push				# jump to stack_push and save position to $ra
  add		$s0, $0, $v0		# $s0 = $0 + $v0 (save return value of stack_push into $s0)

  
  
  


  
end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
