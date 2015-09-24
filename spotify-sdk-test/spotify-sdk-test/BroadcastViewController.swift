//
//  playlistViewController.swift
//  spotify-sdk-test
//
//  Created by Drake Wempe on 9/8/15.
//  Copyright © 2015 Drake Wempe. All rights reserved.
//

import UIKit
import MediaPlayer

class BroadcastViewController : UIViewController, SPTAudioStreamingPlaybackDelegate, UITableViewDataSource, BackButtonDelegate, CanReceivePlaylist {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nowPlayingAlbumLabel: UILabel!
    @IBOutlet weak var nowPlayingArtistLabel: UILabel!
    @IBOutlet weak var nowPlayingTrackLabel: UILabel!
    @IBOutlet weak var nowPlayingImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var globals = Globals()
    var ClientId : String!
    var session : SPTSession!
    var player : SPTAudioStreamingController?
    var playlist : OVCPlaylist?
//    var queueToLoad = [OVCTrack]()
//    var oldTracks = [OVCTrack]()
    var tabController : TabBarController!
    var RailsServerUrl : String!
    var forced_stop : Bool = false
    @IBOutlet weak var muteButoon: UIButton!
    var muted = false
//    var playlistPosition = 0
    
    /*
        Set Spotify Session. If We aren't playing right now make play button visible.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ClientId = globals.SpotifyClientID
        self.RailsServerUrl = globals.RailsServer
        self.tableView.dataSource = self
        let tabController = self.tabBarController as! TabBarController
        self.session = tabController.session
//        if self.playlist.count > 0 {
//            self.resetNowPlayingInfo(track: self.playlist[self.playlistPosition])
//        }
        if self.player == nil {
            self.player = SPTAudioStreamingController(clientId: ClientId)
            self.player!.playbackDelegate = self
        }
        self.playlist = OVCPlaylist(tracks: [OVCTrack](), playlistPosition: 0, session: self.session)
//        self.playButton.hidden = true
    }
    
    //MARK: - UI Button Handlers
    @IBAction func nextButtonClicked(sender: UIButton) {
//        self.forced_stop = true
//        self.player?.stop(nil)
//        if self.playlist.first != nil{
//            self.playlistPosition++
////            self.playlist.removeFirst()
//            self.playNextSong()
//            self.tableView.reloadData()
//        }else{
//            //Set all info to empty
//        }
        self.forced_stop = true
        self.player?.stop(nil)
        self.playlist!.playlistPosition++
        self.playNextSong()
        self.tableView.reloadData()
    }
    @IBAction func playButtonClicked(sender: UIButton) {
        print("clicked play")
        self.tabController.beginBroadcast()
        self.playNextSong()
        sender.hidden = true
    }
    @IBAction func muteButtonPressed(sender: UIButton) {
        if self.muted == false{
            self.toggleMute()
            self.muteButoon.setTitle("Unmute", forState: UIControlState.Normal)
        }else{
            self.toggleMute()
            self.muteButoon.setTitle("Mute", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func changeTabToSearchController(sender: UIButton) {
        self.tabController.changeTabToSearch()
    }
    //MARK: - Table View functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.playlist != nil{
            return self.playlist!.count

        }
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dequeued : AnyObject = tableView.dequeueReusableCellWithIdentifier("playlistTrackCell",forIndexPath: indexPath)
        let cell = dequeued as! PlaylistTrackCell
        let tuple = self.playlist!.trackAtIndex(indexPath.row)
        if tuple.1 == TrackType.Overcast{
            let track = tuple.0 as! OVCTrack
            cell.trackArtistLabel.text = track.artist
            cell.trackTitleLabel.text = track.title
//            cell.backgroundColor = .grayColor()
        }else if tuple.1 == TrackType.Spotify{
            let track = tuple.0 as! SPTTrack
            cell.trackArtistLabel.text = track.artists[0].name
            cell.trackTitleLabel.text = track.name
//            cell.backgroundColor = .whiteColor()
        }else{
            
        }
        if indexPath.row < self.playlist!.playlistPosition{
            cell.backgroundColor = .grayColor()
        }else{
            cell.backgroundColor = .whiteColor()
        }
        return cell
//        if indexPath.row < self.oldTracks.count {
//            let ovcTrack = self.oldTracks[indexPath.row]
//            cell.trackArtistLabel.text = ovcTrack.artist
//            cell.trackTitleLabel.text = ovcTrack.title
//            print(ovcTrack.title)
//            cell.backgroundColor = .grayColor()
//            return cell
//        }
//        if indexPath.row < self.playlist.count + self.oldTracks.count{
//            let sptTrack = self.playlist[indexPath.row - self.oldTracks.count]
//            cell.trackArtistLabel.text = sptTrack.artists[0].name
//            cell.trackTitleLabel.text = sptTrack.name!
//            print(sptTrack.name!)
//            if indexPath.row < self.playlistPosition {
//                cell.backgroundColor = .grayColor()
//            }else{
//                cell.backgroundColor = .whiteColor()
//            }
//            return cell
//        } else {
//            let ovcTrack = self.queueToLoad[indexPath.row - self.playlist.count - self.oldTracks.count]
//            cell.trackArtistLabel.text = ovcTrack.artist
//            cell.trackTitleLabel.text = ovcTrack.title
//            print(ovcTrack.title)
//            return cell
//        }
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let tuple = self.playlist!.trackAtIndex(indexPath.row)
        if tuple.1 == TrackType.Overcast{
            let track = tuple.0 as! OVCTrack
            self.tabController.removeTrackFromPlaylist(track.spotifyID, position: indexPath.row)
        } else if tuple.1 == TrackType.Spotify {
            let track = tuple.0 as! SPTTrack
            self.tabController.removeTrackFromPlaylist(track.identifier, position: indexPath.row)
        }
    }
    
    //MARK: - Playback functions
    /*
        Can be called from other views
    */
    func addToPlaylist(partialTrack: SPTPartialTrack){
        self.playlist!.addTrackToPlaylist(partialTrack)
//        let track = OVCTrack(spotifyTrack: partialTrack)
//        self.queueToLoad.append(track)
//        let position = self.playlist.count + self.queueToLoad.count - 1
//        print ("position : \(position)")
//        self.loadInBackground(track,playlistPosition: position)
//        if self.tableView != nil {
//            self.tableView.reloadData()
//        }
        self.tableView.reloadData()
    }
    func addToPlaylist(ovcTrack: OVCTrack){
        self.playlist!.addTrackToPlaylist(ovcTrack)
//        self.queueToLoad.append(ovcTrack)
//        let position = self.playlist.count + self.queueToLoad.count - 1
//        print ("position : \(position)")
//        self.loadInBackground(ovcTrack,playlistPosition: position)
//        if self.tableView != nil {
//            self.tableView.reloadData()
//        }
        self.tableView.reloadData()
    }
    func getPlaybackInfo() -> [String:String]?{
        if let track = self.playlist!.getFirst(){
            var results = [String:String]()
            results["playlist_position"] = String(self.playlist!.playlistPosition)
            results["track_spotify_id"] = track.identifier
            results["track_position"] = String(self.player!.currentPlaybackPosition)
            return results
        }
        return nil
//        let track = self.playlist[self.playlistPosition]
//        var results = [String:String]()
//        results["playlist_position"] = String(self.playlistPosition)
//        results["track_spotify_id"] = track.identifier
//        results["track_position"] = String(self.player!.currentPlaybackPosition)
//        return results
    }
    func removeTrack(spotifyID: String, position : Int){
        self.playlist!
            .removeTrack(spotifyID, index: position)
//        for var index = 0; index < self.playlist.count; index++ {
//            if self.playlist[index].identifier == spotifyID{
//                self.playlist.removeAtIndex(index)
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.tableView.reloadData()
//                })
//                return
//            }
//        }
    }
    func receivedPlaylist(tracks: [OVCTrack], position: Int){
        self.playlist = OVCPlaylist(tracks: tracks, playlistPosition: position, session: self.session)
//        print("setting it up")
////        self.queueToLoad = tracks
//        print("POSITION -> \(position)")
//        self.playlistPosition = position
//        var count = 0
//        while count < position{
//            print(tracks[count].title)
//            self.oldTracks.append(tracks[count])
//            count++
//        }
//        while count < tracks.count{
//            print(tracks[count].title)
//            self.addToPlaylist(tracks[count])
//            count++
//        }
//        dispatch_async(dispatch_get_main_queue(), {
//            () -> Void in
//            self.tableView.reloadData()
//        })
    }
    
