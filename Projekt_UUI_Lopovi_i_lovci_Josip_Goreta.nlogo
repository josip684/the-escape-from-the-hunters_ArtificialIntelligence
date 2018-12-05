__includes [ "pretrage, provjere i korak.nls" ]

breed [novcici novcic]
breed [lopovi lopov]
breed [lovci lovac]
breed [bonusi2 bonus2] ;ovo je hrana koja se stvori naknadno
breed [bonusi bonus]; ovo su zvjezdice koje se stvore naknadno

lopovi-own [
  vrijeme
  moj-put
  procjena-puta
  ax ay
  heuristika
  hx hy
  k d-o c h

  uk-bodova cilj? uk-zivota tikovi
  a p; za a-star
  ]
lovci-own [procjena-puta heuristika
  vx vy
  personal-best-val
  personal-best-x
  personal-best-y
  ]

patches-own [istrazen? px py phx phy bod val]

globals [ br-istrazenih br lista br-koraka uk-agenata b

  global-best-x
  global-best-y
  global-best-val
  true-best-patch

  MIN-OF-LOVCI

 P-X-COR
 P-Y-COR
  ]

to odabir
  if (tip-pretrage = "sirina")
  [pretraga4]
  if (tip-pretrage = "a-star")
  [pretraga3]
  if (tip-pretrage = "pso")
  [PSO]
end
to pretrazuj
  odabir
end

to setup
  ca

  labirint
  ask patches [ set val random-float 1.0 ]


  let min-val min [val] of patches
  let max-val max [val] of patches
  ; normalize the values to be between 0 and 1
  ask patches [ set val 0.99999 * (val - min-val) / (max-val - min-val)  ]

  ask max-one-of patches [val]
  [
    set val 1.0
    set true-best-patch self
  ]
  set br-istrazenih 0
  set br 0
  set lista [0]
  ;formula
  stvori-lopova
  stvori-lovce
  stvori-novcice
  stvori-bonuse2
  stvori-bonuse
  update-highlight

  set MIN-OF-LOVCI 0
  set P-X-COR 0
 set P-Y-COR 0


  reset-ticks
  tick-advance 1

end

to labirint
  ca
  import-pcolors "corners.png"

  ask patch 1 1 [set pcolor black]
  ask patch 19 1 [set pcolor black]
  ask patch 18 1 [set pcolor black]
  ask patches at-points [
    [11 1] [13 1] [12 1] [10 5] [10 15] [9 14] [10 14] [11 14] [1 22]
    [1 23] [11 23] [12 23] [13 23] [18 23] [19 23] [3 16] [3 11] [16 16] [16 11] ]
 [ set pcolor black]

  ask patches with [pcolor = 101.1 or pcolor = 102.9 or pcolor = 100.6 or pcolor = 94.9
    or pcolor = 104.1 or pcolor = 103.5 or pcolor = 104 or pcolor = 100.8 or pcolor = 104.8 or pcolor = 44.3] [set pcolor blue]
  ask patches with [pcolor = blue] [set pcolor red]
  ask patches with [pcolor != red ] [set pcolor black set istrazen? false]
end

to stvori-novcice
  create-novcici count patches with [pcolor = black] - 4
  [
    move-to one-of patches with [pcolor = black and not any? turtles-here]
    set color yellow
    set shape "dot"

    ]
end

to stvori-lopova
  create-lopovi 1
  [
    move-to one-of patches with [pxcor = 10 and pycor = 5]
    set heading 0
    set shape "person soldier"
    set color green
    set istrazen? true
    set br-koraka 0
    set uk-bodova 0
    set cilj? false
    set uk-zivota zeleni-broj-zivota
    set tikovi 0
    ;pen-down
    ]
end

to stvori-lovce
  create-lovci 3
  [
    move-to one-of patches with [(pxcor = 9 and pycor = 14 ) or (pxcor = 10 and pycor = 14) or (pxcor = 11 and pycor = 14) ;and not any? lovci-here
      ]
    set heading 0
    set shape "person police"
    let r 0

    set vx random-normal 0 1
    set vy random-normal 0 1

    set personal-best-val val
    set personal-best-x xcor
    set personal-best-y ycor

    set color one-of (remove-item 0 base-colors)

    ]
end

to stvori-bonuse2
  create-bonusi2 1
  [
    move-to one-of patches with [pcolor = black]
    set shape "food"
    set color blue
    set hidden? true
    ]
