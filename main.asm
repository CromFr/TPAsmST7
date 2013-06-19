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

init_ports_spi:
	;SPI
	LD A, #$0C
	LD SPICR, A
	LD A, #$03
	LD SPISR, A
	LD A, #$5C
	LD SPICR, A

	;PB2 en sortie
	LD	A,PBDDR
	OR	A,#%00000100
	LD	PBDDR,A
	
	;PB2 en push_pull
	LD	A,PBOR
	OR	A,#%00000100
	LD	PBOR,A

	CALL MAX7219_Init
	CALL MAX7219_Clear
	RET


attend_500ms:
	LD X, #151
	LD Y, #250
attend_500ms_boucle
	DEC Y
	CP	Y, #0
	JRNE attend_500ms_boucle

	DEC X
	CP	X, #0
	JRNE attend_500ms_boucle
	
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
	CALL init_ports_spi

	clr counter_unites
	clr counter_dizaines


while
	call afficher
	call attend_500ms
	
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


dummy_rt:	IRET	; ProcÚdure vide : retour au programme principal.



;************************************************************************
;
;  ZONE DE DECLARATION DES VECTEURS D'INTERRUPTION
;
;************************************************************************


	segment 'vectit'


		DC.W	dummy_rt	; Adresse FFE0-FFE1h
SPI_it		DC.W	dummy_rt	; Adresse FFE2-FFE3h
lt_RTC1_it	DC.W	dummy_rt	; Adresse FFE4-FFE5h
lt_IC_it	DC.W	dummy_rt	; Adresse FFE6-FFE7h
at_timerover_it	DC.W	dummy_rt	; Adresse FFE8-FFE9h
at_timerOC_it	DC.W	dummy_rt	; Adresse FFEA-FFEBh
AVD_it		DC.W	dummy_rt	; Adresse FFEC-FFEDh
		DC.W	dummy_rt	; Adresse FFEE-FFEFh
lt_RTC2_it	DC.W	dummy_rt	; Adresse FFF0-FFF1h
ext3_it		DC.W	dummy_rt	; Adresse FFF2-FFF3h
ext2_it		DC.W	dummy_rt	; Adresse FFF4-FFF5h
ext1_it		DC.W	dummy_rt	; Adresse FFF6-FFF7h
ext0_it		DC.W	dummy_rt	; Adresse FFF8-FFF9h
AWU_it		DC.W	dummy_rt	; Adresse FFFA-FFFBh
softit		DC.W	dummy_rt	; Adresse FFFC-FFFDh
reset		DC.W	main		; Adresse FFFE-FFFFh


	END

;************************************************************************
