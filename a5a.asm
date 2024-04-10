// File: a5a.asm
// Author: Connor Swartz
// Date: March 28, 2022
//
// Description:
// A LIFO stack data structure can be implemented using an array. 
// Translate all functions except main() from file: a5aMain.c
// Also contained global variables moved from a5aMain.c
//

define(STACKSIZE, 5)
define(FALSE, 0)
define(TRUE, 1)
define(lr, x30)
define(fp, x29)
define(TF_r, w28)
define(value_r, w27)
define(i_r, w26)
define(stkbase, x20)
define(topbase, x7)


		.data								// .data section (read and write data) initialized by programmer
		.global top							// Enable "top" to be visible to linker
top:		.word -1							// Initialize top variable

		.bss								// .bss section (read and write data) zero initialized
		.global stack							// Enable "stack" to be visible to linker
stack:		.skip STACKSIZE * 4						// Intitialize stack array with 4 * STACKSIZE bytes

		.text								// .text section (read data)
fullError:	.string "\nStack overflow! Cannot push value onto stack.\n"	// Print statement
emptyError:	.string "\nStack underflow! Cannot pop an empty stack.\n"	// Print statement
emptyStack:	.string "\nEmpty stack\n"					// Print statement
currStack:	.string "\nCurrent stack contents:\n"				// Print statement
contents:	.string	"  %d"							// Print statement
stackTop:	.string " <-- top of stack"					// Print statement
emptyLine:	.string "\n"							// Print statement

		.balign 4							// Ensure next instruction address divisible by 4
										// i.e 4-byte aligned to word length of machine
		.global push							// Enable "push" to be visible to linker

// Start push function
push:
		stp	fp, lr, [sp, -16]!					// Save frame pointer (FP) and link register (LR) to the stack
		mov	fp, sp							// Set FP to the top of the stack

		mov	w19, w0							// Set w19 register to first argument

		bl	stackFull						// Branch to stackFull

		cmp	TF_r, FALSE						// Compare TF_r to FALSE
		b.eq	fullFalse						// Branch to fullFalse if TF_r == FALSE 

		ldr	x0, =fullError						// Load fullError into x0
		bl	printf							// Print

		b	pushEnd							// Branch to pushEnd

fullFalse:
		adrp	topbase, top						// Load top into topbase
		add	topbase, topbase, :lo12:top				// Load top into topbase
		ldr	w5, [topbase]						// Set w5 to topbase

		add	w5, w5, 1						// Add 1 to w5 and store in w5

		adrp	stkbase, stack						// Load stack into stkbase
		add	stkbase, stkbase, :lo12:stack				// Load stack into stkbase
		str	w19, [stkbase, w5, SXTW 2]				// Store w19 in stack[top]

		str	w5, [topbase]						// Store top value into topbase

pushEnd:
		ldp	fp, lr, [sp], 16					// Clean lines and restore the stack 
		ret								// Return
// End push function


		.global pop							// Enable "pop" to be visible to linker

// Start pop function
pop:
		stp	fp, lr, [sp, -16]!					// Save frame pointer (FP) and link register (LR) to the stack
		mov	fp, sp							// Set FP to the top of the stack

		bl	stackEmpty						// Branch to stackEmpty

		cmp	TF_r, FALSE						// Compare TF_r to FALSE
		b.eq	emptyFalse						// Branch to emptyFalse if TF_r == FALSE

		ldr	x0, =emptyError						// Load emptyError into x0
		bl	printf							// Print

		mov	w0, -1							// Return -1 in w0

		b	popEnd							// Branch to popEnd

emptyFalse:
		adrp	topbase, top						// Load top into topbase
		add	topbase, topbase, :lo12:top				// Load top into topbase
		ldr	w5, [topbase]						// Set w5 to topbase

		adrp	stkbase, stack						// Load stack into stkbase
		add	stkbase, stkbase, :lo12:stack				// Load stack into stkbase

		ldr	value_r, [stkbase, w5, SXTW 2]				// Set value_r to stack[top]

		sub	w5, w5, 1						// Subtract 1 from w5 and store in w5

		str	w5, [topbase]						// Store top value into topbase

		mov	w0, value_r						// Return value_r in w0

popEnd:
		ldp	fp, lr, [sp], 16					// Clean lines and restore the stack
		ret								// Return
