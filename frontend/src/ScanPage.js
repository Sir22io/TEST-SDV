import React, { useState } from 'react';

export default function ScanPage({ token }) {
  const [target, setTarget] = useState('');
  const [result, setResult] = useState('');
  const [pdf, setPdf] = useState('');

  const handleScan = async () => {
    const resp = await fetch("/api/scan/nmap", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + token
      },
      body: JSON.stringify({target})
    });
    if (resp.ok) {
      const data = await resp.json();
      setResult(data.output);
      setPdf(data.pdf_report);
    } else {
      alert("Erreur scan");
    }
  };

  return (
    <div>
      <h2>Scan Nmap automatisé</h2>
      <input value={target} onChange={e=>setTarget(e.target.value)} placeholder="Cible (IP ou domaine)" />
      <button onClick={handleScan}>Lancer Scan</button>
      <pre>{result}</pre>
      {pdf && <a href={`/backend/reporting/${pdf}`} target="_blank" rel="noopener noreferrer">Télécharger le rapport PDF</a>}
    </div>
  );
}
