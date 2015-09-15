module.exports = (function (app,io){
    io.sockets.on('connection', function(socket){
        console.log("got a connection!");
    });
});