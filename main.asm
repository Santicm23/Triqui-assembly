# / - + - + - / Triqui hecho por Michael Gonzales, Jose Manuel Rodriguez y Santiago Castro / - + - + - / #

.data
	endl: .asciiz "\n"
	spc: .asciiz " "
	
	#datos imprimir Matriz
	borde: .asciiz "  +---+---+---+\n"
	iCols:  .asciiz "    0   1   2  \n"
	sepFilas:  .asciiz "|"
	
	p1: .asciiz "o"
	p2: .asciiz "x"
	
	matriz: .word 5, 5, 5
			.word 5, 5, 5
			.word 5, 5, 5
	.eqv size 3
	.eqv dataSize 4
	
	ingFpos: .asciiz "\nIngrese la fila\n"
	ingCpos: .asciiz "\nIngrese la columna\n"
	
	turno: .asciiz "\nTurno del jugador "
	
	errorIng: .asciiz "\nError: Indice invalido\n"
	errorRep: .asciiz "\nError: La casilla ya ha sido ingresada\n"
	
	menu: .asciiz "\n---Triqui---\n"
	op1: .asciiz "1.Jugar contra el computador\n"
	op2: .asciiz "2.Jugar en local\n"
	op3: .asciiz "3.Cerrar\n"
	opI: .asciiz "\nOpcion invalida\n"
	
	mOp: .asciiz "\nIngrese la opcion: "
	
	victoria: .asciiz "\nGano el jugador "
	empate: .asciiz "\nEs un empate\n"

