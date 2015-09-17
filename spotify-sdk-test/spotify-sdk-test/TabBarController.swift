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
class TabBarController : UITabBarController, BroadcastDelegate, BroadcasterSocketDelegate, ListenerSocketDelegate, OvercastServerHTTPDelegate {
    var session : SPTSession!
    var playlistController : BroadcastViewController?
    var searchController : SearchViewController?
    var searchBroadcastsController : SearchBroadcastsTableViewController?
    var RailsServerUrl = "http://192.168.1.102:3000"
    var UserID : Int!
    var BroadcastID : Int!
    
    /*
        Saves all its tab controllers in variables and sets the Home tab as the selected one
    */
    override func viewDidLoad() {
        let controllers = self.viewControllers
        for controller in controllers! {
            if controller.title == "PlaylistViewController"{
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
        self.selectedViewController = self.playlistController
    }
    
    //MARK: - Playlist Delegate functions
    func addToPlaylist(track partialTrack : SPTPartialTrack){
        self.pushAddedTrackToServer(partialTrack)
    }
    
    // MARK: - Overcast Server HTTP Request functions
    func pushAddedTrackToServer(track: SPTPartialTrack) {
        print("playlist id : \(self.BroadcastID)")
        print("playable uri : \(track.playableUri)")
        let dict = [
            "spotify_id" : track.identifier,
            "title" : track.name,
            "artist" : track.artists[0].name,
            "duration" : String(track.duration) ,
            "playable_uri" : String(track.playableUri),
            "spotify_uri" : String(track.uri),
            "playlist_id" : String(self.BroadcastID)
        ]
        do {
            let JSONData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
            let JSONString = NSString(data: JSONData, encoding: NSUTF8StringEncoding)
            if let urlToReq = NSURL(string: RailsServerUrl + "/tracks/create"){
                let request = NSMutableURLRequest(URL: urlToReq)
                request.HTTPMethod = "POST"
                let bodyData = "data=\(JSONString!)"
                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
                NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                    (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    self.playlistController!.addToPlaylist(track)
                }).resume()
            }
        }catch{
            
        }
    }
    func beginBroadcast(){
        let dict = [
            "playlist_id" : String(self.BroadcastID)
        ]
        do {
            let JSONData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
            let JSONString = NSString(data: JSONData, encoding: NSUTF8StringEncoding)
            if let urlToReq = NSURL(string: RailsServerUrl + "/playlists/broadcast"){
                let request = NSMutableURLRequest(URL: urlToReq)
                request.HTTPMethod = "POST"
                let bodyData = "data=\(JSONString!)"
                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
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
            //                let bodyData = "data=\(JSONString!)"
            //                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                print("returned")
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    var broadcasts = [[String:String]]()
                    let json = JSON(data: data!)
                    for (index,object) in json{
//                        print(object["username"].stringValue)
                        var broadcast = [String:String]()
                        broadcast["username"] = object["username"].stringValue
                        broadcast["user_id"] = object["user_id"].stringValue
                        broadcast["playlist_id"] = object["playlist_id"].stringValue
                        broadcasts.append(broadcast)
//                        print(broadcasts)
                    }
                    self.searchBroadcastsController!.recieveAllBroadcasts(broadcasts)

                })
            }).resume()
        }
    }
    func getBroadcast(broadcastID: String, forView: ShowBroadcastDetailsViewController){
        let dict = [
            "playlist_id" : String(self.BroadcastID)
        ]
        do {
            let JSONData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
            let JSONString = NSString(data: JSONData, encoding: NSUTF8StringEncoding)
            if let urlToReq = NSURL(string: RailsServerUrl + "/playlists/complete_playlist_info"){
                let request = NSMutableURLRequest(URL: urlToReq)
                request.HTTPMethod = "POST"
                print("here")
                let bodyData = "data=\(JSONString!)"
                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
                NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                    (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        () -> Void in
                        let json = JSON(data: data!)
                        print(json.object)
                        var tracks = [[String:String]]()
                        for (index, object) in json{
                            var track = [String:String]()
                            track["artist"] = object["artist"].stringValue
                            track["duration"] = object["duration"].stringValue
                            track["id"] = object["id"].stringValue
                            track["playable_uri"] = object["playable_uri"].stringValue
                            track["playlist_id"] = object["playlist_id"].stringValue
                            track["spotify_id"] = object["spotify_id"].stringValue
                            track["spotify_uri"] = object["spotify_uri"].stringValue
                            track["title"] = object["title"].stringValue
                            tracks.append(track)
                        }
                        forView.receivedPlaylist(tracks)
                    })
                }).resume()
            }
        }catch{
            
        }
    }
    // MARK: - Socket Handling
    
    
    // MARK: - Broadcaster Socket Delegate functions
    func signalNextSongForced(){}
    func signalNextSong(){}
    func replyCurrentTimeRequest(){}
    func gotListenerJoin(){}
    func gotListenerLikeTrack(){}
    // MARK: - Listener Socket Delegate functions
    func gotNextSongForced(){}
    func gotNextSong(){}
    func requestCurrentTime(){}
    func joinStation(){}
    func likeTrack(){}
    func recievedCurrentTimeReply(){}
}
