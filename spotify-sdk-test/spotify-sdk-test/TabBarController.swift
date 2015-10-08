//
//  tabBarControllerWithSession.swift
//  spotify-sdk-test
//
//  Created by Drake Wempe on 9/8/15.
//  Copyright © 2015 Drake Wempe. All rights reserved.
//

import UIKit
/*
    This acts as the go-between for the tab views
    Should have a Controller variable for each of its tabbed views
    Should have a protocol for being able to call functions in each tabbed view
    Ex. Playlist Delegate so it can add songs to the playlist in the playlist view
*/
class TabBarController : UITabBarController,
BroadcastDelegate, BroadcasterSocketDelegate, ListenerSocketDelegate, OvercastServerHTTPDelegate {
    var globals = Globals()
    var session : SPTSession!
    var playlistController : BroadcastViewController?
    var searchController : SearchViewController?
    var searchBroadcastsController : SearchBroadcastsTableViewController?
    var listenController : ShowBroadcastDetailsViewController?
    var RailsServerUrl : String!
    var UserID : Int!
    var BroadcastID : Int!
    var socket  : SocketIOClient?
    /*
        Saves all its tab controllers in variables and sets the Home tab as the selected one
    */
    override func viewDidLoad() {
        self.RailsServerUrl = globals.RailsServer
        socket = SocketIOClient(socketURL: globals.SocketURL)
        socket!.connect()
        socket!.on("connect"){
            data,ack in
            let IDString = String(self.UserID)
            self.socket?.emit("/set_socket_id", ["user_id" : IDString])
//            self.joinStation("3", broadcaster_id : "1")
        }
        socket!.on("/request_playback_info"){
            data,ack in
            self.replyCurrentTimeRequest(data)
        }
        self.socket!.on("/reply_playback_info"){
            data, ack in
            self.recievedPlaybackInfoReply(data)
        }
        let controllers = self.viewControllers
        for controller in controllers! {
            if controller.title == "PlaylistViewController" {
                self.playlistController = controller as? BroadcastViewController
                self.playlistController?.tabController = self
            }else if controller.title == "SearchViewController"{
                self.searchController = controller as? SearchViewController
            }else if controller.title == "SearchBroadcastsTableViewController"{
                self.searchBroadcastsController = controller as? SearchBroadcastsTableViewController
                self.searchBroadcastsController?.tabController = self
                self.searchBroadcastsController?.session = self.session
            }
        }
        self.getBroadcast(String(self.BroadcastID), forView: self.playlistController!)
        self.selectedViewController = self.playlistController
    }
    
    //MARK: - Playlist Delegate functions
    func addToPlaylist(track partialTrack : SPTPartialTrack){
        if let index = self.playlistController?.playlist?.count{
            self.pushAddedTrackToServer(partialTrack,position: index)
            print("got index of \(index)")
        }else{
            self.pushAddedTrackToServer(partialTrack,position: 0)
            print("got no index, using 0")
        }
    }
    func changeTabToSearch(){
        self.selectedViewController = self.viewControllers![Int(0)]
    }
    
    // MARK: - Overcast Server HTTP Request functions
    func pushAddedTrackToServer(track: SPTPartialTrack, position: Int) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            () -> Void in
            let ovcTrack = OVCTrack(spotifyTrack: track)
            let JSONString = ovcTrack.toJSONString(self.BroadcastID, position: position)
            if let urlToReq = NSURL(string: self.RailsServerUrl + "/tracks/create"){
                let request = NSMutableURLRequest(URL: urlToReq)
                request.HTTPMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                let bodyData = /*"data=\(JSONString!)"*/ JSONString!
//                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
                request.HTTPBody = JSONString!
                NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                    (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    self.playlistController!.addToPlaylist(track)
                }).resume()
            }
        })
    }
    func removeTrackFromPlaylist(spotifyID: String, position: Int){
        let dict = [
            "playlist_id" : String(self.BroadcastID),
            "spotify_id" : spotifyID
        ]
        do {
            let JSONData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
            let JSONString = NSString(data: JSONData, encoding: NSUTF8StringEncoding)
            if let urlToReq = NSURL(string: RailsServerUrl + "/tracks/destroy"){
                let request = NSMutableURLRequest(URL: urlToReq)
                request.HTTPMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                let bodyData = "data=\(JSONString!)"
                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
                NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                    (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    self.playlistController!.removeTrack(spotifyID, position: position)
                }).resume() 
            }
        }catch {
            
        }
    }
    func updatePlaylistPosition(playlistPosition: Int){
        let dict = [
            "playlist_id" : String(self.BroadcastID),
            "playlist_position" : String(playlistPosition)
        ]
        do {
            let JSONData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
//            let JSONString = NSString(data: JSONData, encoding: NSUTF8StringEncoding)
            print("sending position : \(playlistPosition)")
            if let urlToReq = NSURL(string: RailsServerUrl + "/playlists/position"){
                let request = NSMutableURLRequest(URL: urlToReq)
                request.HTTPMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                let bodyData = "data=\(JSONString!)"
//                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
                request.HTTPBody = JSONData
                NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                    (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    //Show that you are broadcasting
                }).resume()
            }
        }catch {
            
        }

    }
    func updateBroadcast(broadcasting : Bool){
        let dict = [
            "playlist_id" : String(self.BroadcastID),
            "broadcasting" : String(broadcasting)
        ]
        do {
            let JSONData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
//            let JSONString = NSString(data: JSONData, encoding: NSUTF8StringEncoding)
            if let urlToReq = NSURL(string: RailsServerUrl + "/playlists/broadcast"){
                let request = NSMutableURLRequest(URL: urlToReq)
                request.HTTPMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                let bodyData = "data=\(JSONString!)"
//                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
                request.HTTPBody = JSONData
                NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                    (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    //Show that you are broadcasting
                }).resume()
            }
        }catch {
            
        }
    }
    func getAllBroadcasts(){
        if let urlToReq = NSURL(string: RailsServerUrl + "/playlists/all_broadcasts"){
            let request = NSMutableURLRequest(URL: urlToReq)
            request.HTTPMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //                let bodyData = "data=\(JSONString!)"
            //                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                print("returned")
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    if (error != nil) {
                        print(error)
                    }
                    var broadcasts = [[String:String]]()
                    let json = JSON(data: data!)
                    print(json.object)
                    let arr = json["broadcasts"].arrayValue
                    for object in arr{
                        print(object["username"].stringValue)
                        var broadcast = [String:String]()
                        broadcast["broadcaster_username"] = object["username"].stringValue
                        broadcast["broadcaster_id"] = object["user_id"].stringValue
                        broadcast["playlist_id"] = object["playlist_id"].stringValue
                        print(broadcast)
                        broadcasts.append(broadcast)
                    }
                    self.searchBroadcastsController!.recieveAllBroadcasts(broadcasts)
                })
            }).resume()
        }
    }
    func getBroadcast(broadcastID: String, forView: CanReceivePlaylist){
        let dict = [
            "playlist_id" : String(broadcastID)
        ]
        do {
            let JSONData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
//            let JSONString = NSString(data: JSONData, encoding: NSUTF8StringEncoding)
            if let urlToReq = NSURL(string: RailsServerUrl + "/playlists/complete_playlist_info"){
                let request = NSMutableURLRequest(URL: urlToReq)
                request.HTTPMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                print("here")
//                let bodyData = "data=\(JSONString!)"
//                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
                request.HTTPBody = JSONData
                NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                    (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        () -> Void in
                        if data != nil{
                            print("got response")
                            if let ovcTracks = OVCTrack.decodeArrayOfTracksFromJSONData(data!){
                                let json = JSON(data: data!)
                                let playlistPosition = json[0]["playlist_position"].intValue
                                //                            print(json[0]["playlist_position"].stringValue)
                                forView.receivedPlaylist(ovcTracks,position : playlistPosition)
                            }
                        }else{
                            print("no response from server")
                        }
                    })
                }).resume()
            }
        }catch{
            
        }
    }
    // MARK: - Socket Handling
    
    
    // MARK: - Broadcaster Socket Delegate functions
    func signalSongChanged(){}
    func replyCurrentTimeRequest(data: NSArray?){
        let json = JSON(data!)
        let requester_id = json[0]["requester_id"].stringValue
        var playbackInfo = self.playlistController!.getPlaybackInfo()!
        playbackInfo["requested_id"] = requester_id
        let request_sent_at = json[0]["request_sent_at"].stringValue
        let reply_sent_at = String(Double(NSDate().timeIntervalSince1970))
        playbackInfo["request_sent_at"] = request_sent_at
        playbackInfo["reply_sent_at"] = reply_sent_at
        self.socket!.emit("/broadcaster/reply_playback_info", playbackInfo)
    }
    func gotListenerJoin(){}
    func gotListenerLikeTrack(){}
    
    // MARK: - Listener Socket Delegate functions
    func gotNextSongForced(){}
    func gotNextSong(){}
    func requestPlaybackInfo(playlist_id : String, broadcaster_id : String){
        print("sending playlist_id = " + playlist_id)
        let data = [
            "requester_id" : String(self.UserID),
            "broadcaster_id" : broadcaster_id,
            "broadcast_id" : playlist_id,
            "request_sent_at" : String(Double(NSDate().timeIntervalSince1970))
        ]
        self.socket!.emit("/listener/request_playback_info", data)
    }
    func joinStation(playlist_id : String, broadcaster_id : String){
        print(playlist_id + "ASDKJHASDLKJHASDLKJHASLDKJHD")
        let data = [
            "user_id" : String(self.UserID),
            "broadcast_id" : playlist_id,
            "broadcaster_id" : broadcaster_id
        ]
        self.socket!.emit("/listener/join", data)
    }
    func likeTrack(){}
    func recievedPlaybackInfoReply(data: NSArray?){
        let json = JSON(data!)
        let spotify_id = json[0]["track_spotify_id"].stringValue
        let track_position = json[0]["track_position"].doubleValue
        let playlist_postition = json[0]["playlist_position"].intValue
        let request_reply_diff = json[0]["reply_sent_at"].doubleValue - json[0]["request_sent_at"].doubleValue
        let reply_arrive_diff = Double(NSDate().timeIntervalSince1970) - json[0]["reply_sent_at"].doubleValue
        print("first diff = \(request_reply_diff)")
        print("second diff = \(reply_arrive_diff)")
        let avg_diff = (request_reply_diff + reply_arrive_diff)/2
        print("recived playback info -> playlist position \(playlist_postition) and track position \(track_position)")
        self.listenController!.beginListenAt(track_position + avg_diff, playlistPosition : playlist_postition, onTrackSpotifyID : spotify_id)
    }
}
