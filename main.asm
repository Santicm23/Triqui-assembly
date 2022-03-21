# / - + - + - / Triqui hecho por Michael Gonzales, Jose Manuel Rodriguez y Santiago Castro / - + - + - / #

.data
	endl: .asciiz "\n"
	spc: .asciiz " "
	
	#datos imprimir Matriz
	borde: .asciiz "  +---+---+---+\n"
	iCols: .asciiz "    0   1   2  \n"
	sepFilas:  .asciiz "|"
	
	p1: .asciiz "o"
	p2: .asciiz "x"
	
	matriz: .word 0, 0, 0
			.word 0, 0, 0
			.word 0, 0, 0
	.eqv size 3
	.eqv dataSize 4
	
	ingFpos: .asciiz "\nIngrese la fila\n"
	ingCpos: .asciiz "\nIngrese la columna\n"
	
	errorIng: .asciiz "\nError: Indice invalido\n"
	errorRep: .asciiz "\nError: La casilla ya ha sido ingresada\n"
	
	menu: .asciiz "\n---Triqui---\n"
	op1: .asciiz "1.Jugar contra el computador\n"
	op2: .asciiz "2.Jugar en local\n"
	op3: .asciiz "3.Cerrar\n"
	opI: .asciiz "\nOpcion invalida\n"
	
	mOp: .asciiz "\nIngrese la opcion: "

.text
	main: #Funcion principal
		la $a3, matriz
		li $s7, 1 #$s7 ser� el que guarde el turno de los jugadores
		while:# Do while:
			jal imprimirMenu
			
			li $v0, 5
			syscall
			move $t0, $v0
			bne $t0, 1, else1 #Case 1: (jugar contra el computador)
				jal imprimirMatriz
				j while
			else1:
			bne $t0, 2, else2 #Case 2: (Jugar en local)
				jal jugarLocal
				j while
			else2:

			beq $t0, 3, exit #condicion salir while
			
			#default
			la $a0, opI
			syscall
		j while
		exit:

	li $v0, 10
	syscall #Fin funcion principal
	
	jugarLocal: #funcion para jugar en local
		sw $ra, 0($sp)
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
			jal cambiarTurno
			addi $t8, $t8, 1
			jal verifFin
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
		bne $a0, 0, elif
			jal printSpace
			lw $ra, 8($sp)
			jr $ra
		elif:
		bne $a0, 1, elseee
			la $a0, p1
			syscall
			lw $ra, 8($sp)
			jr $ra
		elseee:
			la $a0, p2
			syscall
		lw $ra, 8($sp)
	jr $ra
	
	verifCasilla:
		lw $t2, matriz($t1)
		beq $t2, 0, finVerifCasilla
		li $v0, 4
		la $a0, errorRep
		syscall
		j Lloop
		finVerifCasilla:
	jr $ra
	
	verifFin:
		blt $t8, 9, finVerifFin
		li $s6, 1
		finVerifFin:
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