//
//  OVCTrack.swift
//  spotify-sdk-test
//
//  Created by Drake Wempe on 9/17/15.
//  Copyright © 2015 Drake Wempe. All rights reserved.
//

import Foundation

class OVCTrack{
    
    let title : String
    let artist : String
    let duration : Double
    let playableURI : NSURL
    let spotifyURI : NSURL
    let spotifyID : String
    var broadcastID : Int?
    
    init(spotifyTrack : SPTPartialTrack){
        self.title = spotifyTrack.name
        if let artist = spotifyTrack.artists[0].name{
            self.artist = artist
        }else{
            self.artist = "Unknown Artist"
        }
        self.duration = spotifyTrack.duration
        self.playableURI = spotifyTrack.playableUri
        self.spotifyURI = spotifyTrack.uri
        self.spotifyID = spotifyTrack.identifier
    }
    init(spotifyTrack : SPTPartialTrack, broadcastID : Int){
        self.title = spotifyTrack.name
        if let artist = spotifyTrack.artists[0].name{
            self.artist = artist
        }else{
            self.artist = "Unknown Artist"
        }
        self.duration = spotifyTrack.duration
        self.playableURI = spotifyTrack.playableUri
        self.spotifyURI = spotifyTrack.uri
        self.spotifyID = spotifyTrack.identifier
        self.broadcastID = broadcastID
    }
    init(json : JSON){
        self.title = json["title"].stringValue
        self.artist = json["artist"].stringValue
        self.duration = Double(json["duration"].stringValue)!
        self.playableURI = NSURL(string: json["playable_uri"].stringValue)!
        self.spotifyURI = NSURL(string: json["spotify_uri"].stringValue)!
        self.spotifyID = json["spotify_id"].stringValue
//        print(json["playlist_position"])
    }
    
    func toJSONString(broadcastID : Int?) -> NSString?{
        var dict = [
            "title"       : self.title,
            "artist"      : self.artist,
            "duration"    : String(self.duration),
            "playable_uri": String(self.playableURI),
            "spotify_uri" : String(self.spotifyURI),
            "spotify_id"  : self.spotifyID
        ]
        if let playlist_id = broadcastID {
            dict["playlist_id"] = String(playlist_id)
        }
        do {
            let JSONData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue:0))
            let JSONString = NSString(data: JSONData, encoding: NSUTF8StringEncoding)
            return JSONString
        }catch{
            return nil
        }
    }
    static func decodeArrayOfTracksFromJSONData(data : NSData) -> [OVCTrack]?{
        let json = JSON(data: data)
        print(json.object)
        var tracks = [OVCTrack]()
        for (index, object) in json{
            tracks.append(OVCTrack(json: object))
        }
        return tracks
    }
}