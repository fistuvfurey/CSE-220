.data
p_pair: .word 5 3
p_terms: .word 7 2 3 4 0 -1
q_pair: .word 5 3
q_terms: .word -7 2 1 5 5 12 4 3 0 -1
p: .word 0
q: .word 0
r: .word 0
N: .word 2

.text:
main:
    la $a0, p
    la $a1, p_pair
    jal init_polynomial

    la $a0, p
    la $a1, p_terms
    lw $a2, N
    jal add_N_terms_to_polynomial

    la $a0, q
    la $a1, q_pair
    jal init_polynomial

    la $a0, q
    la $a1, q_terms
    lw $a2, N
    jal add_N_terms_to_polynomial

    la $a0, p
    la $a1, q
    la $a2, r
    jal add_poly
    
    # get first term in r 
    la $a0, r
    li $a1, 1
    jal get_Nth_term
    move $t0, $v0 # save coeff 
    
    # print coeff
    li $v0, 1
    move $a0, $v1 # pass coeff 
    syscall 
    
    # print exp
    move $a0, $t0 
    syscall
    
    # get 2nd term in r 
    la $a0, r
    li $a1, 2
    jal get_Nth_term
    move $t0, $v0 # save coeff 
    
    # print coeff
    li $v0, 1
    move $a0, $v1 # pass coeff 
    syscall
    
    # print exp
    move $a0, $t0 
    syscall
    
    # get 3rd term in r 
    la $a0, r
    li $a1, 4
    jal get_Nth_term
    move $t0, $v0 # save coeff
    
    # print coeff
    li $v0, 1
    move $a0, $v1 # pass coeff 
    syscall
    
    # print exp
    move $a0, $t0 
    syscall
	
    # terminate
    li $v0, 10
    syscall

.include "hw5.asm"
