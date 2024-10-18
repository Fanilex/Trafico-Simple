Introducción

A lo largo de este proyecto, hemos hecho uso de un repositorio privado en GitHub donde realizamos un número similar de commits para documentar la evolución del código, así como nuestras decisiones de diseño e implementación. Se ha seguido una estructura iterativa de desarrollo para probar, ajustar y mejorar la simulación de manera gradual.

Link al repositorio en GitHub: https://github.com/Fanilex/Trafico-Simple.git

Este documento proporciona detalles sobre la implementación del modelo, las decisiones de diseño, y las reflexiones individuales acerca de los desafíos encontrados y las soluciones adoptadas durante el desarrollo del proyecto.

Descripción General

Este proyecto implementa una simulación de tráfico simple utilizando el lenguaje de programación Julia. La simulación se centra en modelar un cruce de calles regulado por semáforos y vehículos, que siguen reglas de tráfico básicas. El proyecto se divide en tres fases, cada una agregando mayor complejidad a la simulación.

Componentes Principales

Semáforos en un Cruce: Se introducen semáforos que siguen los ciclos estándar de verde, amarillo y rojo.

Simulación de un Solo Vehículo: Se añade un único vehículo a la simulación, programado para detenerse en los semáforos.

Simulación de Múltiples Vehículos: La fase final introduce múltiples vehículos con posiciones iniciales aleatorias y diferentes velocidades. Esta fase incluye visualización y análisis de la velocidad promedio de los vehículos bajo diferentes condiciones de tráfico.

Metodología Parte 1

En la primera parte del proyecto, desarrollamos una simulación básica de un cruce con semáforos utilizando Julia y la librería Agents.jl. En esta fase, se introdujo un nuevo tipo de agente, el semáforo (TrafficLight), que se mantiene en el mismo lugar y cambia de estado siguiendo una secuencia de colores de acuerdo con la normativa de tránsito en México (verde, amarillo, rojo).

Definición del Modelo

Agente Semáforo (TrafficLight): Utilizamos un agente basado en una cuadrícula (GridAgent{2}) que tiene un atributo color para representar el color del semáforo y un atributo timer para controlar el ciclo de cambios.

Ciclo del Semáforo: La lógica del ciclo del semáforo se implementa mediante la función agent_step!, que cambia el color del semáforo en intervalos predefinidos (10 pasos para verde, 4 para amarillo, y 14 para rojo).

Inicialización del Modelo

Definimos un espacio de simulación cuadrado de 25x25 usando GridSpaceSingle, en el que se añadieron dos semáforos en posiciones específicas del cruce (por ejemplo, (12, 13) y (13, 12)). La sincronización de los semáforos se ajustó de forma que uno comenzara en verde y el otro en rojo.

Backend y Frontend

Implementamos una API utilizando Genie.jl para manejar la simulación y permitir que un frontend interactúe con la misma. Esto incluye la creación, actualización y monitoreo del estado de los semáforos en cada paso de la simulación.

En el frontend, usamos React para visualizar el cruce y los semáforos. El usuario puede iniciar la simulación, detenerla, y observar cómo los semáforos cambian de color en la interfaz gráfica.

Flujo de Trabajo

Backend en Julia: Utilizamos Genie.jl para exponer los endpoints de la API que permitieron configurar y ejecutar la simulación. Los semáforos se añadieron al modelo y su estado fue actualizado en cada ciclo.

Frontend en React: La interfaz permite configurar la simulación (setup), iniciarla (start), y detenerla (stop). Los semáforos se visualizan en una cuadrícula que representa el cruce de calles, y cambian de color en función de su estado.

Resultados de la Primera Parte

Esta primera parte sirvió como base para entender el comportamiento del cruce de calles y cómo los semáforos pueden regular el flujo. Implementamos una sincronización correcta para evitar colisiones, estableciendo los ciclos del semáforo según las normas de tránsito. Esto nos permitió asegurarnos de que cada luz se sincronizara correctamente y evitara conflictos durante la simulación.

Metodología Parte 2

En la segunda parte del proyecto, extendimos la simulación para agregar un vehículo al modelo. Este vehículo debía interactuar correctamente con los semáforos, deteniéndose si el semáforo estaba en amarillo o rojo y avanzando solo cuando la luz estuviera en verde.

Definición del Vehículo

Agente Vehículo (Car): Definimos un nuevo tipo de agente mutable Car con atributos como id, pos (posición), vel (velocidad) y accelerating (booleano que indica si está acelerando).

Interacción con los Semáforos: La lógica para manejar la interacción del vehículo con los semáforos se añadió en la función agent_step!. El vehículo verifica si se encuentra cerca de un semáforo y ajusta su velocidad dependiendo del color del semáforo.

Inicialización del Modelo

Se agregó un solo vehículo que comienza en una posición aleatoria a lo largo de la calle horizontal, excluyendo la zona donde se encuentran los semáforos.

Se utilizó un enfoque basado en ContinuousSpace para definir el espacio de simulación, lo cual permitió una representación más precisa del movimiento del vehículo.

Backend y Frontend

API con Genie.jl: La API se amplió para manejar la inclusión del vehículo y permitir la actualización de su estado en cada paso de la simulación.

Frontend en React: Se actualizó la interfaz para mostrar la posición del vehículo y su interacción con los semáforos. Se añadió la lógica para visualizar el movimiento del vehículo y cómo este se detiene o avanza según el estado del semáforo.

Resultados de la Segunda Parte

En esta etapa, se validó que el vehículo se detuviera correctamente ante un semáforo en rojo o amarillo, y solo avanzara cuando la luz estuviera en verde. Esto permitió simular un comportamiento básico de respeto a las señales de tráfico, asegurando que no se invadieran los carriles perpendiculares y evitando posibles colisiones.
