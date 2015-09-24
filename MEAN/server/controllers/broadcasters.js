module.exports = (function(){
    return {
        //tell listeners to call for the new tracks
        added_track : function (data,socket,io){

        },
        //pass along info to original requester
        reply_playback_info : function (data,socket,io){
            console.log("sending playback info to " + data.requested_id);
            io.to(data.requested_id).emit("/reply_playback_info",data);
        }
    };
})();