'use client'
import { useRef, useState } from "react";

export default function Home() {
  let [location, setLocation] = useState(""); 
  let [cars, setCars] = useState([]);  
  let [lightHorizontal, setLightHorizontal] = useState("green");
  let [lightVertical, setLightVertical] = useState("red");
  let [simSpeed, setSimSpeed] = useState(10);
  const running = useRef(null);

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
          setCars(data["cars"]);  
        } else {
          console.error("Setup failed: No Location returned");
        }
      })
      .catch(err => console.error("Error during setup:", err));
  };

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
          setCars(data["cars"]);
          setLightHorizontal(data["traffic_lights"]["horizontal"]);
          setLightVertical(data["traffic_lights"]["vertical"]);
        })
        .catch(err => {
          console.error("Error during simulation:", err.message);
          handleStop();  
        });
    }, 1000 / simSpeed);
  };

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
        {/* Calles */}
        <rect x={0} y={200} width={800} height={80} style={{ fill: "lightblue" }}></rect>
        <rect x={350} y={0} width={80} height={500} style={{ fill: "lightblue" }}></rect>

        {/* Semáforos */}
        <g transform="translate(330, 240)">
          <rect width={20} height={40} style={{ fill: "black" }} />
          <circle cx={10} cy={10} r={5} style={{ fill: lightHorizontal === "red" ? "red" : "gray" }} />
          <circle cx={10} cy={20} r={5} style={{ fill: lightHorizontal === "yellow" ? "yellow" : "gray" }} />
          <circle cx={10} cy={30} r={5} style={{ fill: lightHorizontal === "green" ? "green" : "gray" }} />
        </g>

        <g transform="translate(390, 180) rotate(90)">
          <rect width={20} height={40} style={{ fill: "black" }} />
          <circle cx={10} cy={10} r={5} style={{ fill: lightVertical === "red" ? "red" : "gray" }} />
          <circle cx={10} cy={20} r={5} style={{ fill: lightVertical === "yellow" ? "yellow" : "gray" }} />
          <circle cx={10} cy={30} r={5} style={{ fill: lightVertical === "green" ? "green" : "gray" }} />
        </g>

        {/* Renderizar los coches */}
        {cars.map(car => (
          <image
            key={car.id}
            x={car.pos[1] === 0 ? car.pos[0] * 32 : 370}  
            y={car.pos[1] === 0 ? 240 : car.pos[1] * 32}  
            width={32}
            href={car.pos[1] === 0 ? "./pato_horizontal.png" : "./pato_vertical.png"} 
          />
        ))}
      </svg>
    </main>
  );
}
