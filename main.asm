ST7/

;************************************************************************
; TITLE:                
; AUTHOR:               
; DESCRIPTION:          
;************************************************************************

	TITLE "SQUELET.ASM"
	
	MOTOROLA
	
	#include "ST7Lite2.INC"

	; Enlever le commentaire si vous utilisez les afficheurs
	#include "MAX7219.INC"


;************************************************************************
;
;  ZONE DE DECLARATION DES SYMBOLES
;
;************************************************************************



;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES SYMBOLES
;
;************************************************************************

	
	BYTES
	
	segment byte 'ram0'

;************************************************************************
;
;  ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************


counter_unites DS.B 1
counter_dizaines DS.B 1

counter_state DS.B 1

compte_it DS.B 1

;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************


        WORDS

	segment byte 'rom'

;************************************************************************
;
;  ZONE DE DECLARATION DES CONSTANTES
;
;************************************************************************




;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES CONSTANTES
;
;************************************************************************

;------------------------------------------------------------------------

;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES
;
;************************************************************************


;===============================> Initialisation du programme
init_chip:
	CALL init_ports
	CALL init_spi
	CALL init_int
	CALL init_oscRC
	RET


init_spi:
	LD A, #$0C
	LD SPICR, A
	LD A, #$03
	LD SPISR, A
	LD A, #$5C
	LD SPICR, A

	CALL MAX7219_Init
	CALL MAX7219_Clear
	RET

init_int:
	;ei0 et ei 3 utilisées en front desc seul
	LD A, EICR
	AND A, #%10111101
	OR  A, #%10000010
	LD EICR, A
	
	;PB0 pour ei3 et PA3 pour ei0
	LD A, EISR
	OR  A, #%00000011
	AND A, #%00111111
	LD EISR, A
	RET

init_ports:
	;PA3 en entrée
	LD	A,PADDR
	AND	A,#%11110111
	LD	PADDR,A
	
	;PA3 en pull-up
	LD	A,PAOR
	OR	A,#%00001000
	LD	PAOR,A

	;PB2 en sortie + PB0 entrée
	LD	A,PBDDR
	OR	A,#%00000100
	AND	A,#%11111110
	LD	PBDDR,A
	
	;PB2 en push_pull + PB0 pull up
	LD	A,PBOR
	OR	A,#%00000101
	LD	PBOR,A
	RET

init_timer:
	ld A, #%00000000
	ld LTCSR1, A
	RET

init_oscRC:
RCCR0	EQU	$FFDE
	LD	A, RCCR0
	LD	RCCR, A
	RET




timer_8ms_interrupt:
	ld X, compte_it
	inc X
	ld compte_it, X

	ld A, LTCSR1

	IRET

attend_500ms:
	clr compte_it

	;Lancer timer
	ld A, LTCSR1
	or A, #%00010000
	ld LTCSR1, A

attend_500ms_boucle
	ld A, compte_it
	cp A, #63
	jrult attend_500ms_boucle

	ld A, LTCSR1
	and A, #%11101111
	ld LTCSR1, A
	RET

afficher:
	LD A, #2
	LD DisplayChar_Digit, A
	LD A, counter_unites
	LD DisplayChar_Character, A
	CALL MAX7219_DisplayChar

	LD A, #1
	LD DisplayChar_Digit, A
	LD A, counter_dizaines
	LD DisplayChar_Character, A
	CALL MAX7219_DisplayChar
	RET
	
	
marche_interrupt:
	ld A, #1
	ld counter_state, A
	iret

arret_interrupt:
	ld A, #0
	ld counter_state, A
	iret



;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES SOUS-PROGRAMMES
;
;************************************************************************


;************************************************************************
;
;  PROGRAMME PRINCIPAL
;
;************************************************************************

main:
	RSP			; Reset Stack Pointer
	RIM
	CALL init_chip

	clr counter_unites
	clr counter_dizaines
	ld A, #1
	ld counter_state, A


while
	call afficher
	call attend_500ms
	
	ld A, counter_state
	cp A, #1
	jrne while
	
	inc counter_unites
	ld A, counter_unites
	cp A, #10
	jrne while

	clr counter_unites
	inc counter_dizaines
	ld A, counter_dizaines
	cp A, #10
	jrne while

	clr counter_dizaines
	jp while


		
fin
	JP	fin



;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES D'INTERRUPTION
;
;************************************************************************


dummy_rt:	IRET	; Procédure vide : retour au programme principal.



;************************************************************************
;
;  ZONE DE DECLARATION DES VECTEURS D'INTERRUPTION
;
;************************************************************************


	segment 'vectit'


		DC.W	dummy_rt	; Adresse FFE0-FFE1h
SPI_it		DC.W	dummy_rt	; Adresse FFE2-FFE3h
lt_RTC1_it	DC.W	timer_8ms_interrupt	; Adresse FFE4-FFE5h
lt_IC_it	DC.W	dummy_rt	; Adresse FFE6-FFE7h
at_timerover_it	DC.W	dummy_rt	; Adresse FFE8-FFE9h
at_timerOC_it	DC.W	dummy_rt	; Adresse FFEA-FFEBh
AVD_it		DC.W	dummy_rt	; Adresse FFEC-FFEDh
		DC.W	dummy_rt	; Adresse FFEE-FFEFh
lt_RTC2_it	DC.W	dummy_rt	; Adresse FFF0-FFF1h
ext3_it		DC.W	marche_interrupt	; Adresse FFF2-FFF3h
ext2_it		DC.W	dummy_rt	; Adresse FFF4-FFF5h
ext1_it		DC.W	dummy_rt	; Adresse FFF6-FFF7h
ext0_it		DC.W	arret_interrupt	; Adresse FFF8-FFF9h
AWU_it		DC.W	dummy_rt	; Adresse FFFA-FFFBh
softit		DC.W	dummy_rt	; Adresse FFFC-FFFDh
reset		DC.W	main		; Adresse FFFE-FFFFh


	END

;************************************************************************