end

to stvori-bonuse
  create-bonusi 4
  [
    move-to one-of patches with [pcolor = black and ((pxcor = 1 and pycor = 23 ) or (pxcor = 1 and pycor = 1 ) or (pxcor = 19 and pycor = 23 ) or (pxcor = 19 and pycor = 1 )) and not any? bonusi-here]
    set shape "star"
    set color yellow
    set hidden? true
    ]
end

to formula
  ask patches with [pcolor = black] [
  set plabel pxcor * 100 + pycor
  ]
end

;*********************KRETANJE************************************************

to naprijed
  ask lopovi
  [
    if [pcolor] of patch-ahead 1 != red
    [fd 1 provjera skupi-bonus skupi-bonus2 ]

    if any? novcici-on patch-here [ask novcici-on patch-here[die] set uk-bodova uk-bodova + 1]

    ]

  ask lovci[manhattan-udaljenost2 [xcor] of lovac (who) [ycor] of lovac (who)]
  tick-advance 1
  ask lopovi [set tikovi ticks]
end

to desno
  ask lopovi
  [
    if [pcolor] of patch-right-and-ahead 90 1 != red
    [right 90 fd 1 provjera skupi-bonus skupi-bonus2]

    if any? novcici-on patch-here [ask novcici-on patch-here[die] set uk-bodova uk-bodova + 1]

    ]

  ask lovci[manhattan-udaljenost2 [xcor] of lovac (who) [ycor] of lovac (who)]
  tick-advance 1
  ask lopovi [set tikovi ticks]
end

to natrag
  ask lopovi
  [
    if [pcolor] of patch-ahead -1 != red
    [fd -1 provjera skupi-bonus skupi-bonus2]

    if any? novcici-on patch-here [ask novcici-on patch-here[die] set uk-bodova uk-bodova + 1]

    ]

  ask lovci[manhattan-udaljenost2 [xcor] of lovac (who) [ycor] of lovac (who)]
  tick-advance 1
  ask lopovi [set tikovi ticks]
end

to lijevo
  ask lopovi
  [
    if [pcolor] of patch-left-and-ahead 90 1 != red
    [left 90 fd 1 provjera skupi-bonus skupi-bonus2]

    if any? novcici-on patch-here [ask novcici-on patch-here[die] set uk-bodova uk-bodova + 1]

    ]

  ask lovci[manhattan-udaljenost2 [xcor] of lovac (who) [ycor] of lovac (who)]
  tick-advance 1
  ask lopovi [set tikovi ticks]
end

to idi-naprijed
  ask lopovi
  [
    if [pcolor] of patch-ahead 1 = black [fd 1 ;set br-koraka br-koraka + 1  if istrazen? = false [set br-istrazenih br-istrazenih + 1] set istrazen? true
      ]
    ]
end
;//////////////////////////////////////////////////////////////////////////////////////
;////////////////////////*********NOVO**************************************/////////////
;/////////////////////////////////////////////////////////////////////////////////////////

to a-star-pretraga

  ask lopovi [set a h + p]
  ask first sort-on [a] lopovi
  [
    korak-lopova
  ]

end

to sirina
  ask lopovi [korak-lopova]
end

to korak-pretrage

    provjera
   ; if any? lopovi with [c = true][ask lopovi with [c = false] [die] stop]
   ;if any? lopovi-on patches with [istrazen? = true] [die]

    if [pcolor != red] of patch-left-and-ahead 90 1
    [ hatch 1 [ lt 90 fd 1 set istrazen? true set k (k + 1) set h h + 1 m-u]  set b (b + 1) provjera  ]

    if [pcolor != red] of patch-ahead 1
    [ hatch 1 [ fd 1 set istrazen? true set k (k + 1) set h h + 1 m-u] set b (b + 1) provjera ]

    if [pcolor != red] of patch-right-and-ahead 90 1
    [ hatch 1 [ rt 90 fd 1 set istrazen? true set k (k + 1) set h h + 1 m-u] set b (b + 1) provjera ]

    if any? novcici-on patch-here [set uk-bodova uk-bodova + 1 ask novcici-on patch-here [die]]

    ask lovci[manhattan-udaljenost2 [xcor] of lovac (who) [ycor] of lovac (who)]
  ;tick-advance 1
  ask lopovi [set tikovi ticks]


    if not any? novcici [user-message "Skupljeni svi novcici, kraj igre!" stop]
    if uk-zivota = 0 [user-message "Kraj igre! Lopov je izgubio sve živote." stop]


    die

