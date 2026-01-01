  const http = require('http');
  const os = require('os');

  const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(`
      <h1>Test Deploy Works!</h1>
      <p>Time: ${new Date().toISOString()}</p>
      <p>Host: ${os.hostname()}</p>
    `);
  });

  server.listen(3000, () => console.log('Server running on port 3000'));
