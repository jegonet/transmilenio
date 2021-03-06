;Variables globales
globals [
  waiting-for-go-in ;variable de cantidad de agentes pendientes de subir al bus
  waiting-for-go-out ; variable de cantidad de personas pendientes de bajar del bus

  no-goin-people ;variable de cantidad de personas en la estación que no subirán al bus
  no-goout-people ;variable de cantidad de personas en el bus que no bajarán en la estación
  must-stop ;variable que indica si el modelo debe parar (porque ya convergió)
]

;
breed [ people-in person-in ] ;personas que van a subir a un bus
breed [ people-out person-out ] ;personas que van a bajar de un bus

;Variables o propiedades de los agentes
turtles-own [
  cross ;booleano que marca si una persona ya logró subir o bajar del bus
  moved ;booleano que marca si en el último tick una tortuga logró moverse
  last-heading ;entero que define la última dirección del agente
  last-ycor ; entero que marca la última posición conocida en el eje Y del agente
]

;Método de configuración inicial
to setup
  clear-all
  draw-patches ;Dibuja las parcelas para simular una estación de transmilenio y un bus

  ;cálculos de las personas que van a subir del bus, según los controles de configuración de parámetros del modelo
  set waiting-for-go-in ( initial-people-go-in * percentaje-people-go-in / 100 )
  set waiting-for-go-in (round waiting-for-go-in)
  set no-goin-people ( initial-people-go-in - waiting-for-go-in )

  ;crea agentes en la estación que no subirán al bus
  create-people-in no-goin-people
  [
    set color white
    setxy random-xcor random-tween-inclusive -2 -10
  ]

  ;crea agentes en la estación que sí subirán al bus
  create-people-in waiting-for-go-in
  [
    set color blue
    setxy random-xcor random-tween-inclusive -2 -10
  ]

  ;cálculos de las personas que van a bajar del bus, según los controles de configuración de parámetros del modelo
  set waiting-for-go-out ( initial-people-go-out * percentaje-people-go-out / 100 )
  set waiting-for-go-out (round waiting-for-go-out)
  set no-goout-people ( initial-people-go-out - waiting-for-go-out)

  ;crea agentes en el bus que sí bajarán del mismo
  create-people-out waiting-for-go-out
  [
    set color orange
    setxy random-xcor random-tween-inclusive 5 0
  ]

  ;crea agentes en el bus que no bajarán del mismo
  create-people-out no-goout-people
  [
    set color yellow
    setxy random-xcor random-tween-inclusive 5 0
  ]

  ;configura los parámetros generales para todos los agentes
  ask turtles [
    set shape  "person"
    set size 1
    set cross false
    set last-heading 90
  ]

  ;setea variable por defecto para que el modelo pueda correr
  set must-stop false
  reset-ticks
end

to go
  if(must-stop = false)[ ; valida que el modelo no haya convergido aún para continuar movimientos
    ask turtles [
      set moved false
    ]
    ask turtles with [ color = white ] [ ;personas en la estación que no se van a subir
      stay-outside-away-doors ; moverse pero mantenerse alejado de las puertas para permitir el tránsito de personas
    ]
    ask turtles with [ color = blue ] [ ;personas en la estación que sí se van a subir
      try-go-in ; moverse con prioridad hacia dentro del bus
    ]
    ask turtles with [ color = yellow ] [ ;personas en el bus que no se van a bajar
      stay-inside-away-doors ; moverse pero mantenerse alejado de las puertas para permitir el tránsito de personas
    ]
    ask turtles with [ color = orange ] [ ;personas en el bus que sí se van a bajar
      try-go-out ; moverse con prioridad hacia fuera del bus
    ]
    tick
  ]
end

; moverse con prioridad hacia dentro del bus
to try-go-in
  ifelse(ycor <= -1) [;no ha entrado al bus

    if (xcor < -5 or (xcor >= 2 and xcor < 6) or  (xcor >= 10 and xcor < 12)) [; a la izquierda de una puerta
      foreach [45 90 135 0 315  225 180 270] try-move ;moverse con prioridad hacia adelante y la derecha
    ]
    if ((xcor >= -5 and xcor <= -3) or (xcor >= 6 and xcor <= 7) or (xcor >= 12 and xcor <= 13)) [; frente a una puerta
      foreach [0 45 315 90 270 135 225 180] try-move ;moverse con prioridad hacia adelante
    ]
    if ((xcor > -3 and xcor < 2) or (xcor > 7 and xcor < 10) or xcor > 13) [ ; a la derecha de la puerta
      foreach [315 270 0 225 45 90 180 135] try-move ;moverse con prioridad hacia adelante y la izquierda
    ]
  ][ ;ya se subió al bus
    foreach [0 90 270 45 315 135 225 180] try-move ;moverse con prioridad hacia adelante y hacia los lados del bus
  ]