    /*
        Requests the first song in the playlist's stream
        Start playing it
    */
    func playNextSong() {
        self.playButton.hidden = true
        if let track = self.playlist!.getFirst(){
            self.player!.loginWithSession(self.session, callback: {
                (error: NSError!) -> Void in
                if error != nil{
                    print(error)
                    return
                }
                self.player!.playURI(track.playableUri, callback: {
                    (error: NSError!) -> Void in
                    self.resetNowPlayingInfo(track: track)
                    self.tabController.updatePlaylistPosition(self.playlist!.playlistPosition)
                })
            })
        }else{
            //NO LOADED SONGS
        }
        if self.tableView != nil{
            self.tableView.reloadData()
        }
//        if self.playlist.count - self.playlistPosition >= 1 {
//            print("position in play next song :\(self.playlistPosition)")
//            print("we have a loaded song")
//            let track = self.playlist[self.playlistPosition - self.oldTracks.count]
//            player!.loginWithSession(self.session) {
//                (error: NSError!) -> Void in
//                print("logged in!")
//                self.player!.playURI(track.playableUri, callback: {
//                    (error: NSError!) -> Void in
//                    print("playing!")
//                    self.resetNowPlayingInfo(track: track)
//                    
//                    self.tabController.updatePlaylistPosition(self.playlistPosition)
//                })
//            }
//        }else{
//            print("we DONT have a loaded song")
//        }
//        if self.tableView != nil {
//            self.tableView.reloadData()
//        }
    }
//    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
//        print("DID CHANGE TO TRACK")
//        if trackMetadata != nil {
//            print(trackMetadata["SPTAudioStreamingMetadataTrackName"])
//            
//        }
//    }
    
