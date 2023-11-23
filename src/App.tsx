import { useState, useEffect, useRef } from 'react';
import reactLogo from './assets/react.svg';
import noiseImage from '/noise-image.jpg';
import viteLogo from '/vite.svg';
import './App.css';

const App = () => {
  const [count, setCount] = useState(0);

  return (
    <>
    <div>
      <a href="https://vitejs.dev" target="_blank" rel="noreferrer">
        <img src={viteLogo} className="logo" alt="Vite logo" />
      </a>
      <a href="https://react.dev" target="_blank" rel="noreferrer">
        <img src={reactLogo} className="logo react" alt="React logo" />
      </a>
    </div>
    <h1>Vite + React</h1>
    <div className="card">
      <button type="button" onClick={() => setCount((count) => count + 1)}>
        count is {count}
      </button>
      <p>
        Edit <code>src/App.tsx</code> and save to test HMR
      </p>
    </div>
    <p className="read-the-docs">Click on the Vite and React logos to learn more</p>
    <RemoveNoise />
  </>
  );
};

export default App;

type RemoveNoiseExports = {
  removeNoise: (data: number, width: number, height: number, range?: number) => void;
  wasmMemory: WebAssembly.Memory;
};

const memory = new WebAssembly.Memory({
  initial: 100 /* pages */,
  maximum: 200 /* pages */,
});

const RemoveNoise = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const context = canvas.getContext('2d');
    if (!context) return;

    const image = new Image();
    image.src = noiseImage;

    image.onload = () => {
      canvas.width = image.width;
      canvas.height = image.height;
      context.drawImage(image, 0, 0, canvas.width, canvas.height);

      WebAssembly.instantiateStreaming(fetch('/wasm/removeNoise.wasm'), { env: { memory } }).then(
        (result) => {
          const wasmExports = result.instance.exports as RemoveNoiseExports;
          const wasmMemoryArray = new Uint8Array(wasmExports.wasmMemory.buffer);

          const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
          const data = new Uint8ClampedArray(wasmExports.wasmMemory.buffer, 0, imageData.data.length);
          data.set(imageData.data);
          wasmExports.removeNoise(data.byteOffset, canvas.width, canvas.height, 2);
          imageData.data.set(wasmMemoryArray.subarray(0, imageData.data.length));
          context.putImageData(imageData, 0, 0);
        }
      );
    };
  }, []);

  return <canvas ref={canvasRef} />;
};
