.data
p_pair: .word 5 2
p_terms: .word 7 1 0 -1
q_pair: .word -5 2
q_terms: .word 1 1 0 -1
p: .word 0
q: .word 0
r: .word 0
N: .word 1

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
    jal mult_poly

    #write test code
    # get first term 
    la $a0, r
    li $a1, 1
    jal get_Nth_term
    
    # print first term
    move $t0, $v0 # save exp
    move $a0, $v1  # pass  coeff
    li $v0, 1
    syscall # print coeff
    move $a0, $t0 # pass exp
    syscall # print exp
    
    # get 2nd term
    la $a0, r
    li $a1, 2
    jal get_Nth_term
    
    # print 2nd term 
    move $t0, $v0 # save exp
    li $v0, 1
    move $a0, $v1 # pass coeff
    syscall # print coeff
    move $a0, $t0 # pass exp
    syscall # print exp 
    
    # get 3rd term
    la $a0, r
    li $a1, 3
    jal get_Nth_term
    
    # print third term
    move $t0, $v0 # save exp
    li $v0, 1
    move $a0, $v1 # pass coeff
    syscall # print coeff
    move $a0, $t0 # pass exp
    syscall # print exp
    
    # terminate 
    li $v0, 10
    syscall

.include "hw5.asm"
