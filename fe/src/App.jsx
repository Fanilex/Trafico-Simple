'use client'
import { useRef, useState } from "react";

export default function Home() {
  let [location, setLocation] = useState("");
  let [trafficLights, setTrafficLights] = useState([]);
  let [simSpeed, setSimSpeed] = useState(2);
  const running = useRef(null);

  let setup = () => {
    console.log("Configurando simulación");
    fetch("http://localhost:8000/simulations", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ })
    }).then(resp => resp.json())
    .then(data => {
      console.log("Datos recibidos en setup:", data);
      setLocation(data["Location"]);
      setTrafficLights(data["traffic_lights"]);
    });
  }

  const handleStart = () => {
    running.current = setInterval(() => {
      fetch("http://localhost:8000" + location)
      .then(res => res.json())
      .then(data => {
        console.log("Datos recibidos en actualización:", data);
        setTrafficLights(data["traffic_lights"]);
      });
    }, 1000 / simSpeed);
  };

  const handleStop = () => {
    clearInterval(running.current);
  }

  const handleSimSpeedSliderChange = (event, newValue) => {
    setSimSpeed(newValue);
  };

  // escala de los semáforos
  const scale = 20;
  const offsetX = -10;
  const offsetY = -10;

  return (
    <main>
      <div>
        <button onClick={setup}>
          Setup
        </button>
        <button onClick={handleStart}>
          Start
        </button>
        <button onClick={handleStop}>
          Stop
        </button>
      </div>
      <svg width="500" height="500" xmlns="http://www.w3.org/2000/svg" style={{backgroundColor:"lightgray"}}>
        {/* Dibujar las calles */}
        <rect x={200} y={0} width={100} height={500} style={{fill: "darkgray"}} />
        <rect x={0} y={200} width={500} height={100} style={{fill: "darkgray"}} />

        {/* Dibujar los semáforos */}
        {trafficLights.map(light => (
          <rect
            key={light.id}
            x={(light.pos[0] * scale) + offsetX}
            y={(light.pos[1] * scale) + offsetY}
            width={20}
            height={20}
            fill={
              light.color === "green" ? "green" :
              light.color === "yellow" ? "yellow" :
              "red"
            }
          />
        ))}
      </svg>
    </main>
  );
}
