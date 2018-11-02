turtles-own [drug1_resistance drug2_resistance]

;; Setup
to setup
  clear-all
  set drug1_enabled false
  set drug2_enabled false
  ask patches [set pcolor white]
  setup-disease
  reset-ticks
end

;Initializes the disease.
to setup-disease
  create-turtles initial_disease_count [
    initialise-bacteria
    random-range drug1_base_resistance_min drug1_base_resistance_max
    random-range drug2_base_resistance_min drug2_base_resistance_max
  ]
end

;;Performs per-tick operations in the model.
to go
  if((count turtles = 0) or stop-after-drug-course-check)[stop]

  toggle-drugs
  apply-drugs

  ask-concurrent turtles[
    if(transformation_enabled) [bacterial-transformation]
    if(ticks mod spread_rate = 0) [spread-disease]
  ]

  tick
end

;check to see if program should be stopped after the course
to-report stop-after-drug-course-check
  ifelse(stop_after_drug_course)[
    let stop_time max list drug1_end_tick drug2_end_tick
    ifelse(stop_time != 0 and ticks >= stop_time)
    [report true]
    [report false]
  ]
  [report false]
end

;Toggles on/off drug application based on pre-set variables.
to toggle-drugs
  ;Check to enable the drugs
  if(drug1_start_tick != 0 and drug1_start_tick = ticks)[set drug1_enabled true]
  if(drug2_start_tick != 0 and drug2_start_tick = ticks)[set drug2_enabled true]

  ;Check to disable the drugs
  if(drug1_end_tick != 0 and drug1_end_tick = ticks)[set drug1_enabled false]
  if(drug2_end_tick != 0 and drug2_end_tick = ticks)[set drug2_enabled false]
end

;;Applies the drugs at the specified rate.
to apply-drugs
  if(ticks != 0) [
    if(drug1_enabled and (ticks - drug1_start_tick) mod drug1_interval = 0) [add-drug1]
    if(drug2_enabled and (ticks - drug2_start_tick) mod drug2_interval = 0) [add-drug2]
  ]
end

;;Antibiotics

;Applies a drug effect to the simulation.
to add-drug1
  ask-concurrent turtles[
    ifelse(drug1_resistance < random 100)
    [die]
    [if(drug1_resistance != 100) [set drug1_resistance drug1_resistance + random drug1_max_resistance_gain]]
  ]
end

;Applies a drug effect to the simulation.
to add-drug2
  ask-concurrent turtles[
    ifelse(drug2_resistance < random 100)
    [die]
    [if(drug2_resistance != 100) [set drug2_resistance drug2_resistance + random drug2_max_resistance_gain]]
  ]
end

;;Disease

;Transforms bacteria (bacterial sex) one bacteria shares its genetic information with another
to bacterial-transformation
  if(transformation_chance >= random 100)[
    let donor_d1 drug1_resistance
    let donor_d2 drug2_resistance
    let recipient one-of other turtles
    if (recipient != nobody)[
      ask one-of other turtles[
        if(donor_d1 > drug1_resistance)[set drug1_resistance random-range drug1_resistance donor_d1]
        if(donor_d2 > drug2_resistance)[set drug2_resistance random-range drug2_resistance donor_d2]
      ]
    ]
  ]
end

;Spreads the disease to any neigbouring patches of the current disease.
to spread-disease
  if(spread_chance >= random 100)[hatch 1 [initialise-bacteria drug1_resistance drug2_resistance]]
end

to initialise-bacteria[d1_resistance d2_resistance]
  set color red
  set xcor random-xcor
  set ycor random-ycor
  set drug1_resistance mutate-resistance d1_resistance
  set drug2_resistance mutate-resistance d2_resistance
end

;Applies a mutation factor to the passed in resistance based on the mutation chance variable.
to-report mutate-resistance [resistance]
  ifelse(mutation_chance > random 100) [
    let modified_resistance resistance
    let rand random 2

    ifelse(rand = 0)
    [set modified_resistance modified_resistance - 1]
    [set modified_resistance modified_resistance + 1]

    if(modified_resistance < 0)[set modified_resistance 0]
    if(modified_resistance > 100)[set modified_resistance 100]

    report modified_resistance
  ]
  [report resistance]
end

to-report random-range [min-range max-range]
  report random (max-range - min-range) + min-range
end
@#$#@#$#@
GRAPHICS-WINDOW
1135
10
1568
444
-1
-1
1.654
1
10
1
1
1
0
1
1
1
-128
128
-128
128
0
0
1
ticks
30.0

