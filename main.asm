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

can_result DS.B 2

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
	CALL init_lcd
	CALL init_can
	RET

init_lcd:
	LD A, #$0C
	LD SPICR, A
	LD A, #$03
	LD SPISR, A
	LD A, #$5C
	LD SPICR, A

	CALL MAX7219_Init
	CALL MAX7219_Clear
	RET

init_can:
	;Use PB0/nSS/AIN0 as input
	ld A, ADCCSR
	and A, #%11111100
	ld ADCCSR, A
	RET


can_convert:
	;Set ADON bit to start conversion
	ld A, ADCCSR
	or A, #%00100000
	ld ADCCSR, A

can_convert_boucle
	ld A, ADCCSR
	and A, #%00100000
	cp A, #%00100000
	jrne can_convert_boucle
	;end boucle

	;load results
	push X

	;reformat values
	ld A, ADCDRH
	srl A
	srl A
	or A, ADCDRL
	ld X, #1
	ld (can_result,X), A

	ld A, ADCDRL
	rlc A
	rlc A
	and A, #%00000011
	ld X, #0
	ld (can_result,X), A
	
	pop X
	RET



afficher:
	ld A, #4
	ld DisplayChar_Digit, A
	ld X, #1
	ld A, (can_result,X)
	ld DisplayChar_Character, A
	call MAX7219_DisplayChar
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
	CALL init_chip



while
	call can_convert
	call afficher

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
