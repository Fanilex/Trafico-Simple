'use client'
import { useRef, useState } from "react";

export default function Home() {
  let [location, setLocation] = useState("");          // Almacena la URL de la simulación
  let [verticalCars, setVerticalCars] = useState([]);  // Almacena datos de los coches verticales
  let [lightHorizontal, setLightHorizontal] = useState("green");  // Estado del semáforo horizontal
  let [lightVertical, setLightVertical] = useState("red");        // Estado del semáforo vertical
  let [simSpeed, setSimSpeed] = useState(10);          // Velocidad de simulación (steps por segundo)
  let [horizontalCars, setHorizontalCars] = useState([]);  // Almacena datos de los coches horizontales
  const running = useRef(null);  // Mantiene la referencia al intervalo de la simulación

  // Configuración de la simulación
  let setup = () => {
    fetch("http://localhost:8000/simulations", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    })
      .then(resp => resp.json())
      .then(data => {
        if (data["Location"]) {
          setLocation(data["Location"]);  
          setVerticalCars(data["Verticalcars"]);   
          setHorizontalCars(data["HorizontalCars"]);   
        } else {
          console.error("Setup failed: No Location returned");
        }
      })
      .catch(err => console.error("Error during setup:", err));
  };

  // Inicia la simulación
  const handleStart = () => {
    if (!location) {
      console.error("No simulation location found. Did you run setup?");
      return;
    }
  
    running.current = setInterval(() => {
      fetch("http://localhost:8000" + location)
        .then(res => {
          if (!res.ok) { 
            return res.json().then(errData => {
              throw new Error(errData.error);
            });
          }
          return res.json();
        })
        .then(data => {
          setHorizontalCars(data["HorizontalCars"]);
          setVerticalCars(data["VerticalCars"]);
          
          // Actualizar semáforos en función de la respuesta
          const horizontalLight = data["traffic_lights"].find(light => light.pos[1] === 200);  // Ajustar según tu sistema
          const verticalLight = data["traffic_lights"].find(light => light.pos[0] === 350);  // Ajustar según tu sistema
          
          setLightHorizontal(horizontalLight.state);
          setLightVertical(verticalLight.state);
      })
        .catch(err => {
          console.error("Error during simulation:", err.message);
          handleStop();  // Detiene la simulación en caso de error
        });
    }, 1000 / simSpeed);
  };

  // Detiene la simulación
  const handleStop = () => {
    clearInterval(running.current);
  };

  return (
    <main>
      <div>
        <button onClick={setup}>Setup</button>
        <button onClick={handleStart}>Start</button>
        <button onClick={handleStop}>Stop</button>
      </div>
      <svg width="800" height="500" xmlns="http://www.w3.org/2000/svg" style={{ backgroundColor: "lightgreen" }}>
        {/* Carreteras */}
        <rect x={0} y={200} width={800} height={80} style={{ fill: "lightblue" }}></rect>
        <rect x={350} y={0} width={80} height={500} style={{ fill: "lightblue" }}></rect>

        {/* Semáforos */}
        <g transform="translate(330, 200)">
          <rect width={20} height={40} style={{ fill: "black" }} />
          <circle cx={10} cy={10} r={5} style={{ fill: lightHorizontal === "red" ? "red" : "gray" }} />
          <circle cx={10} cy={20} r={5} style={{ fill: lightHorizontal === "yellow" ? "yellow" : "gray" }} />
          <circle cx={10} cy={30} r={5} style={{ fill: lightHorizontal === "green" ? "green" : "gray" }} />
        </g>

        <g transform="translate(430, 180) rotate(90)">
          <rect width={20} height={40} style={{ fill: "black" }} />
          <circle cx={10} cy={10} r={5} style={{ fill: lightVertical === "red" ? "red" : "gray" }} />
          <circle cx={10} cy={20} r={5} style={{ fill: lightVertical === "yellow" ? "yellow" : "gray" }} />
          <circle cx={10} cy={30} r={5} style={{ fill: lightVertical === "green" ? "green" : "gray" }} />
        </g>

        {/* Coche (representado por un pato) horizontal */}
        {horizontalCars.map(car => (
          <image
            key={car.id}
            x={car.pos[0] * 32}
            y={200 + car.pos[1] * 20}
            width={32}
            href={car.id === 1 ? "./pato.png" : "./pato.png"}
          />
        ))}

        {/* Coche (representado por un pato) vertical */}
        {verticalCars.map(car => (
          <image
            key={car.id}
            x={350 + car.pos[1] * 20}
            y={car.pos[0] * 32}
            width={32}
            href={car.id === 1 ? "./pato.png" : "./pato.png"}
          />
        ))}
      </svg>
    </main>
  );
}