.text
	main: #Funcion principal
		la $a3, matriz
		while:# Do while:
			jal imprimirMenu
			
			li $v0, 5
			syscall
			move $t0, $v0
			bne $t0, 1, else1 #Case 1: (jugar contra el computador)
				jal genRandNum
				la $s7, ($a0) #$s7 sera el que guarde el turno de los jugadores
				jal imprimirMatriz
				j while
			else1:
			bne $t0, 2, else2 #Case 2: (Jugar en local)
				jal genRandNum
				la $s7, ($a0) #$s7 sera el que guarde el turno de los jugadores
				jal jugarLocal
				jal reiniciarMatriz
				j while
			else2:

			beq $t0, 3, exit #condicion salir while
			
			#default
			li $v0, 4
			la $a0, opI
			syscall
		j while
		exit:

	li $v0, 10
	syscall #Fin funcion principal
	
	jugarLocal: #funcion para jugar en local
		sw $ra, 0($sp)
		jal printTurno
		li $s6, 0 # 0 = no terminado, 1 = terminado
		addi $t8, $zero, 0
		Lloop:
			jal inputFila
			move $t1, $v0
			jal inputColumna
			move $t2, $v0
			mul $t1, $t1, size
			add $t1, $t1, $t2
			mul $t1, $t1, dataSize
			la $a0, ($s7)
			jal verifCasilla
			sw $a0, matriz($t1)
			jal imprimirMatriz
			addi $t8, $t8, 1
			
			jal verifVictoria
			jal verifEmpate
			
			jal cambiarTurno
		beq $s6, 0, Lloop
		lw $ra, 0($sp)
	jr $ra

	imprimirMatriz: #funcion para imprimir la matriz actual
		sw $ra, 4($sp)
		
		addi $t1, $zero, 0
		addi $t9, $a3, 0
		loop1:
			li $v0, 4
			jal printBorde
			li $v0, 1
			addi $a0, $t1, 0
			syscall
			li $v0, 4
			jal printSpace
			
			addi $t2, $zero, 0
			loop2:
				jal printSep
				jal printSpace
				li $v0, 1
				lw $a0, ($t9)
				jal printChar
				li $v0, 4
				jal printSpace
				add $t9, $t9, dataSize
				addi $t2, $t2, 1
			blt $t2, size, loop2
			
			jal printSep
			jal printEndl
			
			addi $t1, $t1, 1
		blt $t1, size, loop1
		
		jal printBorde
		la $a0, iCols
		syscall
		
		lw $ra, 4($sp)
		
	jr $ra #fin funcion imprimirMatriz
	
	reiniciarMatriz:
		addi $t1, $zero, 0
		li $a0, 5
		reiniciarLoop:
			sw $a0, matriz($t1)
			addi $t1, $t1, dataSize
		blt $t1, 36, reiniciarLoop
	jr $ra
	
	verifCasilla:
		lw $t2, matriz($t1)
		beq $t2, 5, finVerifCasilla
		li $v0, 4
		la $a0, errorRep
		syscall
		j Lloop
		finVerifCasilla:
	jr $ra
	
	verifVictoria: #si la suma es 3 o 6
		sw $ra, 16($sp)
	
		addi $t9, $a3, 0
		addi $t4, $zero, 0
		addi $s6, $zero, 1
		
		addi $t1, $zero, 0
		victFils:
			addi $t3, $zero, 0
			vict2Fils:
				lw $t5, ($t9)
				add $t4, $t4, $t5
				add $t9, $t9, dataSize
				addi $t3, $t3, 1
			blt $t3, 3, vict2Fils
			
			beq $t4, 3, vict
			beq $t4, 6, vict
			addi $t4, $zero, 0
			addi $t1, $t1, 1
		blt $t1, 3, victFils
		
		addi $t1, $zero, 0
		victCols:
			addi $t3, $zero, 0
			add $t9, $a3, $t1
			vict2Cols:
				lw $t5, ($t9)
				add $t4, $t4, $t5
				addi $t9, $t9, 12
				addi $t3, $t3, 1
			blt $t3, 3, vict2Cols
			
			beq $t4, 3, vict
			beq $t4, 6, vict
			addi $t4, $zero, 0
			add $t1, $t1, dataSize
		blt $t1, 12, victCols
			
		#Diag 1
			addi $t1, $zero, 0
			addi $t9, $a3, 0
			vict1Diags:
				lw $t5, ($t9)
				add $t4, $t4, $t5
				addi $t9, $t9, 16
				addi $t1, $t1, 1
			blt $t1, 3, vict1Diags
			
			beq $t4, 3, vict
			beq $t4, 6, vict
			addi $t4, $zero, 0
		
		#Diag 2
			addi $t3, $zero, 0
			addi $t9, $a3, 8
			vict2Diags:
				lw $t5, ($t9)
				add $t4, $t4, $t5
				addi $t9, $t9, 8
				addi $t3, $t3, 1
			blt $t3, 3, vict2Diags
			
			beq $t4, 3, vict
			beq $t4, 6, vict
			addi $t4, $zero, 0
		
		addi $s6, $zero, 0
		j finVict
		vict:
			li $v0, 4
			la $a0, victoria
			syscall
			la $a0, ($s7)
			jal printChar
			jal printEndl
		finVict:
		lw $ra, 16($sp)
	jr $ra
	
	verifEmpate:
		blt $t8, 9, finVerifEmpate
		beq $s6, 1, finVerifEmpate
		li $s6, 1
		li $v0, 4
		la $a0, empate
		syscall
		finVerifEmpate:
	jr $ra
	
	#----Funciones que permiten entender mejor el codigo:----#
	imprimirMenu:
		li $v0, 4
		la $a0, menu
		syscall
		la $a0, op1
		syscall
		la $a0, op2
		syscall
		la $a0, op3
		syscall
		la $a0, mOp
		syscall
	jr $ra
	
	printChar: #funcion para imprimir el caracter correspondiente al valor de la matriz $a0 dado
		sw $ra, 8($sp)
		li $v0, 4
		bne $a0, 1, elif
			la $a0, p1
			syscall
			lw $ra, 8($sp)
			jr $ra
		elif:
		bne $a0, 2, elseee
			la $a0, p2
			syscall
			lw $ra, 8($sp)
			jr $ra
		elseee:
			jal printSpace
		lw $ra, 8($sp)
	jr $ra
	
	printSep:
		la $a0, sepFilas
		syscall
	jr $ra
	
	printBorde:
		la $a0, borde
		syscall
	jr $ra
	
	printSpace:
		la $a0, spc
		syscall
	jr $ra
	
	printEndl:
		la $a0, endl
		syscall
	jr $ra
	
	inputFila: #funcion para recibir el indice de las filas y asegurarse de que este entre 0 y 2
		j lFila
		errF:
			li $v0, 4
			la $a0, errorIng
			syscall
		lFila:
			li $v0, 4
			la $a0, ingFpos
			syscall
			li $v0, 5
			syscall
		blt $v0, 0, errF
		bgt $v0, 2, errF
	jr $ra
	
	inputColumna: #funcion para recibir el indice de las columnas y asegurarse de que este entre 0 y 2
		j lColu
		errC:
			li $v0, 4
			la $a0, errorIng
			syscall
		lColu:
			li $v0, 4
			la $a0, ingCpos
			syscall
			li $v0, 5
			syscall
		blt $v0, 0, errC
		bgt $v0, 2, errC
	jr $ra
	
	cambiarTurno:
		bne $s7, 2, elsee
			li $s7, 1
		jr $ra
		elsee:
			li $s7, 2
	jr $ra
	
	printTurno:
		sw $ra, 12($sp)
		li $v0, 4
		la $a0, turno
		syscall
		la $a0, ($s7)
		jal printChar
		jal printEndl
		lw $ra, 12($sp)
	jr $ra

	genRandNum:
		li $a1, 2  #Here you set $a1 to the max bound.
	    li $v0, 42  #generates the random number.
	    syscall
    	add $a0, $a0, 1  #Here you add the lowest bound
    jr $ra
