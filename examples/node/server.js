var express = require('express');
var app = express();
app.use(require('body-parser').json());

app.post('/start', function (req, res) {
  res.send({
    name: 'node-test-snake',
    color: '#f0db4f'
  });
});

app.post('/move', function (req, res) {
  var turn = req.body.turn;
  var directions = ['up', 'left', 'down', 'right'];
  var move = directions[turn % directions.length];
  res.send({move});
});

app.listen(3000, function () {
  console.log('Snake server listening on port 3000!');
});
