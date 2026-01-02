import http from 'node:http';
import os from 'node:os';

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end(`
    <h1>Läuft!</h1>
    <p>Time: ${new Date().toISOString()}</p>
    <p>Host: ${os.hostname()}</p>
    <p>Runtime: Node ${process.version}</p>
  `);
});

server.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});