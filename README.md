# Modelo de Simulación de Tráfico en Julia

## Descripción General

Este proyecto implementa una simulación de tráfico simple utilizando el lenguaje de programación Julia. La simulación se centra en modelar un cruce de calles regulado por semáforos y vehículos, que siguen reglas de tráfico básicas. El proyecto se divide en tres fases, cada una agregando mayor complejidad a la simulación.

### Componentes Principales:
1. **Semáforos en un Cruce:** Se introducen semáforos que siguen los ciclos estándar de verde, amarillo y rojo.
2. **Simulación de un Solo Vehículo:** Se añade un único vehículo a la simulación, programado para detenerse en los semáforos.
3. **Simulación de Múltiples Vehículos:** La fase final introduce múltiples vehículos con posiciones iniciales aleatorias y diferentes velocidades. Esta fase incluye visualización y análisis de la velocidad promedio de los vehículos bajo diferentes condiciones de tráfico.

## Estructura del Proyecto

### Parte 1: Agregar Semáforos a la Simulación

- Definimos un nuevo agente, el `Semaforo`, que sigue un ciclo de semáforo basado en el utilizado en México (Verde-Amarillo-Rojo).
- El espacio de simulación se redimensiona para acomodar la representación visual del cruce de calles.
- Se añaden dos semáforos sincronizados en el cruce para gestionar el flujo de tráfico.
- La función `agent_step!` se actualiza para controlar el tiempo asignado a cada color del semáforo, con:
  - **10 unidades de tiempo en verde**
  - **4 unidades de tiempo en amarillo**
  - **14 unidades de tiempo en rojo**

Los semáforos deben estar correctamente sincronizados para evitar colisiones en el cruce.

### Parte 2: Agregar un Solo Vehículo

- Se agrega un solo vehículo a la simulación, comenzando en una posición aleatoria en la calle horizontal (evitando la zona del semáforo).
- El comportamiento del vehículo está programado para detenerse en la luz amarilla o roja, asegurando que no invada el carril perpendicular.
- Se modifica la función `agent_step!` para manejar el comportamiento del vehículo en el cruce, deteniéndose a una distancia adecuada cuando la luz no está en verde.

### Parte 3: Agregar Múltiples Vehículos

- Se expande la simulación para incluir múltiples vehículos en cada calle (hasta 5 por calle), con posiciones iniciales aleatorias y diferentes velocidades.
- Los vehículos pueden acelerar o desacelerar según las condiciones del tráfico, evitando colisiones.
- Se utiliza un ícono más pequeño para los vehículos, proporcionando más espacio para la visualización.
- La simulación informa sobre la velocidad promedio de los vehículos cuando se ejecuta con 3, 5 y 7 vehículos por calle, permitiendo un análisis del rendimiento.
- Se incluye una visualización para monitorear la simulación en tiempo real, proporcionando información sobre el flujo general del tráfico y la velocidad promedio.

## Requisitos

- Julia (versión 1.x o posterior)
- Agents.jl: Un paquete de Julia para modelado basado en agentes.

## Cómo Ejecutar la Simulación

Para ejecutar la simulación:

1. Clona este repositorio.
2. Instala los paquetes de Julia necesarios ejecutando:
   ```bash
   ] add Agents Makie