//End pop function


		.global stackFull						// Enable "stackFull" to be visible to linker

// Start stackFull function
stackFull:
		stp	fp, lr, [sp, -16]!					// Save frame pointer (FP) and link register (LR) to the stack
		mov	fp, sp							// Set FP to the top of the stack

		adrp	topbase, top						// Load top into topbase
		add	topbase, topbase, :lo12:top				// Load top into topbase
		ldr	w5, [topbase]						// Set w5 to topbase

		mov	w6, STACKSIZE						// Set w6 to STACKSIZE
		sub	w6, w6, 1						// Subtract 1 from w6 and store in w6

		cmp	w5, w6							// Compare w5 to w6
		b.eq	setTrue							// Branch to setTrue if w5 == w6
		
		mov	TF_r, FALSE						// Set TF_r to FALSE

		b	endStackFull						// Branch to endStackFull
setTrue:
		mov	TF_r, TRUE						// Set TF_r to TRUE

endStackFull:
		ldp	fp, lr, [sp], 16					// Clean lines and restore the stack
		ret								// Return
// End stackFull function


		.global stackEmpty						// Enable "stackEmpty" to be visible to linker

// Start stackEmpty function
stackEmpty:
		stp	fp, lr, [sp, -16]!					// Save frame pointer (FP) and link register (LR) to the stack
		mov	fp, sp							// Set FP to the top of the stack

		adrp	topbase, top						// Load top into topbase
		add	topbase, topbase, :lo12:top				// Load top into topbase
		ldr	w5, [topbase]						// Set w5 to topbase

		mov	w6, -1							// Set w6 to -1

		cmp	w5, w6							// Compare w5 to w6
		b.ne	setFalse						// Branch to setFalse if w5 != w6

		mov	TF_r, TRUE						// Set TF_r to TRUE

		b	endStackEmpty						// Branch to endStackEmpty

setFalse:
		mov	TF_r, FALSE						// Set TF_r to FALSE

endStackEmpty:
		ldp	fp, lr, [sp], 16					// Clean lines and restore the stack
		ret								// Return
// End stackEmpty function
		

		.global display							// Enable "display" to be visible to linker

display:
		stp	fp, lr, [sp, -16]!					// Save frame pointer (FP) and link register (LR) to the stack
		mov	fp, sp							// Set FP to the top of the stack

		bl	stackEmpty						// Branch to stackEmpty

		cmp	TF_r, FALSE						// Compare TF_r to FALSE
		b.eq	displayEmptyFalse					// Branch to displayEmptyFalse if TF_r == FALSE

		ldr	x0, =emptyStack						// Load emptyStack into x0
		bl	printf							// Print

		b	displayEnd						// Branch to displayEnd

displayEmptyFalse:
		ldr	x0, =currStack						// Load currStack into x0
		bl	printf							// Print

		adrp	topbase, top						// Load top into topbase
		add	topbase, topbase, :lo12:top				// Load top into topbase
		ldr	w5, [topbase]						// Set w5 top topbase

		mov	i_r, w5							// Set i_r to w5

		b	loopTest						// Branch to loopTest

loopTop:
		adrp	stkbase, stack						// Load stack into stkbase
		add	stkbase, stkbase, :lo12:stack				// Load stack into stkbase

		ldr	w1, [stkbase, i_r, SXTW 2]				// Load stack[i] into w1

		ldr	x0, =contents						// Load contents into x0
		bl	printf							// Print

		adrp	topbase, top						// Load top into topbase
		add	topbase, topbase, :lo12:top				// Load top into topbase
		ldr	w5, [topbase]						// Set w5 to topbase

		cmp	i_r, w5							// Compare i_r to w5
		b.ne	newLine							// Branch to newLine if i_r != w5

		ldr	x0, =stackTop						// Load stackTop into x0
		bl	printf							// Print

newLine:
		ldr	x0, =emptyLine						// Load emptyLine into x0
		bl	printf							// Print

		sub	i_r, i_r, 1						// Subtract 1 from i_r and store in i_r

loopTest:
		cmp	i_r, 0							// Compare i_r to 0
		b.ge	loopTop							// Branch to loopTop if i_r >= 0

displayEnd:
		ldp	fp, lr, [sp], 16					// Clean lines and restore the stack
		ret								// Return

