const http = require('http');

const port = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  // TODO: implement webhook handling for provider: ${provider_name}
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('ok\n');
});

server.listen(port, () => {
  console.log('webhook handler listening on :' + port);
});
