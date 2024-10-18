# Simulación de Tráfico en Julia

Este proyecto implementa una simulación de tráfico simple utilizando el lenguaje de programación **Julia**. La simulación se centra en modelar un cruce de calles regulado por semáforos y vehículos, que siguen reglas de tráfico básicas. El proyecto se divide en tres fases, cada una agregando mayor complejidad a la simulación.

## Componentes Principales

- **Semáforos en un Cruce:** Se introducen semáforos que siguen los ciclos estándar de verde, amarillo y rojo.
- **Simulación de un Solo Vehículo:** Se añade un único vehículo a la simulación, programado para detenerse en los semáforos.
- **Simulación de Múltiples Vehículos:** La fase final introduce múltiples vehículos con posiciones iniciales aleatorias y diferentes velocidades. Esta fase incluye visualización y análisis de la velocidad promedio de los vehículos bajo diferentes condiciones de tráfico.

---

## Metodología Parte 1

En la primera parte del proyecto, desarrollamos una simulación básica de un cruce con semáforos utilizando **Julia** y la librería **Agents.jl**. En esta fase, se introdujo un nuevo tipo de agente, el semáforo (`TrafficLight`), que sigue una secuencia de colores de acuerdo con las normas de tránsito en México (verde, amarillo, rojo).

### Definición del Modelo

- **Agente Semáforo (`TrafficLight`):** Utilizamos un agente basado en una cuadrícula (`GridAgent{2}`) que tiene un atributo `color` para representar el color del semáforo y un atributo `timer` para controlar el ciclo de cambios.
- **Ciclo del Semáforo:** La lógica del ciclo del semáforo se implementa mediante la función `agent_step!`, que cambia el color del semáforo en intervalos predefinidos (10 pasos para verde, 4 para amarillo, y 14 para rojo).

### Inicialización del Modelo

- Definimos un espacio de simulación cuadrado de `25x25` usando `GridSpaceSingle`, en el que se añadieron dos semáforos en posiciones específicas del cruce (por ejemplo, `(12, 13)` y `(13, 12)`).
- La sincronización de los semáforos se ajustó de forma que uno comenzara en verde y el otro en rojo.

### Backend y Frontend

- **Backend con Genie.jl:** Implementamos una API utilizando **Genie.jl** para manejar la simulación y permitir que un frontend interactúe con la misma. Esto incluye la creación, actualización y monitoreo del estado de los semáforos en cada paso de la simulación.
- **Frontend con React:** En el frontend, usamos **React** para visualizar el cruce y los semáforos. El usuario puede iniciar la simulación, detenerla, y observar cómo los semáforos cambian de color en la interfaz gráfica.

### Flujo de Trabajo

1. **Backend en Julia:** Utilizamos **Genie.jl** para exponer los endpoints de la API que permitieron configurar y ejecutar la simulación. Los semáforos se añadieron al modelo y su estado fue actualizado en cada ciclo.
2. **Frontend en React:** La interfaz permite configurar la simulación (setup), iniciarla (start), y detenerla (stop). Los semáforos se visualizan en una cuadrícula que representa el cruce de calles, y cambian de color en función de su estado.

### Resultados de la Primera Parte

- Implementamos una sincronización correcta para evitar colisiones, estableciendo los ciclos del semáforo según las normas de tránsito.
- Nos aseguramos de que cada luz se sincronizara correctamente y evitara conflictos durante la simulación.

---

## Metodología Parte 2

En la segunda parte del proyecto, extendimos la simulación para agregar un vehículo al modelo. Este vehículo debía interactuar correctamente con los semáforos, deteniéndose si el semáforo estaba en amarillo o rojo y avanzando solo cuando la luz estuviera en verde.

### Definición del Vehículo

- **Agente Vehículo (`Car`):** Definimos un nuevo tipo de agente mutable `Car` con atributos como `id`, `pos` (posición), `vel` (velocidad) y `accelerating` (booleano que indica si está acelerando).
- **Interacción con los Semáforos:** La lógica para manejar la interacción del vehículo con los semáforos se añadió en la función `agent_step!`. El vehículo verifica si se encuentra cerca de un semáforo y ajusta su velocidad dependiendo del color del semáforo.

### Inicialización del Modelo

- Se agregó un solo vehículo que comienza en una posición aleatoria a lo largo de la calle horizontal, excluyendo la zona donde se encuentran los semáforos.
- Se utilizó un enfoque basado en **ContinuousSpace** para definir el espacio de simulación, lo cual permitió una representación más precisa del movimiento del vehículo.

### Backend y Frontend

- **API con Genie.jl:** La API se amplió para manejar la inclusión del vehículo y permitir la actualización de su estado en cada paso de la simulación.
- **Frontend en React:** Se actualizó la interfaz para mostrar la posición del vehículo y su interacción con los semáforos. Se añadió la lógica para visualizar el movimiento del vehículo y cómo este se detiene o avanza según el estado del semáforo.

### Resultados de la Segunda Parte

- El vehículo se detiene correctamente ante un semáforo en rojo o amarillo y solo avanza cuando la luz está en verde.
- Se simuló un comportamiento básico de respeto a las señales de tráfico, evitando posibles colisiones y asegurando que no se invadieran los carriles perpendiculares.

---

## Metodología Parte 3

En la tercera parte del proyecto, se introdujeron múltiples vehículos en la simulación. Estos vehículos comienzan en posiciones y velocidades aleatorias y pueden interactuar con los semáforos de manera independiente. La fase final incluyó la visualización de la velocidad promedio de los vehículos.

