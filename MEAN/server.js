var express = require("express");
// var path = require("path");
var bodyParser = require('body-parser');
var io = require('socket.io');

var app = express();
var server = app.listen(1337);
console.log("Listening on port 1337");

app.use(bodyParser.urlencoded());
app.use(bodyParser.json());

io = io.listen(server);
require('./server/config/routes.js')(app,io);