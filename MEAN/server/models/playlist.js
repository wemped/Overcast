module.exports = (function (){
    return {
        create_playlist : function (db,user_id,callback){
            var query_string = "INSERT INTO playlists (user_id) VALUES (?)";
            query_string = db.format(query_string,[user_id]);
            db.query(query_string, function (err,rows,fields){
                if (err){
                    console.log(err);
                    callback(null);
                }else{
                    callback(rows.insertId);
                }
            });
        },
        get_position : function (db,playlist_id,callback){
            var query_string = "SELECT playlists.current_position FROM playlists WHERE playlists.id = ?";
            query_string = db.format(query_string,[playlist_id]);
            db.query(query_string, function (err,rows,fields){
                if (err){
                    console.log(err);
                    callback(null);
                }else{
                    console.log(rows[0].current_position);
                    callback(rows[0].current_position);
                }
            });
        },
        update_position : function (db, playlist_id, position, callback){
            var query_string = "UPDATE playlists SET current_position = ? WHERE id = ?";
            query_string = db.format(query_string,[position,playlist_id]);
            db.query(query_string, function (err,rows,fields){
                if (err){
                    console.log(err);
                    callback(null);
                }else{
                    callback(true);
                }
            });
            // UPDATE `overcast`.`playlists` SET `current_position`='1' WHERE `id`='1';
        },
        update_broadcasting : function (db, playlist_id, broadcasting,callback){
            var bc;
            if (broadcasting){
                bc = 1;
            }else{
                bc = 0;
            }
            var query_string = "UPDATE playlists SET broadcasting = ? WHERE id = ?";
            query_string = db.format(query_string,[bc,playlist_id]);
            db.query(query_string, function (err,rows,fields){
                if (err){
                    console.log(err);
                    callback (null);
                }else{
                    callback(true);
                }
            });
        },
        all_broadcasts : function (db, callback){
            var query_string = "SELECT playlists.id AS playlist_id, playlists.current_position AS position, users.id AS user_id, users.username AS username FROM playlists JOIN users on playlists.user_id = users.id WHERE playlists.broadcasting = 1";
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