BUTTON
15
10
79
43
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
125
10
188
43
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
55
187
88
initial_disease_count
initial_disease_count
1
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
30
340
200
373
spread_rate
spread_rate
10
1000
180.0
10
1
ticks
HORIZONTAL

SLIDER
210
340
380
373
spread_chance
spread_chance
1
100
50.0
1
1
%
HORIZONTAL

SLIDER
30
180
203
213
drug1_interval
drug1_interval
100
10000
1541.0
1
1
ticks
HORIZONTAL

PLOT
685
455
1125
775
Mean Drug Resistance
Ticks
Resistance Level
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Drug 1" 1.0 0 -2674135 true "" "plot mean [drug1_resistance] of turtles"
"Drug 2" 1.0 0 -13345367 true "" "plot mean [drug2_resistance] of turtles"

SLIDER
30
220
202
253
drug2_interval
drug2_interval
100
10000
100.0
1
1
ticks
HORIZONTAL

SWITCH
210
180
349
213
drug1_enabled
drug1_enabled
0
1
-1000

SWITCH
210
220
349
253
drug2_enabled
drug2_enabled
1
1
-1000

PLOT
685
10
1125
280
Infection Level
Ticks
Count
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Infected" 1.0 0 -16777216 true "" "plot count turtles"

SLIDER
30
460
200
493
mutation_chance
mutation_chance
0
100
5.0
1
1
%
HORIZONTAL

INPUTBOX
360
155
515
215
drug1_start_tick
2000.0
1
0
Number

INPUTBOX
360
220
515
280
drug2_start_tick
0.0
1
0
Number

TEXTBOX
415
115
645
150
Defines which tick each drug should be enabled/disabled (0 = disabled)
14
0.0
1

SLIDER
30
380
200
413
drug1_base_resistance_min
drug1_base_resistance_min
1
drug1_base_resistance_max
5.0
1
1
NIL
HORIZONTAL

SLIDER
30
420
200
453
drug2_base_resistance_min
drug2_base_resistance_min
1
drug2_base_resistance_max
4.0
1
1
NIL
HORIZONTAL

INPUTBOX
520
155
675
215
drug1_end_tick
0.0
1
0
Number

INPUTBOX
520
220
675
280
drug2_end_tick
0.0
1
0
Number

SWITCH
425
285
612
318
stop_after_drug_course
stop_after_drug_course
1
1
-1000

TEXTBOX
170
145
270
175
Drug Control
16
0.0
1

TEXTBOX
160
305
275
330
Disease Control
16
0.0
1

SWITCH
30
500
200
533
transformation_enabled
transformation_enabled
1
1
-1000

SLIDER
210
500
380
533
transformation_chance
transformation_chance
0
100
11.0
1
1
%
HORIZONTAL

SLIDER
210
380
380
413
drug1_base_resistance_max
drug1_base_resistance_max
drug1_base_resistance_min
100
13.0
1
1
NIL
HORIZONTAL

SLIDER
210
420
380
453
drug2_base_resistance_max
drug2_base_resistance_max
drug1_base_resistance_min
100
11.0
1
1
NIL
HORIZONTAL

MONITOR
835
290
975
335
Infection Level
count turtles
17
1
11

MONITOR
835
345
975
390
Drug 1 Mean Resistance
mean [drug1_resistance] of turtles
17
1
11

MONITOR
835
400
975
445
Drug 2 Mean Resistance
mean [drug2_resistance] of turtles
17
1
11

MONITOR
685
345
825
390
Drug 1 Min Resistance
min [drug1_resistance] of turtles
17
1
11

MONITOR
685
400
825
445
Drug 2 Min Resistance
min [drug2_resistance] of turtles
17
1
11

MONITOR
985
345
1125
390
Drug 1 Max Resistance
max [drug1_resistance] of turtles
17
1
11

MONITOR
985
400
1125
445
Drug 2 Max Resistance
max [drug2_resistance] of turtles
17
1
11

PLOT
1135
455
1575
775
Min/Max Drug Resistance
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Drug 1 Max" 1.0 0 -955883 true "" "plot max [drug1_resistance] of turtles"
"Drug 1 Min" 1.0 0 -1184463 true "" "plot min [drug1_resistance] of turtles"
"Drug 2 Max" 1.0 0 -13840069 true "" "plot max [drug2_resistance] of turtles"
"Drug 2 Min" 1.0 0 -11221820 true "" "plot min [drug2_resistance] of turtles"

SLIDER
390
380
560
413
drug1_max_resistance_gain
drug1_max_resistance_gain
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
390
420
560
453
drug2_max_resistance_gain
drug2_max_resistance_gain
0
100
3.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