end
to m-u
  ask lopovi [set p  (abs (pxcor - (first [pxcor] of novcici)) + abs( pycor - first [pycor] of novcici)) ]
end

to pretraga3
  a-star-pretraga
ask lovci
[
  if item 0 [tikovi] of lopovi = ticks
  [
    ifelse count lovci = 1
    [
      ask item 0 (sort-by [[procjena-puta] of ?1 < [procjena-puta] of ?2] lovci)
      [
        korak provjeri-uk-zivota
      ]
    ]

    [
      ifelse count lovci > 4 ;
      [
        ask last (sort-by [[procjena-puta] of ?1 < [procjena-puta] of ?2] lovci)
        [
          die
        ]
      ]
      [
        if count lovci > 1
        [
          ask item 1 (sort-by [[procjena-puta] of ?1 < [procjena-puta] of ?2] lovci)
          [
            korak provjeri-uk-zivota
          ]
        ]
      ]
    ]
  ]
]
ask lopovi[set tikovi 0]
end

to korak-lopova
  provjera
  ask lopovi[
    ifelse count lopovi < 5
    [
      if [pcolor != red ] of patch-left-and-ahead 90 1
    [
      hatch 1[
        lt 90 fd 1  if any? novcici-on patch-here [ask novcici-on patch-here[die] set uk-bodova uk-bodova + 1]
        provjeri-uk-zivota manhattan-udaljenost2 [xcor] of lopov (who) [ycor] of lopov (who)
        ]
      ]

      if [pcolor != red ] of patch-ahead 1
    [
      hatch 1 [
        fd 1   if any? novcici-on patch-here [ask novcici-on patch-here[die] set uk-bodova uk-bodova + 1]
        provjeri-uk-zivota manhattan-udaljenost2 [xcor] of lopov (who) [ycor] of lopov (who)
        ]
      ]

      if [pcolor != red ] of patch-right-and-ahead 90 1
    [
      hatch 1 [
        rt 90 fd 1  if any? novcici-on patch-here [ask novcici-on patch-here[die] set uk-bodova uk-bodova + 1]
        provjeri-uk-zivota manhattan-udaljenost2 [xcor] of lopov (who) [ycor] of lopov (who)
        ]
      ]

      ask lopovi [
        if [pcolor = red ] of patch-right-and-ahead 90 1 and [pcolor = red ] of patch-ahead 1 and [pcolor = red ] of patch-left-and-ahead 90 1
        [
          ask lopovi-on patch-here[right 180]
          ]
        ]
      die
    ]
  [
    ask max-one-of lopovi [ procjena-puta][die]
    ]
  ;radilo je s ovim ispod
  ;ask lovci[manhattan-udaljenost2 [xcor] of lovac (who) [ycor] of lovac (who)]
  ask lopovi[manhattan-udaljenost2 [xcor] of lopov (who) [ycor] of lopov (who)]
  ;tick-advance 1
  ask lopovi [set tikovi ticks]
  if any? novcici-on patch-here [ask novcici-on patch-here[die] set uk-bodova uk-bodova + 1]
  if any? bonusi-on patch-here [ask bonusi-on patch-here[die] set uk-zivota uk-zivota + 2 setxy 9 14]
  if any? bonusi2-on patch-here [ask bonusi2-on patch-here[die] set uk-zivota uk-zivota + 1 ]


    if not any? novcici [user-message "Skupljeni svi novcici, kraj igre!" stop]
    if uk-zivota = 0 [user-message "Kraj igre! Lopov je izgubio sve živote." stop]
 ]
end

to pretraga4
  sirina
ask lovci
[
  if item 0 [tikovi] of lopovi = ticks
  [
    ifelse count lovci = 1
    [
      ask item 0 (sort-by [[procjena-puta] of ?1 < [procjena-puta] of ?2] lovci)
      [
        korak provjeri-uk-zivota
      ]
    ]

    [
      ifelse count lovci > 4 ;bilo je > 2
      [
        ask last (sort-by [[procjena-puta] of ?1 < [procjena-puta] of ?2] lovci)
        [
          die
        ]
      ]
      [
        if count lovci > 1
        [
          ask item 1 (sort-by [[procjena-puta] of ?1 < [procjena-puta] of ?2] lovci)
          [
            korak provjeri-uk-zivota
          ]
        ]
      ]
    ]
  ]
]
ask lopovi[set tikovi 0]
end

