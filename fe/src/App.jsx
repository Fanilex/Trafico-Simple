'use client'
import { useRef, useState } from "react";

export default function Home() {
  let [location, setLocation] = useState("");
  let [cars, setCars] = useState([]);
  let [simSpeed, setSimSpeed] = useState(10);
  const running = useRef(null);

  let setup = () => {
    console.log("Hola");
    fetch("http://localhost:8000/simulations", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    }).then(resp => resp.json())
    .then(data => {
      console.log(data);
      setLocation(data["Location"]);
      setCars(data["cars"]);
    });
  }

  const handleStart = () => {
    running.current = setInterval(() => {
      fetch("http://localhost:8000" + location)
      .then(res => res.json())
      .then(data => {
        setCars(data["cars"]);
      });
    }, 1000 / simSpeed);
  };

  const handleStop = () => {
    clearInterval(running.current);
  }

  const handleSimSpeedSliderChange = (event, newValue) => {
    setSimSpeed(newValue);
  };

  return (
    <main>
      <div>
        <button variant={"contained"} onClick={setup}>
          Setup
        </button>
        <button variant={"contained"} onClick={handleStart}>
          Start
        </button>
        <button variant={"contained"} onClick={handleStop}>
          Stop
        </button>
      </div>
      <svg width="800" height="500" xmlns="http://www.w3.org/2000/svg" style={{ backgroundColor: "lightgreen" }}>
      
        {/* Calle horizontal */}
        <rect x={0} y={200} width={800} height={80} style={{ fill: "lightblue" }}></rect>
        
        {/* Calle vertical */}
        <rect x={350} y={0} width={80} height={500} style={{ fill: "lightblue" }}></rect>

        {/* Semaforo horizontal */}
        <g transform="translate(330, 240)">
          <rect width={20} height={40} style={{ fill: "black" }} />
          <circle cx={10} cy={10} r={5} style={{ fill: "red" }} />
          <circle cx={10} cy={20} r={5} style={{ fill: "yellow" }} />
          <circle cx={10} cy={30} r={5} style={{ fill: "green" }} />
        </g>

        {/* Semaforo vertical */}
        <g transform="translate(390, 180) rotate(90)">
          <rect width={20} height={40} style={{ fill: "black" }} />
          <circle cx={10} cy={10} r={5} style={{ fill: "red" }} />
          <circle cx={10} cy={20} r={5} style={{ fill: "yellow" }} />
          <circle cx={10} cy={30} r={5} style={{ fill: "green" }} />
        </g>

        {/* Mostrar los carros en horizontal */}
        {
          cars.map((car, index) => (
            <image
              key={car.id}
              x={car.pos[0] * 32}
              y={200 + car.pos[1] * 20}
              width={32}
              href={car.id === 1 ? "./pato.png" : "./pato.png"}
            />
          ))
        }

        {/* Mostrar los carros en vertical */}
        {
          cars.map((car, index) => (
            <image
              key={car.id}
              y={car.pos[0] * 32}
              x={380 + car.pos[1] * 20}
              width={32}
              href={car.id === 1 ? "./pato.png" : "./pato.png"}
              transform={`rotate(90, ${380 + car.pos[1] * 20 + 16}, ${car.pos[0] * 32 + 16})`}
            />
          ))
        }
      </svg>
    </main>
  );
}
