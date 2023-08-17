# / - + - + - / Triqui hecho por Michael Gonzalez, Jose Manuel Rodriguez y Santiago Castro / - + - + - / #

.data
	endl: .asciiz "\n"
	spc: .asciiz " "
	
	#datos imprimir Matriz
	borde: .asciiz "  +---+---+---+\n"
	iCols: .asciiz "    0   1   2  \n"
	sepFilas:  .asciiz "|"
	
	p1: .asciiz "o"
	p2: .asciiz "x"
	
	matriz: .word 5, 5, 5
			.word 5, 5, 5
			.word 5, 5, 5
	
	matrizPuntos: .word 0, 0, 0 #7 => 200, 9 => 75, 5 => 25 (solo en la diagonal), 11 => 10, 12 => 5.
				  .word 0, 0, 0
				  .word 0, 0, 0
	
	.eqv size 3
	.eqv dataSize 4
	
	ingFpos: .asciiz "\nIngrese la fila\n"
	ingCpos: .asciiz "\nIngrese la columna\n"
	
	turno: .asciiz "\nTurno del jugador: "
	turnoCmp: .asciiz "\nTurno de la IA: "
	
	errorIng: .asciiz "\nError: Indice invalido\n"
	errorRep: .asciiz "\nError: La casilla ya ha sido ingresada\n"
	
	menu: .asciiz "\n---Triqui---\n"
	op1: .asciiz "1.Jugar contra el computador\n"
	op2: .asciiz "2.Jugar en local\n"
	op3: .asciiz "3.Cerrar\n"
	opI: .asciiz "\nOpcion invalida\n"
	
	mOp: .asciiz "\nIngrese la opcion: "
	
	victoria: .asciiz "\nGano el jugador: "
	empate: .asciiz "\nEs un empate\n"

