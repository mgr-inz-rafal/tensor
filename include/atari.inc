XITVBV	= $E462		;vector to process deferred VBLANK
SETVBV	= $E45C		;vector to set VBLANK parameters 
SDMCTL	= $022F		;SAVE DMACTL REGISTER 
PCOLR0	= $02C0		;1-byte player-missile 0 color/luminance
PCOLR1	= $02C1		;1-byte player-missile 1 color/luminance
PCOLR2	= $02C2		;1-byte player-missile 2 color/luminance
PCOLR3	= $02C3		;1-byte player-missile 3 color/luminance
GRACTL	= $D01D		;graphic control 
GPRIOR	= $026F		;GLOBAL PRIORITY CELL
STICK0	= $0278		;1-byte joystick 0
STRIG0	= $0284		;1-byte joystick trigger 0
CHBAS	= $02F4		;CHBAS REGISTER RAM
SDLSTL	= $0230		;SAVE DISPLAY LIST LOW BYTE
ATRACT	= $4D		;ATRACT FLAG
CH		= $02FC		;GLOBAL VARIABLE FOR KEYBOARD 
VDSLST	equ $200

CLR0	= $2C4          	
CLR1	= $2C5
CLR2	= $2C6
CLR3	= $2C7
CLR4	= $2C8