end

; moverse con prioridad hacia fuera del bus
to try-go-out
  ifelse(ycor > -1) [;no se ha bajado del bus
    if (xcor < -9 or (xcor >= 2 and xcor < 5) or  (xcor >= 10 and xcor < 11)) [; a la izquierda de una puerta
      foreach [135 180 90 45 0 225 270 315] try-move ;moverse con prioridad hacia el sur y la derecha
    ]
    if ((xcor >= -9 and xcor <= -3) or (xcor >= 5 and xcor <= 7) or (xcor >= 11 and xcor <= 13)) [; frente a una puerta
      foreach [180 225 135 270 90 315 45 0] try-move ;moverse con prioridad hacia el sur
    ]
    if ((xcor > -3 and xcor < 2) or (xcor > 7 and xcor < 10) or xcor > 13) [; a la derecha de una puerta
      foreach [225 180 135 270 90 315 0 45] try-move ;moverse con prioridad hacia el sur y la izquierda
    ]
  ][ ;ya se bajo del bus
    foreach [180 225 135 270 90 315 45 0] try-move ;moverse con prioridad hacia el sur y hacia los lados
  ]
end

; moverse dentro del bus pero mantenerse alejado de las puertas para permitir el tránsito de personas
to stay-inside-away-doors
  foreach [0 315 45 270 90 225 135 180] try-move ;moverse con prioridad hacia el norte y hacia los lados del bus
end

; moverse en la estación pero mantenerse alejado de las puertas para permitir el tránsito de personas
to stay-outside-away-doors
  foreach [180 135 225 90 270 45 315 0] try-move ;moverse con prioridad hacia el sur y hacia los lados
end

;función de movimiento general de agentes hacia una dirección, aplicando restricciones
to try-move [direction]

  set heading direction ;ubica el agente hacia la dirección indicada para dar un paso

  if(moved = false)[ ; valida que el agente en el último tick no se haya movido
    let ahead patch-set patch-ahead 1
    if (any? ahead) [ ;valida que haya lugar para moverse en el mundo
      if not any? turtles-on patch-ahead 1 [  ;valida que no hayan otras personas en el espacio en frente

        fd 1
        let valid-movement true

        ;inicia algoritmo de detección de posibles movimientos inválidos (no posibles) de los autómatas
        ifelse(cross = false)[
          if (color = blue and ycor > -1)[
            if not ((xcor >= -7 and xcor <= -7) or (xcor >= -5 and xcor <= -3) or (xcor >= 6 and xcor <= 7) or (xcor >= 12 and xcor <= 13))[ ;cruce por lugar que no es la puerta
              set valid-movement false
            ]
          ]
          if (color = orange and ycor <= 0)[
            if not ((xcor >= -9 and xcor < -7) or (xcor >= -5 and xcor <= -3) or (xcor >= 5 and xcor <= 7) or (xcor >= 11 and xcor <= 13))[ ;cruce por lugar que no es la puerta
              set valid-movement false
            ]
          ]
          if (color = yellow and ycor <= 0)[;no debería salirse del bus un pasajero que no quiere bajarse
            set valid-movement false
          ]
          if (color = white and ycor > -1)[;no debería subirse al bus un pasajero al que no le sirve el mismo
            set valid-movement false
          ]
        ][
          if ((color = orange or color = yellow) and ycor > -1 and ycor >= last-ycor)[;se devolvió al bus y no está tratando de volver a la estación
              set valid-movement false
          ]
          if ((color = white or color = blue) and ycor <= 0 and ycor <= last-ycor)[;se devolvió a la estación y no está tratando de regresar al bus
              set valid-movement false
          ]
        ]
        if (ycor > 5)[ ;no se puede salir al otro lado del transmilenio, es una zona verde fuera de la estación
          set valid-movement false
        ]

        ifelse (valid-movement = true)[ ;movimiento válido, continuar y verificar estadísticas
          set moved true
          cross-control
          set last-heading heading ;almacenando última dirección
          set last-ycor ycor ;almacenando última coordenada en el eje Y para validar movimientos con respecto al pasado
        ][ ;deshacer pasos inválidos
          let tpm-ahead heading
          rt 180
          fd 1
          set heading tpm-ahead
        ]
      ]
    ]
  ]
end

;función que valida si un agente cruzó hacia su objetivo para cambiar comportamiento
to cross-control
  if (cross = false) [
    if (color = orange and ycor <= -1) [ ;un agente naranja logró bajar del bus
      set waiting-for-go-out ( waiting-for-go-out - 1 )
      set cross true
    ]
    if (color = blue and ycor >= 0) [ ;un agente azul logró subir al bus
      set waiting-for-go-in ( waiting-for-go-in - 1 )
      set cross true
    ]
  ]

  ;si ya se subieron y bajaron todos los agentes, entonces detener el modelo
  if (waiting-for-go-out <= 0 and waiting-for-go-in <= 0) [
    set must-stop true
  ]