.text
	main: #Funcion principal
		la $a3, matriz
		la $a2, matrizPuntos
		while:# Do while:
			jal imprimirMenu
			
			li $v0, 5
			syscall
			move $t0, $v0
			bne $t0, 1, else1 #Case 1: (jugar contra el computador)
				jal genRandNum
				la $s7, ($a0) #$s7 sera el que guarde el turno de los jugadores
				jal jugarContraIA
				jal reiniciarMatriz
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
	
	jugarContraIA:
		sw $ra, 0($sp)
		li $s6, 0 # 0 = no terminado, 1 = terminado
		addi $t8, $zero, 0
		jal imprimirMatriz
		IAloop:
			jal printTurnoIA
			
			beq $s7, 2, jugador
				#aqui juega la IA (7,9,5,11,12)
				jal llenarPuntosIA
				jal turnoIA
				j finIA
			jugador: #juega el jugador
				jal inputFila
				move $t1, $v0
				jal inputColumna
				move $t2, $v0
				mul $t1, $t1, size
				add $t1, $t1, $t2
				mul $t1, $t1, dataSize
				la $a0, ($s7)
				jal verifCasillaIA
				sw $a0, matriz($t1)
			finIA:
			
			jal imprimirMatriz
			addi $t8, $t8, 1
			
			jal verifVictoria
			jal verifEmpate
			
			jal cambiarTurno
		beq $s6, 0, IAloop
		lw $ra, 0($sp)
	jr $ra
	
	turnoIA: #funcion que a partir de la matriz de puntos toma la mejor jugada
		addi $t7, $a2, 0
		addi $t3, $zero, 0
		addi $t4, $zero, 0
		lw $t6, matrizPuntos($t4)
		loopTurnoIA:
			lw $t5, ($t7)
			ble $t5, $t6, lowerEq
				addi $t4, $t3, 0
				lw $t6, matrizPuntos($t4)
			lowerEq:
			addi $t7, $t7, dataSize
			addi $t3, $t3, dataSize
		blt $t3, 36, loopTurnoIA
		
		sw $s7, matriz($t4)
	jr $ra
	
	llenarPuntosIA:
		sw $ra, 16($sp)
		
		jal reiniciarPuntos
		
		addi $t9, $a3, 0
		addi $t7, $zero, 0
		
		addi $t1, $zero, 0
		IAFils:
			jal verifFil
			jal valorEqT4
			jal llenarFilIA
			
			addi $t1, $t1, 1
		blt $t1, 3, IAFils
		
		addi $t1, $zero, 0
		IACols:
			add $t9, $a3, $t1
			addi $t7, $t1, 0
			jal verifCol
			jal valorEqT4
			jal llenarColIA
			
			add $t1, $t1, dataSize
		blt $t1, 12, IACols
			
		#Diag 1
			addi $t9, $a3, 0
			jal verifDiag1
			jal valorEqT4
			jal llenarDiag1IA
			
		#Diag 2
			addi $t9, $a3, 8
			jal verifDiag2
			jal valorEqT4
			jal llenarDiag2IA
			
		lw $ra, 16($sp)
	jr $ra
	
	llenarFilIA:
		addi $t3, $zero, 0
		llenFil:
			lw $t5, matriz($t7)
			bne $t5, 5, finLlenFil
				lw $t5, matrizPuntos($t7)
				add $t5, $t5, $t4
				sw $t5, matrizPuntos($t7)
			finLlenFil:
			add $t7, $t7, dataSize
			addi $t3, $t3, 1
		blt $t3, 3, llenFil
	jr $ra
	
	llenarColIA:
		addi $t3, $zero, 0
		llenCol:
			lw $t5, matriz($t7)
			bne $t5, 5, finLlenCol
				lw $t5, matrizPuntos($t7)
				add $t5, $t5, $t4
				sw $t5, matrizPuntos($t7)
			finLlenCol:
			addi $t7, $t7, 12
			addi $t3, $t3, 1
		blt $t3, 3, llenCol
	jr $ra
	
	llenarDiag1IA:
		sw $ra, 20($sp)
		addi $t3, $zero, 0
		addi $t7, $zero, 0
		bne $t4, 25, llenarDiag1
			jal diagEq25
		j finLlenDiag1
		llenarDiag1:
			lw $t5, matriz($t7)
			bne $t5, 5, finLlenDiag1
				lw $t5, matrizPuntos($t7)
				add $t5, $t5, $t4
				sw $t5, matrizPuntos($t7)
			finLlenDiag1:
			addi $t7, $t7, 16
			addi $t3, $t3, 1
		blt $t3, 3, llenarDiag1
		lw $ra, 20($sp)
	jr $ra
	
	llenarDiag2IA:
		sw $ra, 20($sp)
		addi $t3, $zero, 0
		addi $t7, $zero, 8
		bne $t4, 25, llenarDiag2
			jal diagEq25
		j finLlenDiag2
		llenarDiag2:
			lw $t5, matriz($t7)
			bne $t5, 5, finLlenDiag2
				lw $t5, matrizPuntos($t7)
				add $t5, $t5, $t4
				sw $t5, matrizPuntos($t7)
			finLlenDiag2:
			addi $t7, $t7, 8
			addi $t3, $t3, 1
		blt $t3, 3, llenarDiag2
		lw $ra, 20($sp)
	jr $ra
	
	diagEq25:
		addi $t6, $zero, 16
		lw $t6, matriz($t6)
		beq $t6, 2, finDiagEq25
		addi $t7, $zero, 4
		addi $t3, $zero, 0
		loopEq25:
			lw $t5, matriz($t7)
			bne $t5, 5, finDiagEq
				lw $t5, matrizPuntos($t7)
				add $t5, $t5, $t4
				sw $t5, matrizPuntos($t7)
			finDiagEq:
			addi $t7, $t7, 8
			addi $t3, $t3, 1
		blt $t3, 4, loopEq25
		finDiagEq25:
	jr $ra
	
	valorEqT4:
		beq $t4, 7, valor200
		beq $t4, 9, valor75
		beq $t4, 5, valor25
		beq $t4, 11, valor10
		beq $t4, 12, valor5
		j defaultT4
		valor200:
			addi $t4, $zero, 200
		j finVlrT4
		valor75:
			addi $t4, $zero, 75
		j finVlrT4
		valor25:
			addi $t4, $zero, 25
		j finVlrT4
		valor10:
			addi $t4, $zero, 10
		j finVlrT4
		valor5:
			addi $t4, $zero, 5
		j finVlrT4
		defaultT4:
			addi $t4, $zero, 0
		finVlrT4:
	jr $ra
	
	jugarLocal: #funcion para jugar en local
		sw $ra, 0($sp)
		li $s6, 0 # 0 = no terminado, 1 = terminado
		addi $t8, $zero, 0
		li $v0, 4
		jal printEndl
		jal imprimirMatriz
		Lloop:
			jal printTurno
			jal inputFila
			move $t1, $v0
			jal inputColumna
			move $t2, $v0
			mul $t1, $t1, size
			add $t1, $t1, $t2
			mul $t1, $t1, dataSize
			la $a0, ($s7)
			jal verifCasillaLocal
			sw $a0, matriz($t1)
			jal imprimirMatriz
			addi $t8, $t8, 1
			
			jal verifVictoria
			jal verifEmpate
			
			jal cambiarTurno
		beq $s6, 0, Lloop
		lw $ra, 0($sp)
	jr $ra
	
	verifVictoria: #si la suma es 3 o 6
		sw $ra, 16($sp)
	
		addi $t9, $a3, 0
		addi $t4, $zero, 0
		addi $s6, $zero, 1
		
		addi $t1, $zero, 0
		victFils:
			jal verifFil
			
			beq $t4, 3, vict
			beq $t4, 6, vict
			addi $t1, $t1, 1
		blt $t1, 3, victFils
		
		addi $t1, $zero, 0
		victCols:
			add $t9, $a3, $t1
			jal verifCol
			
			beq $t4, 3, vict
			beq $t4, 6, vict
			add $t1, $t1, dataSize
		blt $t1, 12, victCols
			
		#Diag 1
			addi $t9, $a3, 0
			jal verifDiag1
			
			beq $t4, 3, vict
			beq $t4, 6, vict
		
		#Diag 2
			addi $t9, $a3, 8
			jal verifDiag2
			
			beq $t4, 3, vict
			beq $t4, 6, vict
		
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
	
	imprimirMatrizPuntos: #funcion para imprimir la matriz actual
		sw $ra, 4($sp)
		
		addi $t1, $zero, 0
		addi $t7, $a2, 0
		loopP1:
			li $v0, 4
			jal printBorde
			li $v0, 1
			addi $a0, $t1, 0
			syscall
			li $v0, 4
			jal printSpace
			
			addi $t2, $zero, 0
			loopP2:
				jal printSep
				jal printSpace
				li $v0, 1
				lw $a0, ($t7)
				syscall
				li $v0, 4
				jal printSpace
				add $t7, $t7, dataSize
				addi $t2, $t2, 1
			blt $t2, size, loopP2
			
			jal printSep
			jal printEndl
			
			addi $t1, $t1, 1
		blt $t1, size, loopP1
		
		jal printBorde
		la $a0, iCols
		syscall
		
		lw $ra, 4($sp)
		
	jr $ra #fin funcion imprimirMatriz
	
	reiniciarPuntos:
		addi $t1, $zero, 0
		addi $t9, $a3, 0
		addi $t5, $zero, 8
		reiniciarPuntosLoop:
			li $a0, 1
			lw $t7, ($t9)
			bne $t7, 5, noPuntos
				bne $t1, 16, noCentro
					addi $a0, $a0, 1
				noCentro:
				div $t1, $t5
				mfhi $t6
				bne $t6, 0, lado
					addi $a0, $a0, 1
				lado:
				sw $a0, matrizPuntos($t1)
				j finIfPuntos
			noPuntos:
				sw $zero, matrizPuntos($t1)
			finIfPuntos:
			addi $t1, $t1, dataSize
			addi $t9, $t9, dataSize
		blt $t1, 36, reiniciarPuntosLoop
	jr $ra
	
	reiniciarMatriz:
		addi $t1, $zero, 0
		li $a0, 5
		reiniciarLoop:
			sw $a0, matriz($t1)
			addi $t1, $t1, dataSize
		blt $t1, 36, reiniciarLoop
	jr $ra
	
	verifCasillaLocal:
		lw $t2, matriz($t1)
		beq $t2, 5, finVerifCasillaLocal
		li $v0, 4
		la $a0, errorRep
		syscall
		j Lloop
		finVerifCasillaLocal:
	jr $ra
	
	verifCasillaIA:
		lw $t2, matriz($t1)
		beq $t2, 5, finVerifCasillaIA
		li $v0, 4
		la $a0, errorRep
		syscall
		j IAloop
		finVerifCasillaIA:
	jr $ra
	
	verifFil:
		addi $t4, $zero, 0
		addi $t3, $zero, 0
		loopFils:
			lw $t5, ($t9)
			add $t4, $t4, $t5
			add $t9, $t9, dataSize
			addi $t3, $t3, 1
		blt $t3, 3, loopFils
	jr $ra
	
	verifCol:
		addi $t4, $zero, 0
		addi $t3, $zero, 0
		loopCol:
			lw $t5, ($t9)
			add $t4, $t4, $t5
			addi $t9, $t9, 12
			addi $t3, $t3, 1
		blt $t3, 3, loopCol
	jr $ra
	
	verifDiag1:
		addi $t4, $zero, 0
		addi $t3, $zero, 0
		loopDiag1:
			lw $t5, ($t9)
			add $t4, $t4, $t5
			addi $t9, $t9, 16
			addi $t3, $t3, 1
		blt $t3, 3, loopDiag1
	jr $ra
	
	verifDiag2:
		addi $t4, $zero, 0
		addi $t3, $zero, 0
		loopDiag2:
			lw $t5, ($t9)
			add $t4, $t4, $t5
			addi $t9, $t9, 8
			addi $t3, $t3, 1
		blt $t3, 3, loopDiag2
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
	
	printTurnoIA:
		sw $ra, 12($sp)
		li $v0, 4
		beq $s7, 2, printJugador
			la $a0, turnoCmp
		j printMensaje
		printJugador:
			la $a0, turno
		printMensaje:
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
