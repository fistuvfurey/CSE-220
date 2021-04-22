# add test cases to data section
# Test your code with different Network layouts
# Don't assume that we will use the same layout in all our tests
.data
Name1: .asciiz "Cacophonix"
Name2: .asciiz "Getafix"
Name_prop: .asciiz "NAME"
Frnd_prop: .asciiz "FRIEND"

Network:
  .word 5   #total_nodes (bytes 0 - 3)
  .word 10  #total_edges (bytes 4- 7)
  .word 12  #size_of_node (bytes 8 - 11)
  .word 12  #size_of_edge (bytes 12 - 15)
  .word 0   #curr_num_of_nodes (bytes 16 - 19)
  .word 0   #curr_num_of_edges (bytes 20 - 23)
  .asciiz "NAME" # Name property (bytes 24 - 28)
  .asciiz "FRIEND" # FRIEND property (bytes 29 - 35)
   # nodes (bytes 36 - 95)	
  .byte 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0	
   # set of edges (bytes 96 - 215)
  .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

.text:
main:
	# create person1 node
	la $a0, Network
	jal create_person
	move $s0, $v0 # save person1 address
	
	# give person1 name1
	la $a0, Network
	move $a1, $s0 # pass newly created person1 address
	la $a2, Name_prop
	la $a3, Name1
	jal add_person_property
	
	# create person2 node
	la $a0, Network
	jal create_person
	move $s1, $v0 # save person2 address
	
	# give person2 name2
	la $a0, Network
	move $a1, $s1 # pass newly created person2 address
	la $a2, Name_prop
	la $a3, Name2
	jal add_person_property
	
	# add relation between person1 and person2
	la $a0, Network
	move $a1, $s0 # pass person1 address
	move $a2, $s1 # pass person2 address
	jal add_relation
	
	# add property to newly created relation 
	la $a0, Network
	move $a1, $s0 # pass person1 address
	move $a2, $s1 # pass person2 address
	la $a3, Frnd_prop
	addi $sp, $sp, -4
	li $s1, 1
	sw $s1, 0($sp) 
	jal add_relation_property
	
	# terminate
	li $v0, 10
	syscall
	
.include "hw4.asm"
