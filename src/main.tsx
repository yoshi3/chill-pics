import React from 'react';
import reactDom from 'react-dom/client';
import App from './App.tsx';
import './index.css';

const rootElement = document.createElement('div');
rootElement.setAttribute('id', 'root');
document.body.appendChild(rootElement);

reactDom.createRoot(rootElement).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