### Definición de Múltiples Vehículos

- **Velocidad Aleatoria y Guiada por Slider:** Se agregó la funcionalidad para alternar entre velocidades aleatorias y controladas por el slider mediante un switch en la interfaz.
- **Interacción con Semáforos y otros Vehículos:** Los vehículos interactúan con los semáforos y también pueden ajustar su velocidad si hay otro vehículo en el mismo carril.

### Análisis de la Velocidad Promedio

- **Monitoreo de la Velocidad Promedio:** Se implementó un monitoreo de la velocidad promedio de los vehículos en la simulación. Los resultados se compararon bajo diferentes configuraciones: velocidad aleatoria vs controlada por slider y con diferentes números de vehículos (3, 5 y 7 autos).

---

  ### Análisis con 3 carros
  - Aceleración y desaceleración: Las fluctuaciones en la velocidad promedio reflejan la interacción directa de los vehículos con los semáforos, donde los estados rojo y verde provocan detenciones y aceleraciones, respectivamente.
  - Sincronización de los semáforos: La estabilización de la velocidad promedio a partir de los 100 segundos indica que los semáforos y los vehículos han alcanzado un estado de equilibrio en la simulación, donde los vehículos no están siendo interrumpidos y pueden moverse a su velocidad máxima.
  - Interacción efectiva con el entorno: La simulación responde adecuadamente a las reglas de tránsito implementadas, con un comportamiento coherente que refleja las fases de los semáforos y las dinámicas del tráfico.
  
  ![image](https://github.com/user-attachments/assets/479d74a2-0029-4226-8aae-4656dc80422e)

### Análisis con 5 carros
  - Aceleración y desaceleración: La caída y recuperación en la velocidad promedio observada en los primeros 60 segundos indica una interacción continua de los vehículos con los semáforos. Las fluctuaciones en esta etapa sugieren que los vehículos están desacelerando o deteniéndose temporalmente, pero también acelerando cuando los semáforos cambian a verde.
  - Patrón de tráfico estabilizado: La estabilización en la velocidad promedio cerca de 1 a partir de los 100 segundos sugiere que los vehículos han alcanzado un patrón de tráfico estable, donde los semáforos ya no están causando interrupciones significativas en el flujo.
  - Interacciones menos severas: A pesar de las pequeñas caídas en la velocidad promedio alrededor de los 120 segundos, la magnitud de las fluctuaciones es menor, lo que sugiere que la simulación ha entrado en una fase de interacción más fluida entre los vehículos y los semáforos.

  ![image](https://github.com/user-attachments/assets/a732d0d2-9319-48b7-9c26-1d75b66c9d39)
 
### Análisis con 7 carros
  - Mayor densidad de vehículos: Con 7 patos, se observan más caídas pronunciadas en la velocidad promedio en comparación con las simulaciones anteriores. Esto sugiere que la mayor densidad de vehículos provoca más interacciones con los semáforos, lo que ralentiza el flujo del tráfico de manera más frecuente.
  - Interacciones más complejas: Las fluctuaciones son más notables y frecuentes en comparación con las simulaciones de 3 y 5 patos, lo que implica que la cantidad de vehículos en el sistema aumenta la complejidad de la simulación. Las caídas rápidas en la velocidad promedio indican que hay más vehículos que se detienen en los semáforos simultáneamente, lo que provoca interrupciones más grandes en el flujo de tráfico.
  - Recuperación más lenta: Aunque los vehículos eventualmente alcanzan una velocidad cercana a 1, la recuperación es más lenta y menos constante debido a la mayor cantidad de vehículos y su interacción con el entorno.
  - 
  ![image](https://github.com/user-attachments/assets/cdcce8ab-a1c4-4e10-9e1f-b943e1f9c0cf)

### Compración de las 3 graficas
- 3 patos: La simulación con 3 patos es la más estable y presenta el flujo de tráfico más fluido. Las fluctuaciones son menores, y los vehículos alcanzan rápidamente una velocidad promedio constante, lo que sugiere que hay menos interacción con los semáforos y menos colisiones o detenciones simultáneas.
- 5 patos: A medida que aumenta la densidad, también lo hacen las fluctuaciones en la velocidad promedio. Sin embargo, la simulación aún logra estabilizarse después de 100 segundos, aunque con más interrupciones que en la simulación con 3 patos.
- 7 patos: Con 7 patos, la simulación presenta las mayores fluctuaciones y caídas en la velocidad promedio. La densidad adicional de vehículos provoca más interrupciones en el flujo de tráfico, lo que retrasa la estabilización y provoca un comportamiento más caótico.

En resumen, a mayor densidad de vehículos, mayor es el número de fluctuaciones y caídas en la velocidad promedio, lo que retrasa la estabilización del tráfico. Sin embargo, incluso con 7 patos, los vehículos logran eventualmente alcanzar una velocidad promedio constante, aunque el proceso es más lento y está plagado de más interrupciones.

---

## Conclusión

Este proyecto permitió simular el comportamiento de un cruce de calles regulado por semáforos y múltiples vehículos que interactúan con las señales de tráfico. A lo largo de las tres fases del proyecto, se construyeron capacidades más avanzadas de simulación, desde la sincronización de semáforos hasta el manejo de múltiples vehículos con velocidades aleatorias o guiadas por el usuario.

---

## Tecnologías Utilizadas

- **Julia**
  - Agents.jl
  - Genie.jl
- **React**
  - Plotly.js para visualización de datos
