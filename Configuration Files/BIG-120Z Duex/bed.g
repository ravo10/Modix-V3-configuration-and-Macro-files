; Modix bed.g file for duex enabled printers
; Configuration file for Duet WiFi (firmware version 3.4.1)
; Generated by Modix - Version 3.4.1 Config D

M98 P"config_probe.g"   											; insure probe is using most recent configuration values
M280 P0 S60 I1														; clear any probe errors

if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed	; If the printer hasn't been homed, home it
	M280 P0 S60 I1														; clear any probe errors
	G29 S2                      										; cancel mesh bed compensation
	G91                    												; relative positioning
	M913 X50 															; X axis 50% power
	G1 H2 Z5 F200          												; lift Z relative to current position
	G1 H1 X{(move.axes[0].max+5)*-1} Y{move.axes[1].max+5} F3000  		; move quickly to X and Y axis endstops and stop there (first pass)
	G1 H2 X5 Y-5 F600      												; go back a few mm
	G1 H1 X{(move.axes[0].max+5)*-1} Y{move.axes[1].max+5} F600  		; move slowly to X and Y axis endstops once more (second pass)
	M913 X100 															; X axis 100% power
	G90                    												; absolute positioning
	G1 X{move.axes[0].min+5} Y{move.axes[1].min+5} F6000 				; move to front left
	G1 F600																; reduce speed
	G30                    												; home Z by probing the bed

M280 P0 S60 I1														; clear any probe errors
G29 S2                       										; cancel mesh bed compensation
M290 R0 S0                   										; cancel baby stepping

G90                          										; absolute moves
G1 Z5 F99999                 										; insure Z starting position is high enough to avoid probing errors
G1 X{move.axes[0].min+2} Y{move.axes[1].min+2} F6000 				; move to front left

G30                          										; do single probe which sets Z to trigger height of Z probe

; --- level bed ---
while true
	M280 P0 S60 I1																													; clear any probe errors
	G30 P0 X{move.axes[0].min + sensors.probes[0].offsets[0] + 2} Y{move.axes[1].min + sensors.probes[0].offsets[1] + 2} Z-99999	; Probe near front left leadscrew
	M280 P0 S60 I1																													; clear any probe errors
	G30 P1 X{move.axes[0].max + sensors.probes[0].offsets[0] - 2} Y{move.axes[1].min + sensors.probes[0].offsets[1] + 2} Z-99999	; Probe near front right leadscrew
	M280 P0 S60 I1																													; clear any probe errors
	G30 P2 X{move.axes[0].max + sensors.probes[0].offsets[0] - 2} Y{move.axes[1].max + sensors.probes[0].offsets[1] - 2} Z-99999	; Probe near rear right leadscrew
	M280 P0 S60 I1																													; clear any probe errors
	G30 P3 X{move.axes[0].min + sensors.probes[0].offsets[0] + 2} Y{move.axes[1].max + sensors.probes[0].offsets[1] - 2} Z-99999 S4	; Probe near rear left leadscrew

	if move.calibration.initial.deviation < 0.02
		echo "Your bed is within 0.02 mm between the corners. The difference was " ^ move.calibration.initial.deviation ^ "mm. You can proceed to print"
		break
	; check pass limit - abort if pass limit reached
	if iterations = 10
		M291 P"Bed Leveling Aborted" R"Pass Limit Reached"
		abort "Bed Leveling Aborted - Pass Limit Reached"

G1 X{move.axes[0].min+2} Y{move.axes[1].min+2} F6000 				; move to front left
G30																	; do single probe which sets Z to trigger height of Z probe