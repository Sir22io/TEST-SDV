import React, { useState } from 'react';

export default function Login({ setToken }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const handleLogin = async (e) => {
    e.preventDefault();
    const resp = await fetch("/api/auth/token", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({username, password})
    });
    if (resp.ok) {
      const data = await resp.json();
      setToken(data.access_token);
      localStorage.setItem("token", data.access_token);
    } else {
      alert("Erreur de connexion");
    }
  };
  return (
    <form onSubmit={handleLogin}>
      <h2>Connexion</h2>
      <input value={username} onChange={e=>setUsername(e.target.value)} placeholder="Nom d'utilisateur" />
      <input type="password" value={password} onChange={e=>setPassword(e.target.value)} placeholder="Mot de passe" />
      <button type="submit">Se connecter</button>
    </form>
  );
}
