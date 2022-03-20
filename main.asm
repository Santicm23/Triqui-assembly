# / - + - + - / Triqui hecho por Michael Gonzales, Jose Manuel Rodriguez y Santiago Castro / - + - + - / #

.data
	endl: .asciiz "\n"
	spc: .asciiz " "
	
	#datos imprimir Matriz
	borde: .asciiz "  +---+---+---+\n"
	iCols:  .asciiz "    0   1   2  \n"
	sepFilas:  .asciiz "|"
	
	matriz: .asciiz " ", " ", " "
			.asciiz " ", " ", " "
			.asciiz " ", " ", " "
	.eqv size 3
	.eqv dataSize 2
	
	menu: .asciiz "\n---Triqui---\n"
	op1: .asciiz "1.Jugar contra el computador\n"
	op2: .asciiz "2.Jugar en local\n"
	op3: .asciiz "3.Cerrar\n"
	opI: .asciiz "\nOpcion invalida\n"
	
	mOp: .asciiz "\nIngrese la opcion: "

.text
	main: #Funcion principal
		la $a3, matriz
		while:# Do while:
			jal imprimirMenu
			
			li $v0, 5
			syscall
			move $t0, $v0
			bne $t0, 1, else1 #Case 1: (jugar contra el computador)
				jal imprimirMatriz #Llamada a la funcion imprimirMatriz
				j while
			else1:
			bne $t0, 2, else2 #Case 2: (Jugar en local)
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

	imprimirMatriz: #funcion imprimirMatriz
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
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
				la $a0, ($t9)
				syscall
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
		
		lw $ra, 0($sp)
		
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