to update-highlight
  ifelse highlight-mode = "Best found"
  [ ;watch patch global-best-x global-best-y

    watch patch 10 14
    ]

  [
    ifelse highlight-mode = "True best"
    [  watch true-best-patch ]
    [  reset-perspective ]
  ]
end

to PSO
  korak-lopova
  ask lovci [

    ;max-one-of lopovi [ procjena-puta]
    if MIN-OF-LOVCI > personal-best-val
    [
      set personal-best-val MIN-OF-LOVCI
      set personal-best-x xcor
      set personal-best-y ycor
      ]
    ]

  ask min-one-of lovci [personal-best-val]
  [
    if global-best-val < personal-best-val
    [
      set global-best-val personal-best-val
      set global-best-x personal-best-x
      set global-best-y personal-best-y

      ]
    ]

  if global-best-val = [min-one-of lovci [procjena-puta]] of true-best-patch [stop]

  ask lovci
  [
    set vx 1 * vx
    set vy 1 * vy

    facexy personal-best-x personal-best-y
   let dist distancexy personal-best-x personal-best-y
   set vx vx + (1 - 1) * 1 * (random-float 1.0) * dist * dx
   set vy vy + (1 - 1) * 1 * (random-float 1.0) * dist * dy

    facexy global-best-x global-best-y
    set dist distancexy global-best-x global-best-y
    set vx vx + (1 - 1) * 1 * (random-float 1.0) * dist * dx
    set vy vy + (1 - 1) * 1 * (random-float 1.0) * dist * dy

    if (vx > 10) [set vx 10]
    if (vx < 0 - 10) [set vx 0 - 10]
    if (vy > 10) [ set vy 10 ]
    if (vy < 0 - 10) [ set vy 0 - 10 ]

    facexy (xcor + vx) (ycor + vy)

    ;if [pcolor] of patch-ahead 1 != red [fd sqrt (vx * vx + vy * vy)]
    ;ifelse [pcolor] of patch-ahead 1 = red []
    ;[lt 90 fd sqrt (vx * vx + vy * vy)]
    korak-lovca-pso
    ]
  update-highlight
  tick

end

to korak-lovca-pso
  provjera


  ask lovci[

    ifelse count lovci < 5 ; bilo je < 3
    [
      if [pcolor != red ] of patch-left-and-ahead 90 1
    [
      hatch 1[
        lt 90 fd sqrt (vx * vx + vy * vy) set color blue provjeri-uk-zivota manhattan-udaljenost2 [xcor] of lovac (who) [ycor] of lovac (who)
        ]
      ]

      if [pcolor != red ] of patch-ahead 1
    [
      hatch 1 [
        fd sqrt (vx * vx + vy * vy) set color blue provjeri-uk-zivota manhattan-udaljenost2 [xcor] of lovac (who) [ycor] of lovac (who)
        ]
      ]

      if [pcolor != red ] of patch-right-and-ahead 90 1
    [
      hatch 1 [
        rt 90 fd sqrt (vx * vx + vy * vy) set color blue provjeri-uk-zivota manhattan-udaljenost2 [xcor] of lovac (who) [ycor] of lovac (who)
        ]
      ]

      ask lovci [
        if [pcolor = red ] of patch-right-and-ahead 90 1 and [pcolor = red ] of patch-ahead 1 and [pcolor = red ] of patch-left-and-ahead 90 1
        [
          ask lovci-on patch-here[right 180]
          ]
        ]
      die
    ]
  [
    set MIN-OF-LOVCI min [procjena-puta] of lovci
    set P-X-COR [pxcor] of lovci with [[procjena-puta] of lovci  = MIN-OF-LOVCI]
    set P-Y-COR [pycor] of lovci with [[procjena-puta] of lovci  = MIN-OF-LOVCI]

    ask max-one-of lovci [ procjena-puta][die]
    ]
 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
627
525
-1
-1
19.4
1
10
1
1
1
0
1
1
1
0
20
0
24
0
0
1
ticks
30.0

BUTTON
24
16
197
49
Postavi
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
21
259
193
304
Broj crnih polja
count patches with [pcolor = black]
17
1
11

MONITOR
21
312
194
357
Preostalo novčića:
count novcici
17
1
11

BUTTON
23
62
196
95
Poglepna pretraga
pretraga2
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
23
150
194
195
Trenutni bodovi:
[uk-bodova] of lopovi
17
1
11

MONITOR
23
205
194
250
Ostalo života:
[uk-zivota] of lopovi
17
1
11

BUTTON
63
436
125
489
^
naprijed
NIL
1
T
OBSERVER
NIL
8
NIL
NIL
1

BUTTON
63
539
126
592
V
natrag
NIL
1
T
OBSERVER
NIL
2
NIL
NIL
1

BUTTON
9
487
64
540
<
lijevo
NIL
1
T
OBSERVER
NIL
4
NIL
NIL
1

BUTTON
123
489
182
540
>
desno
NIL
1
T
OBSERVER
NIL
6
NIL
NIL
1

SLIDER
20
400
191
433
zeleni-broj-zivota
zeleni-broj-zivota
1
10
4
1
1
NIL
HORIZONTAL

SLIDER
19
363
191
396
brzina-lovaca
brzina-lovaca
0
1
0.7
0.1
1
NIL
HORIZONTAL

BUTTON
21
107
195
140
Pretraga u dubinu
dubina
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
639
19
839
52
A* pretraga - simulacija
pretraga3
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
642
149
722
194
Broj lopova
count lopovi
17
1
11

BUTTON
640
63
839
96
Pretraga po širini
pretraga4
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
734
150
815
195
Broj lovaca
count lovci
17
1
11

CHOOSER
640
203
815
248
highlight-mode
highlight-mode
"None" "Best found" "True best"
0

BUTTON
642
106
839
139
Particle Swarm Optimization pretraga
PSO
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
641
256
818
301
tip-pretrage
tip-pretrage
"sirina" "a-star" "pso"
0

BUTTON
642
316
818
381
Pretraga
pretrazuj
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the lopovs use to create the overall behavior of the model)

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

