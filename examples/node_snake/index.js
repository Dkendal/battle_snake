const http = require('http')

function start(game) {
  return {
    name: 'Snek',
    color: '#bb2233',
  }
}

function move(data) {
  return {
    move: "up",
    taunt: "Boop the snoot!",
  }
}

/**
 * HTTP Server
 * Boilerplate server to receive and respond to POST requests
 * other requests will be returned immediately with no data
 */
http.createServer((req, res) => {
  if (req.method !== 'POST') return respond(); // non-game requests

  let body = [];
  req.on('data', chunk => body.push(chunk));
  req.on('end', () => {
    body = JSON.parse(Buffer.concat(body).toString());
    if (req.url === '/start') message = start(body);
    if (req.url === '/move') message = move(body);
    return respond(message);
  });

  function respond(message) {
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify(message));
  }
}).listen(process.env.PORT || 80, console.error)
