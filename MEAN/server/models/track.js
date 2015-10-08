module.exports = (function (){
    return {
        add_track : function (db,track_info,callback){
            // console.log("track info : " + track_info.title);
            // var title = track_info["title"];
            // console.log("title : " + title);
            var query_string = "INSERT INTO tracks (playlist_id, title, artist, album, duration, playable_uri, spotify_id, created_at, updated_at,playlist_index,spotify_uri) VALUES (?,?,?,?,?,?,?,NOW(),NOW(),?,?)";
            query_string = db.format(query_string, [track_info.playlist_id,track_info.title,track_info.artist,track_info.album,track_info.duration,track_info.playable_uri,track_info.spotify_id,track_info.position,track_info.spotify_uri]);
            db.query(query_string, function (err, rows, fields){
                if (err){
                    console.log(err);
                    callback(null);
                }else{
                    track_info.track_id = rows.insertId;
                    callback(track_info);
                }
            });
        },
        all_playlist : function (db,playlist_id,callback){
            var query_string = "SELECT * FROM tracks WHERE tracks.playlist_id = ? ORDER BY playlist_index   ";
            query_string = db.format(query_string, [playlist_id]);
            db.query(query_string, function (err,rows,fields){
                if (err){
                    console.log(err);
                    callback(null);
                }else{
                    console.log(rows);
                    callback(rows);
                }
            });
        }
    };
})();