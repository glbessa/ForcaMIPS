.data
	num_words: .word 36
	max_errors: .word 10
	underline: .ascii "-"
	
	msg1: .asciiz "Chances: "
	msg2: .asciiz "Voce perdeu.\nBusque conhecimento - ET Bilu."
	msg3: .asciiz "Voce ganhou, ajude o proximo a ganhar tambem."
	menu1: .asciiz "Escolha uma opcao:\n\n1- Jogar\n2-Sair\n"
	
	words:
	.asciiz "PALAVRA"
	.asciiz "GABRIEL"
	.asciiz "PNEUMOULTRAMICROSCOPICOSSILICOVULCANOCONIOTICO"
	.asciiz "NEVE"
	.asciiz "LIVRE"
	.asciiz "MICROONDAS"
	.asciiz "TRAJE"
	.asciiz "EUROPA"
	.asciiz "SALGADO"
	.asciiz "ATRIZ"
	.asciiz "MIPS"
	.asciiz "LUCIANO"
	.asciiz "RISC"
	.asciiz "MONOCICLO"
	.asciiz "PIPELINE"
	.asciiz "LENDA"
	.asciiz "OPERACOES"
	.asciiz "FORJAR"
	.asciiz "GRITO"
	.asciiz "COZINHAR"
	.asciiz "ERRO"
	.asciiz "POETA"
	.asciiz "TOSSE"
	.asciiz "PADARIA"
	.asciiz "MENTIRA"
	.asciiz "TORTA"
	.asciiz "ANTICONGELANTE"
	.asciiz "CARIDE"
	.asciiz "CARIBE"
	.asciiz "SOFTWARE"
	.asciiz "PRESENTE"
	.asciiz "LINUX"
	.asciiz "UBUNTU"
	.asciiz "ARCH"
	.asciiz "ROXO"
	.asciiz "VINAGRE"
	.asciiz "RESSACA"

	word_to_print:
	.space 2000
.text
	lw $s0, num_words # num words
	la $s1, words # words base addr
	lb $s2, underline # underline
	lw $s3, max_errors # max_errors
	
	# --------------------------- MENU --------------------------- 
	li $v0, 4 # print string code
	la $a0, menu1 # argument of print string
	syscall
	
	li $v0, 5 # read int
	syscall
	
	beq $v0, 2, exit_option
	# --------------------------- FIM MENU --------------------------- 
	
	jal raffleWord
	move $s4, $v0 # s4 -> raffled word

	move $a0, $s4 # argument of wordSize routine
	jal wordSize
	move $s5, $v0 # s5 -> raffled word length (remaining letters)
		
	jal storeUnderlines
	
	roundInteraction:
	#  --------------- Player Interaction ---------------
		
	li $v0, 4 # print string code
	la $a0, msg1 # argument of print string
	syscall
		
	li $v0, 1 # print int code
	move $a0, $s3 # print chances remaining
	syscall
		
	# line feed
	li $v0, 11 # print char code
	li $a0, 0xA # line feed ASCII code
	syscall
		
	# Print word to guess
	li $v0, 4 # print string code
	la $a0, word_to_print # argument of print string
	syscall
	
	# line feed
	li $v0, 11 # print char code
	li $a0, 0xA # line feed ASCII code
	syscall
	
	# read char from player
	li $v0, 12 # read char
	syscall
	
	move $a0, $v0 # argument of processGuess routine
	jal processGuess
	
	# line feed
	li $v0, 11 # print char code
	li $a0, 0xA # line feed ASCII code
	syscall
	syscall
	
	beq $s3, $0, end_lost
	beq $s5, $0, end_win
	
	j roundInteraction


# --------- Subroutines --------------
	raffleWord:
		move $t0, $s1 # copy of words base addr
		
		move $a1, $s0 # load num_words
		li $v0, 42 # syscall to random
		syscall
		# a0 -> null terminator counter
		
		beq $a0, $0, returnWord
		walkWords:
			addi $t0, $t0, 1
			lb $t1, ($t0) # actual letter
			bne $t1, $0, walkWords
			
			add $a0, $a0, -1
			bne $a0, $0, walkWords
			
			addi $t0, $t0, 1 
		returnWord:
		move $v0, $t0
		# v0 -> raffle word addr
		jr $ra

	# a0 -> word base addr
	wordSize:
		move $t0, $0 # counter
		
		iterateLetters:
			lb $t1, ($a0) # actual letter
			beq $t1, $0, returnSize
			addi $a0, $a0, 1 # inc word base addr
			addi $t0, $t0, 1 # inc counter
			j iterateLetters
			
		returnSize:
		move $v0, $t0
		# v0 -> word length
		jr $ra
	
	storeUnderlines:
		move $t0, $s5 # counter
		la $t1, word_to_print
		
		loopStoreUnderlines:
			sb $s2, ($t1)
			addi $t0, $t0, -1
			addi $t1, $t1, 1
			bne $t0, $0, loopStoreUnderlines
		
		sb $0, ($t1) # put null terminator
		jr $ra
	
	# a0 -> Player char 
	processGuess:
		move $t0, $s4 # raffled word addr
		la $t1, word_to_print # word to guess
		li $t3, 0 # letter exists counter
		
		# convert letter to uppercase
		blt $a0, 97, loopProcessGuess
		addi $a0, $a0, -32
			
		loopProcessGuess:
			lb $t2, ($t0)
			lb $t4, ($t1)
			
			# check if string ended
			beq $t2, $0, returnProcessGuess
			
			beq $a0, $t4, exitProcessGuess
			# check if letter exists in this position
			bne $a0, $t2, continueProcessGuess
			addi $t3, $t3, 1
			sb $t2, ($t1)
			
			continueProcessGuess:
				addi $t0, $t0, 1
				addi $t1, $t1, 1
				j loopProcessGuess
			
		returnProcessGuess:
			bne $t3, $0, exitProcessGuess
			addi $s3, $s3, -1
		
		exitProcessGuess:
			sub $s5, $s5, $t3
			jr $ra
		
	end_lost:
		li $a0, 58
		li $a1, 600
		li $a2, 2
		li $a3, 127
		li $v0, 31   
		syscall
		
		li $v0, 4 # print string code
		la $a0, msg2 # argument of print string
		syscall
		
		j exit
		
	end_win:
		li $a0, 127
		li $a1, 600
		li $a2, 2
		li $a3, 127
		li $v0, 31   
		syscall
	
		li $v0, 4 # print string code
		la $a0, msg3 # argument of print string
		syscall
		
		j exit
		
	exit:
		# line feed
		li $v0, 11 # print char code
		li $a0, 0xA # line feed ASCII code
		syscall
		syscall
		
		li $v0, 4 # print string code
		move $a0, $s4 # argument of print string
		syscall
	
	exit_option:	
		li $v0, 10 # argument of exit
		syscall