    /*
        Called when a track stops
        forced stop is true when someone clicked next
        if the song finished, remove it from the playlist and play the next song
    */
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: NSURL!) {
        print("DID STOP PLAYING TRACK")
        if (!self.forced_stop){
            if (self.playlist!.count > 0){
                self.playlist!.playlistPosition++
                self.playNextSong()
            }
        }
        self.forced_stop = false
    }
    
    /*
        Called when a track failed to play
        Skip it and play the next song
    */
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didFailToPlayTrack trackUri: NSURL!) {
        print("DID FAIL TO PLAY TRACK")
        if (self.playlist!.count > 0){
            self.playlist!.playlistPosition++
            self.playNextSong()
        }
    }
    
//    func loadInBackground(ovctrack : OVCTrack, playlistPosition : Int){
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
//            () -> Void in
////            self.player!.loginWithSession(self.session) { (error: NSError!) -> Void in
//                SPTRequest.requestItemAtURI(ovctrack.spotifyURI, withSession: self.session, callback: {
//                    (error:NSError!, object: AnyObject!) -> Void in
//                    let track = object as! SPTTrack
//                    for var index = 0; index < self.queueToLoad.count; index++ {
//                        if self.queueToLoad[index].spotifyID == track.identifier{
//                            self.queueToLoad.removeAtIndex(index)
//                            if (playlistPosition > self.playlist.count){
//                                self.playlist.append(track)
//                            }else{
//                                self.playlist.insert(track, atIndex: playlistPosition)
//                            }
//                            if self.playlist.count == 0 {
//                                self.resetNowPlayingInfo(track: track)
//                            }
//                            print("full track loaded")
//                        }
//                    }
//                })
////            }
//        })
//    }
//    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
//        print("DID START PLAYING TRACK")
//    }
    
    /*
        Reset now playing info with track metadata if its already playing
    */
    func resetNowPlayingInfo(metadata trackMetadata : [NSObject : AnyObject]){
        let duration = trackMetadata["SPTAudioStreamingMetadataTrackDuration"] as? Int
        let artist = trackMetadata["SPTAudioStreamingMetadataArtistName"] as? String
        let album = trackMetadata["SPTAudioStreamingMetadataAlbumName"] as? String
        let track = trackMetadata["SPTAudioStreamingMetadataTrackName"] as? String
        nowPlayingTrackLabel.text = track
        nowPlayingArtistLabel.text = artist
        nowPlayingAlbumLabel.text = album
        var nowPlayingInfo : [String: AnyObject]!
        nowPlayingInfo = [
            MPMediaItemPropertyPlaybackDuration : duration as! AnyObject,
            MPMediaItemPropertyTitle : track as! AnyObject,
            MPMediaItemPropertyArtist : artist as! AnyObject,
            MPMediaItemPropertyAlbumTitle : album as! AnyObject
        ]
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nowPlayingInfo
    }
    /*
        Reset now playing info when it just started playing (metadata hasn't loaded yet)
    */
    func resetNowPlayingInfo(track full_track : SPTTrack){
        let duration = full_track.duration
        let artist = full_track.artists[0].name
        let track = full_track.name
        let album = full_track.album.name
        if nowPlayingTrackLabel != nil {
            nowPlayingTrackLabel.text = track
            nowPlayingArtistLabel.text = artist
            nowPlayingAlbumLabel.text = album
        }
        var nowPlayingInfo : [String: AnyObject]!
        nowPlayingInfo = [
            MPMediaItemPropertyPlaybackDuration : duration as AnyObject,
            MPMediaItemPropertyTitle : track as AnyObject,
            MPMediaItemPropertyArtist : artist as AnyObject,
            MPMediaItemPropertyAlbumTitle : album as AnyObject
        ]
        self.setNowPlayingImage(full_track.album.largestCover)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nowPlayingInfo
    }
    /*
        Reset now playing info before any playing
        **This only happens when people have added tracks to the playlist but have not started playing music
    */