end

;función de colores sobre las parcelas del mundo, para el bus, la estación, las puertas y la zona verde
to draw-patches
  ask patches [
    set pcolor green - 0.5 ;zona verde al otro lado de la estación de transmilenio
  ]
  ask patches with [ pycor <= 5 ] [
    set pcolor red - 1 ;bus de transmilenio
  ]
  ask patches with [  pycor = 0 and  ( ( pxcor >= -9 and pxcor <= -7 ) or ( pxcor >= -5 and pxcor <= -3 ) or ( pxcor >= 5 and pxcor <= 7 ) or ( pxcor >= 11 and pxcor <= 13 )  ) ] [
      set pcolor red - 2.5 ;puertas del bus de transmilenio
  ]
  ask patches with [ pycor <= -1 ] [
    set pcolor grey - 1 ;estimación de transmilenio
  ]
end

;función utilitaria para generar números aleatorios dentro de un rango determinado
to-report random-tween-inclusive [ a b ]
    report a + random (b - a)
end
@#$#@#$#@
GRAPHICS-WINDOW
213
12
624
294
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-15
15
-10
10
0
0
1
ticks
30.0

BUTTON
11
11
75
44
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
132
12
195
45
Run
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
11
57
194
90
initial-people-go-in
initial-people-go-in
0
160
80.0
1
1
NIL
HORIZONTAL

SLIDER
11
144
195
177
initial-people-go-out
initial-people-go-out
0
160
80.0
1
1
NIL
HORIZONTAL

SLIDER
11
101
195
134
percentaje-people-go-in
percentaje-people-go-in
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
10
187
196
220
percentaje-people-go-out
percentaje-people-go-out
0
100
50.0
1
1
NIL
HORIZONTAL

PLOT
635
77
874
227
People waiting to go into or go out
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13345367 true "" "plot waiting-for-go-in"
"pen-1" 1.0 0 -955883 true "" "plot waiting-for-go-out"

TEXTBOX
646
237
860
293
-Blue line, people waiting for going into the bus.\n-Orange line, people waiting for getting out the bus.
11
0.0
1

MONITOR
635
12
740
57
NIL
waiting-for-go-in
17
1
11

MONITOR
759
12
873
57
NIL
waiting-for-go-out
17
1
11

@#$#@#$#@
## WHAT IS IT?

Este modelo trata de emular el comportamiento de las personas para subir o bajar de un bus articulado de Trasmilenio, sistema masivo de transporte en Bogotá, Colombia, utilizando reglas muy simples de movimiento y organización.

## HOW IT WORKS

