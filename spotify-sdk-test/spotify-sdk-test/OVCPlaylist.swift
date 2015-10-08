//
//  OVCPlaylist.swift
//  spotify-sdk-test
//
//  Created by Drake Wempe on 9/18/15.
//  Copyright © 2015 Drake Wempe. All rights reserved.
//

import Foundation

class OVCPlaylist {
    
//    var viewController : DisplaysPlaylistInfo?
    var willNotLoad = [OVCTrack]()
    var loaded = [SPTTrack]()
    var toLoad = [OVCTrack]()
    let session : SPTSession
    var playlistPosition : Int
    var count : Int{
        get {
            return self.willNotLoad.count + self.loaded.count + self.toLoad.count
        }
    }
    init(tracks : [OVCTrack], playlistPosition : Int, session : SPTSession){
        self.playlistPosition = playlistPosition
        self.session = session
        var count = 0
        while count < self.playlistPosition {
            self.willNotLoad.append(tracks[count])
            count++
        }
        while count < tracks.count{
            self.addTrackToPlaylist(tracks[count])
            count++
        }
    }
    func getFirst() -> SPTTrack?{
        if self.loaded.count > 0 {
            return self.loaded[0]
        }
        return nil
    }
    func getCurrentTrack() -> SPTTrack?{
        let tuple = self.trackAtIndex(self.playlistPosition)
        if (tuple.1 == TrackType.Spotify){
            return tuple.0 as! SPTTrack
        }else{
            return nil
        }
    }
    func addTrackToPlaylist(partial : SPTPartialTrack){
        print("in the playlist object")
        let track = OVCTrack(spotifyTrack: partial)
        self.toLoad.append(track)
        let position = self.loaded.count + self.toLoad.count - 1
        self.loadInBackground(track, position: position)
    }
    func addTrackToPlaylist(ovcTrack : OVCTrack){
        self.toLoad.append(ovcTrack)
        let position = self.loaded.count + self.toLoad.count - 1
        self.loadInBackground(ovcTrack, position: position)
    }
    func loadInBackground(ovcTrack: OVCTrack, position: Int){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            () -> Void in
            print(ovcTrack.spotifyURI)
            SPTRequest.requestItemAtURI(ovcTrack.spotifyURI, withSession: self.session, callback: {
                (error: NSError!, object: AnyObject!) -> Void in
                let track = object as! SPTTrack
                for var index = 0; index < self.toLoad.count; index++ {
                    if self.toLoad[index].spotifyID == track.identifier{
                        self.toLoad.removeAtIndex(index)
//                        if position == self.playlistPosition {
//                            viewController.resetNowPlayingInfo(track: track)
//                        }
                        if position > self.loaded.count{
                            self.loaded.append(track)
                        }else{
                            self.loaded.insert(track, atIndex: position)
                        }
                        print("full track loaded")
                    }
                }
            })
        })
    }
    func trackAtIndex(index : Int) -> (AnyObject?, TrackType){
        if index > self.count || index < 0{
            return (nil,TrackType.None)
        }
        if index < self.willNotLoad.count {
            return (self.willNotLoad[index], TrackType.Overcast)
        }
        if index < self.loaded.count + self.willNotLoad.count {
            let newIndex = index - self.willNotLoad.count
            return (self.loaded[newIndex], TrackType.Spotify)
        }
        if index < self.toLoad.count + self.loaded.count + self.toLoad.count {
            let newIndex = index - self.willNotLoad.count - self.loaded.count
            return (self.toLoad[newIndex], TrackType.Overcast)
        }
        else{
            return (nil,TrackType.None)
        }
    }
    func removeTrack(spotifyID: String, index: Int){
        if index > self.count || index < 0{
            return
        }
        if index < self.willNotLoad.count {
            if self.willNotLoad[index].spotifyID == spotifyID{
                self.willNotLoad.removeAtIndex(index)
            }
        }
        if index < self.loaded.count + self.willNotLoad.count {
            let newIndex = index - self.willNotLoad.count
            if self.loaded[newIndex].identifier == spotifyID{
                self.loaded.removeAtIndex(newIndex)
            }
        }
    }
}