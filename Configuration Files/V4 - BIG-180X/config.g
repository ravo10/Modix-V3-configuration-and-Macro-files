; Modix Big-180X, Generation 4, Single Printhead
; Configuration file for Duet WiFi (firmware version 3.4.4)
; Generated by Modix - Version 3.4.4 Config A 
global config_version = "Version 3.4.4 Config A"
global Generation = 4 ; Generation 4 printer

; General preferences_________________________________________________________
G90															; send absolute coordinates...
M83															; ...but relative extruder moves
M555 P2														; Set output to look like Marlin
M575 P1 B57600 S1											; Set auxiliary serial port baud rate and require checksum (for PanelDue)

; Network_____________________________________________________________________
M550 P"Big 180X V4"											; set printer name
;M551 P"MODIX3D"											; Set password (optional)
M552 S1														; enable network
;M552 P0.0.0.0												; Uncomment this command for using Duet Ethernet board

; Drives_________________________________________________________________________
;Main board______________________________________________________________________
M569 P0 S0													; Physical drive 0. X1
M569 P1 S1													; Physical drive 1. X2
M569 P2 R-1													; Physical drive 2. disabled
M569 P3 S0													; Physical drive 3 goes backwards. E0-Extruder.
M569 P4 R-1													; Physical drive 4. disabled
;Duex5 board_____________________________________________________________________
M569 P5 S0													; Physical drive 5. Y
M569 P6 S0													; Physical drive 6. Z1 (0,600) 
M569 P7 S0													; Physical drive 7. Z2 (0,0) 
M569 P8 S0													; Physical drive 8. Z3 (1800,0) 
M569 P9 S0													; Physical drive 9. Z4 (1800,600) 

;Settings_________________________________________________________
M584 X0:1 Y5 Z6:7:8:9 E3 P3									; Driver mapping
M671 X-185:-185:1868:1868 Y668:-46:-46:668 S30    			; Leadscrew mapping
 
;___________________________________________________________________
M350 X16 Y16 Z16 E16 I1										; Configure microstepping with interpolation
M92 X100 Y100 Z2000 E418.5									; Set steps per mm
M566 X360 Y360 Z120 E3600 P1								; Set maximum instantaneous speed changes (mm/min)
M203 X9000 Y9000 Z200 E12000								; Set maximum speeds (mm/min)
M201 X1000 Y1000 Z120 E1000									; Set accelerations (mm/s^2)
M204 P500													; Set print and travel accelerations  (mm/s^2)
M906 X1800 Y1800 Z1800 E1000 I50							; Set motor currents (mA) and motor idle factor in per cent
M84 S100													; Set idle timeout - 100 seconds

; Axis Limits
M208 X0 Y0 Z-2 S1                               			; set axis minima
M208 X1800 Y600 Z600 S0                          			; set axis maxima

; Endstops
M574 X1 S1 P"xstop + e0stop"                            	; configure switch-type (e.g. microswitch) endstop for low end on X via pin xstop
M574 Y2 S1 P"ystop"                            				; configure switch-type (e.g. microswitch) endstop for low end on Y via pin ystop

; Z-Probe
M558 P9 C"zprobe.in" H5 F120 T6000 A1 R0.7					; BLTouch probing settings
M950 S0 C"duex.pwm5"										; sets the BLTouch probe
M376 H100			                						; Height (mm) over which to taper off the bed compensation
G31 P500 X-25.5 Y26.9										; BLTouch X and Y offset
M557 X{move.axes[0].min + sensors.probes[0].offsets[0] + 1, move.axes[0].max + sensors.probes[0].offsets[0] - 1} Y{move.axes[1].min + sensors.probes[0].offsets[1] + 1, move.axes[1].max + sensors.probes[0].offsets[1] - 1} P30:10
; The M557 is used to define the mesh grid area. It uses the P parameter to set the amount of probing points. P10:10 would be a 10x10 grid. Supports up to a 21x21 grid. 
M98 P"config_probe.g"										; Load the Z-offset from the config_probe.g file
; The Z_offset value is now set in config_probe.g, not in config.g
; Adjust the values there, do not adjust anything here.

; Automatic Z Offset Calibration____________________________________
M574 Z1 S1 P"!duex.e5stop"									; configure switch-type for Automatic z-offset

; Heaters___________________________________________________________
M140 H-1                                       				; disable heated bed (overrides default heater mapping)

;E0_________________________________________________________________
;M308 S0 P"e0temp" Y"thermistor" T100000 B4725   			; configure sensor 0 as thermistor on pin e0temp
;M308 S0 P"spi.cs1" Y"rtd-max31865"							; Configure sensor 0 as PT100 via the daughterboard
M308 S0 P"e0temp" Y"pt1000"									; Configure sensor 0 as PT1000 on pin e0temp
M950 H0 C"e0heat" T0                            			; create nozzle heater output on e0heat and map it to sensor 0
M98 P"PID_tune_E0.g" R1										; PID calibration
; M307 is not used in this config. The M307 files are stored and executed from the PID_tune_E0.g file. You can verify the values there.
M143 H0 S285                                    			; set temperature limit for heater 0 to 285C

; Fans______________________________________________________________
M950 F0 C"fan0" Q500                            			; create fan 0 on pin fan0 and set its frequency
M106 P0 S0 H-1 C"Primary blower fan"						; set fan 0 value. Thermostatic control is turned on
M950 F2 C"duex.fan7" Q500                            		; create LED on pin fan2 and set its frequency
M106 P2 S0 H-1 C"LED"                              			; Disable fan channel for LED
M106 P2 S255												; LED on by default
M950 F3 C"duex.fan5" Q500                       			; create fan 3 on pin fan1 and set its frequency
M106 P3 S255 H0 T45                             			; set fan 3 value. Thermostatic control is turned on

; Tools______________________________________________________________
;T0_________________________________________________________________
M563 P0 S"E0 Primary" D0 H0 F0                  			; define tool 0
G10 P0 X0 Y0 Z0                                 			; set tool 0 axis offsets
G10 P0 R0 S210                                  			; set initial tool 0 active and standby temperatures to 0C

; Automatic power saving____________________________________________
M911 S22.5 R29.0 P"M913 X0 Y0 G91 M83 G1 Z3 E-5 F1000"     	; Set voltage thresholds and actions to run on power loss. Power Failure Pause

; Filament sensor settings__________________________________________________
; Primary hotend Clog detector__________________________________________________
M950 J0 C"duex.e2stop" 									; create Input Pin 0 on pin E2 to for M581 Command.
M581 T1 P0 S0 R1 											; Runout switch for E0 As External Trigger
M591 D0 P7 C"e1stop" S1 L3.2 E10 R10:300					; Clog Detector E0 [Add-On]

; Crash detector__________________________________________________
M950 J2 C"duex.e4stop" 									; create Input Pin 2 on pin E4 to for M581 Command.
;M581 P2 T0 S0 R0											; Crash Detector   [Add-On]

; Emergency stop button__________________________________________________
M950 J3 C"duex.e6stop" 									; create Input Pin 2 on pin E4 to for M581 Command.
;M581 P3 T0 S1 R0 											; Emergency stop [Add-On]
;M581 P3 T1 S1 R1											; Emergency stop, pause the print [Add-On]
;M581 P3 T1 S1 R0 											; Emergency stop, pause always [Add-On]