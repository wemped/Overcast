module.exports = (function (){
    return {
        get_user : function(db,username,callback){
            var query_string = "SELECT * FROM users WHERE username = ?";
            query_string = db.format(query_string,[username]);
            db.query(query_string, function (err,rows,fields){
                if(err){
                    console.log(err);
                    callback(null);
                }else{
                    callback(rows[0]);
                }
            });
        },
        get_playlist_id : function(db, user_id, callback){
            var query_string = "SELECT id FROM playlists WHERE user_id = ?";
            query_string = db.format(query_string,[user_id]);
            db.query(query_string,function (err,rows,fields){
                if (err){
                    console.log(err);
                    callback(null);
                }else{
                    callback(rows[0]['id']);
                }
            });
        },
        create_user : function (db, username, password, callback){
            var query_string = "INSERT INTO users (username,password,created_at,updated_at) VALUES (?,?,NOW(),NOW())";
            query_string = db.format(query_string,[username,password]);
            db.query(query_string, function (err, rows, fields){
                if (err){
                    console.log(err);
                    callback(null);
                }else{
                    callback(rows.insertId);
                }
            });
        }
    };
})();