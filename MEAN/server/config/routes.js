
var Listener = require('./../controllers/listeners.js');
var Broadcaster = require('./../controllers/broadcasters.js');
var Users = require('./../controllers/users.js');
var Playlists = require('./../controllers/playlists.js');

module.exports = (function (app,io,db){

    /*HTTP*/
    app.post('/users/login', function (req,res){
        Users.login(req,res,db);
    });
    app.post('/tracks/create', function (req,res){
        Playlists.add_track(req,res,db);
    });
    app.post('/playlists/complete_playlist_info',function (req,res){
        Playlists.get_playlist(req,res,db);
    });
    app.post('/playlists/position', function (req,res){
        Playlists.update_position(req,res,db);
    });
    app.post('/playlists/broadcast', function (req,res){
        Playlists.update_broadcasting(req,res,db);
    });
    app.get('/playlists/all_broadcasts', function (req,res){
        Playlists.get_all_broadcasts(req,res,db);
    });



    /*Sockets*/
    io.sockets.on('connection', function(socket){
        console.log("got a connection!");

        socket.on('disconnect', function () {
            console.log(socket.id + " DISCONNECTED");
          });
        socket.on('/set_socket_id',function (data){
            console.log("joining socket " + socket.id + " to room " + data.user_id);
            socket.join(data.user_id);
        });

        /*Listener Routes*/
        socket.on('/listener/join', function (data){
            //update broadcaster, update db
            console.log("??");
            Listener.join(data,socket,io);
        });
        socket.on('/listener/request_playback_info', function (data){
            //pass along request to broadcaster
            Listener.request_playback_info(data,socket,io);
        });
        socket.on('/listener/like_track', function (data){
            //update broadcaster and update db
            Listener.like_track(data,socket,io);
        });
        /*Broadcaster Routes*/
        socket.on('/broadcaster/added_track', function (data){
            //tell listeners to call for the new tracks
            Broadcaster.added_track(data,socket,io);
        });
        socket.on('/broadcaster/reply_playback_info', function (data){
            //pass along info to original requester
            Broadcaster.reply_playback_info(data,socket,io);
        });
    });
});