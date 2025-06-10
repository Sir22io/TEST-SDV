import React, { useState } from 'react';
import Login from './Login';
import ScanPage from './ScanPage';

function App() {
  const [token, setToken] = useState(localStorage.getItem("token") || "");

  return (
    <div>
      {!token ?
        <Login setToken={setToken} /> :
        <ScanPage token={token} />
      }
    </div>
  );
}

export default App;