//    func resetNowPlayingInfo(partialTrack partial : OVCTrack){
//        player!.loginWithSession(self.session) {
//            (error: NSError!) -> Void in
//            SPTRequest.requestItemFromPartialObject(partial, withSession: nil, callback: {
//                (error:NSError!, results: AnyObject!) -> Void in
//                let track = results as! SPTTrack
//                self.resetNowPlayingInfo(track: track)
//            })
//        }
//    }
    /*
        Asynchronously grabs the album art
    */
    func setNowPlayingImage(artwork : SPTImage?){
        if artwork != nil && self.nowPlayingImageView != nil{
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), { () -> Void in
                if let imageData = NSData(contentsOfURL: artwork!.imageURL){
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.nowPlayingImageView.image = UIImage(data: imageData)
                    })
                }
            })
        }
    }
    func toggleMute(){
        if self.muted == true{
            self.player?.setVolume(1, callback: {
                (error: NSError!) -> Void in
                if error != nil{
                    print(error)
                }
            })
        }else{
            self.player?.setVolume(0, callback: {
                (error: NSError!) -> Void in
                if error != nil{
                    print(error)
                }
            })
        }
        self.muted = !self.muted
    }
    // MARK - Back Button Delegate functions
    func backButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showListenersTableView" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController! as! ShowListenersTableViewController
            controller.backButtonDelegate = self
        }
    }
}