El modelo fue desarrollado en un mundo finito de parcelas de 21 de alto * 33 de ancho, simulando en gris la estación de transmilenio, en rojo el bus de transmilenio biarticulado para 160 pasajeros, ubicando allí en color rojo oscuro el lugar de las puertas, cada una con un ancho que permite el tránsito de hasta 3 agentes en simultáneo; en la parte superior se ve una zona verde que representan pastos al otro lado de la estación, donde no debería haber ninguna persona caminando (por lo menos no para el propósito de este modelo:

El modelo incluye 2 tipos de agentes, cada uno con 2 tipos de comportamientos:

a. Agentes que están en el bus. Algunos de estos agentes quieren bajar de la estación (color naranja), por lo que su comportamiento es primordialmente acercarse a las puertas para lograr salir. En este modelo se propuso que la parte izquierda de las puertas (desde la perspectiva del espectador de la simulación) es exclusiva para la salida de pasajeros, mientras que la parte derecha y central de cada puerta bien puede ser usada tanto para salir como para entrar. Una vez logran bajar del bus, estos agentes se alejan de las puertas para ir hacia los lados de las estaciones.

El segundo comportamiento de los agentes dentro del bus, es el de los agentes que quieren permanecer dentro del bus mismo (color amarillo), porque no tienen la intención de bajar a la estación. Estos agentes con prioridad se mueven para alejarse de las puertas, de tal forma que permitan el tránsito de las personas que desean subir o bajar del bus.

b. El segundo y último tipo de agente modelado, es el agente que está en la estación, este tiene dos tipos de comportamientos, dependiendo de si desea subir o no al bus.

En color azul se modelan los agentes que desean subir al bus, de esta forma, estos se mueven primordialmente hacia las puertas para lograr subir al bus. Una vez logran subir al bus, se mueven hacia los costados del bus, de tal forma que se alejan de las puertas permitiendo el tránsito de las personas. 

En color blanco se modelan los agentes que no desean subir al bus, estos agentes se mueven hacia el bus y luego hacia los lados permitiendo que las personas puedan subir o bajar del bus. Por su comportamiento, tienden a generar bloqueo para las personas que quieren subir o bajar del bus. 

Aunque en el comportamiento de cada agente, claramente hay una “prioridad” en la dirección de sus movimientos, fue necesario permitir que cada agente pudiera moverse en ciertos momentos, en dirección contraria a su objetivo, esto con el fin de dar la capacidad de salir de espacios cerrados u ocupados por otros agentes, con una cierta libertad, como lo haría una persona común al ver que no hay espacio para salir (tendría que buscar otro espacio).

Por otra parte, se programaron algunas reglas adicionales:

- Todo agente para subir o bajar del bus (cruzar), debía hacerlo usando exclusivamente el espacio de las puertas del mismo.

- Ningún agente podía moverse a una ubicación ya ocupada por otro agente.

- Una agente naranja que lograra salir del bus (cumplir su objetivo), no podía moverse regresando al bus.

- Un agente azul que lograra subir al bus (cumplir su objetivo), no podía salir del mismo y regresar a la estación.

## HOW TO USE IT

El botón Setup permite inicializar el modelo, mientras que el botón Run permite correr el modelo mismo.

El slider initial-people-go-in permite seleccionar la cantidad de pasajeros en la estación que podrían subir al bus. Una cantidad entre 0 y 160. Con el slider percentaje-people-go-in se establece el porcentaje (de 0 a 100) de las personas de la estación que realmente desean subir al bus mismo. 

El slider initial-people-go-out permite seleccionar la cantidad de pasajeros dentro del bus que podrían bajar del mismo. Una cantidad entre 0 y 160. Con el slider percentaje-people-go-out se establece el porcentaje (de 0 a 100) de las personas dentro del bus que realmente desean bajar del mismo. 

Los monitores permiten ver la cantidad de personas que faltan por subir o bajar del bus respectivamente, mientras que la gráfica permite ver los cambios de estas variables en cada tick de una manera comparativa, donde la línea azul representa la cantidad de personas que faltan por subir al bus, mientras la línea naranja representa la cantidad de personas que faltan por bajar del mismo.

## THINGS TO NOTICE

Considerar que un bus de Transmilenio soporta un máximo teórico de 160 pasajeros, por lo que tratar de mantener una cantidad de personas superior dentro del bus implicará que no converja.

## THINGS TO TRY

Casos extremos:

- Slider de initial-people-go-out en 160 y percentaje-people-go-out en 100, mientras que el slider de initial-people-go-in está en 160 y percentaje-people-go-in en 100. Comparar con los tiempos de la configuración initial-people-go-out en 160 y percentaje-people-go-out en 50, mientras que el slider de initial-people-go-in está en 160 y percentaje-people-go-in en 50. Aunque involucra la misma cantidad de personas, si las personas que no se van a subir o bajar, no están obstaculizando las puertas, el flujo de entrada y salida es muy bueno.

- Comparar los tiempos de la configuración: Slider de initial-people-go-out en 160 y percentaje-people-go-out en 100, mientras que el slider de initial-people-go-in está en 0. Comparar con initial-people-go-out en 0, mientras que el slider de initial-people-go-in está en 160 y percentaje-people-go-in en 100. Dado que se está dando prioridad a la salida, y que el área del bus es más reducida que el de la estación, las personas bajan más rápido de lo que suben.


## EXTENDING THE MODEL

Integrar la capacidad de enviar mensajes de un agente a otro (de una persona a otra[s]), simulando el comportamiento de solicitar permiso para poder pasar.

## NETLOGO FEATURES

Se usaron las características comunes de NetLogo. 

Sin embargo, sería provechoso poder ubicar de una manera mucho más sencilla a todos los agentes en diferentes parcelas, sin que se sobrepusieran al crearlos de manera aleatoria. Aunque hay una instrucción que lo permite, hace que el agente se desplace a cualquier parte del mundo, sin embargo, se requería poder definir una parte del mundo para mover al agente, por lo que no se pudo utilizar dicha instrucción.

## RELATED MODELS

"Traffic Basic": a simple model of the movement of cars on a highway.

Traffic 2 Lanes": a more sophisticated two-lane version of the "Traffic Basic" model.

"Traffic Intersection": a model of cars traveling through a single intersection.

## CREDITS AND REFERENCES

Autores:
Jorge Eliécer Gantiva Ochoa - jgantiva@unbosque.edu.co
Andrés Felipe Rodriguez Casteñada - aferodriguez@unbosque.edu.co
Johana Andrea Castellanos Fonseca - castellanosf@unbosque.edu.co

Profesor:
Orlando López Cruz - orlandolopez@unbosque.edu.co
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
0
@#$#@#$#@