bird
false
0
Polygon -7500403 true true 135 165 90 270 120 300 180 300 210 270 165 165
Rectangle -7500403 true true 120 105 180 237
Polygon -7500403 true true 135 105 120 75 105 45 121 6 167 8 207 25 257 46 180 75 165 105
Circle -16777216 true false 128 21 42
Polygon -7500403 true true 163 116 194 92 212 86 230 86 250 90 265 98 279 111 290 126 296 143 298 158 298 166 296 183 286 204 272 219 259 227 235 240 241 223 250 207 251 192 245 180 232 168 216 162 200 162 186 166 175 173 171 180
Polygon -7500403 true true 137 116 106 92 88 86 70 86 50 90 35 98 21 111 10 126 4 143 2 158 2 166 4 183 14 204 28 219 41 227 65 240 59 223 50 207 49 192 55 180 68 168 84 162 100 162 114 166 125 173 129 180

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

food
false
0
Polygon -7500403 true true 30 105 45 255 105 255 120 105
Rectangle -7500403 true true 15 90 135 105
Polygon -7500403 true true 75 90 105 15 120 15 90 90
Polygon -7500403 true true 135 225 150 240 195 255 225 255 270 240 285 225 150 225
Polygon -7500403 true true 135 180 150 165 195 150 225 150 270 165 285 180 150 180
Rectangle -7500403 true true 135 195 285 210

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

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

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
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>pretraga3</go>
    <timeLimit steps="100"/>
    <metric>count lovci</metric>
    <metric>count novcici</metric>
    <metric>count lopovi</metric>
    <steppedValueSet variable="zeleni-broj-zivota" first="1" step="1" last="10"/>
    <steppedValueSet variable="brzina-lovaca" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>pretraga4</go>
    <timeLimit steps="100"/>
    <exitCondition>not any? novcici</exitCondition>
    <metric>count lovci</metric>
    <metric>count novcici</metric>
    <metric>count lopovi</metric>
    <steppedValueSet variable="zeleni-broj-zivota" first="1" step="1" last="10"/>
    <steppedValueSet variable="brzina-lovaca" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="lovci-lopovi" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>PSO</go>
    <timeLimit steps="100"/>
    <metric>count lovci</metric>
    <metric>count novcici</metric>
    <metric>count lopovi</metric>
    <steppedValueSet variable="zeleni-broj-zivota" first="1" step="1" last="10"/>
    <steppedValueSet variable="brzina-lovaca" first="0" step="0.1" last="1"/>
  </experiment>
</experiments>
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
0
@#$#@#$#@
