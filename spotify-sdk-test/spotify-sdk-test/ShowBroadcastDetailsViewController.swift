//
//  ShowBroadcastDetailsViewController.swift
//  spotify-sdk-test
//
//  Created by Drake Wempe on 9/16/15.
//  Copyright © 2015 Drake Wempe. All rights reserved.
//

import UIKit

class ShowBroadcastDetailsViewController: UIViewController, UITableViewDataSource, CanReceivePlaylist{

    @IBOutlet weak var tableView: UITableView!
    let globals = Globals()
//    var playlist : [OVCTrack]?
    var playlist : OVCPlaylist?
    var player : SPTAudioStreamingController!
    var session : SPTSession!
    var listener : ListenerSocketDelegate!
    var broadcaster_id : String!
    var playlist_id : String!
    var broadcaster_username : String!
    var backDelegate : BackButtonDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player = SPTAudioStreamingController(clientId: globals.SpotifyClientID)
        self.tableView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receivedPlaylist(tracks : [OVCTrack], position: Int){
//        self.playlist = tracks
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.playlist = OVCPlaylist(tracks: tracks, playlistPosition: position, session: self.session)
            self.tableView.reloadData()
        })
    }
    
    func beginListenAt(trackPosition : Double, playlistPosition : Int, onTrackSpotifyID : String){
//        let partialTrack = self.playlist![playlistPosition]
//        let playableUri = partialTrack.playableURI
//        let trackUri = partialTrack.spotifyURI
        
        //check if the correct song is playing
        print("in begin listening")
        if self.playlist!.playlistPosition == playlistPosition{
            print("on the correct song already")
            let diff = abs(self.player.currentPlaybackPosition - trackPosition)
            print("diff ====> \(diff)")
            if diff > 0.05{
                if self.player.isPlaying{
                    self.player.seekToOffset(NSTimeInterval(trackPosition), callback: {
                        (error: NSError!) -> Void in
                        
                    })
                }else{
//                    let track = self.playlist!.getCurrentTrack()
//                    self.player!.loginWithSession(self.session) {
//                        (error: NSError!) -> Void in
//                        
//                        self.player!.playURI(track?.playableUri, callback: {
//                            (error: NSError!) -> Void in
//                            self.listener.requestPlaybackInfo(self.playlist_id,broadcaster_id: self.broadcaster_id)
//                        })
//                    }
                }
            }
        }else{
            print("not on the correct song")
            self.playlist!.playlistPosition = playlistPosition
            let track = self.playlist!.getCurrentTrack()
            self.player!.loginWithSession(self.session) {
                (error: NSError!) -> Void in
                self.player!.playURI(track?.playableUri, callback: {
                    (error: NSError!) -> Void in
                    self.listener.requestPlaybackInfo(self.playlist_id,broadcaster_id: self.broadcaster_id)
                })
            }
        }
            //if so : 
                //check if diff is big enough
                    //if so : seek
                    //if not : do nothing
            //if not : login, request, play, and request playback
        
//        self.player!.loginWithSession(self.session) {
//            (error: NSError!) -> Void in
//            
//            SPTRequest.requestItemAtURI(trackUri, withSession: nil, callback: {
//                (error: NSError!, object: AnyObject!) -> Void in
//                let track = object as! SPTTrack
//                //mute
//                //play
//                //seek
//                //request playback info
//                //on reply start
//                let diff = abs(self.player.currentPlaybackPosition - trackPosition)
//                self.player!.playURI(track.playableUri, callback: {
//                    (error : NSError!) -> Void in
//                    print("playing...")
//                    print("local current time : \(self.player.currentPlaybackPosition)")
//                    print("given track time : \(trackPosition)")
//                    print("DIFF -> \(diff)")
//                    self.player.seekToOffset(NSTimeInterval(trackPosition), callback: {
//                        (error: NSError!) -> Void in
//                        print("SEEKING")
//                        print(diff)
//                        if diff > 0.1 {
//                            self.listener.requestPlaybackInfo(self.playlist_id, broadcaster_id: self.broadcaster_id)
//                        }else{
//                            print("UNDER 100 ms :]]]]]")
//                        }
//                        
//                    })
//                })
//            })
//        }
    }
    // MARK: - UI Button handlers
    @IBAction func playButtonPressed(sender: UIButton) {
        print("^_^_^_^_^_^_")
        self.listener.joinStation(self.playlist_id, broadcaster_id: broadcaster_id)
        self.listener.requestPlaybackInfo(self.playlist_id, broadcaster_id: broadcaster_id)
    }

    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.backDelegate.backButtonPressedFrom(self)
    }
    
    // MARK: - Table View functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.playlist != nil{
            return self.playlist!.count
        }
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dequeued = tableView.dequeueReusableCellWithIdentifier("playlistTrackCell")
        let cell = dequeued as! PlaylistTrackCell
        let tuple = self.playlist!.trackAtIndex(indexPath.row)
        if tuple.1 == TrackType.Overcast{
            let track = tuple.0 as! OVCTrack
            cell.trackArtistLabel.text = track.artist
            cell.trackTitleLabel.text = track.title
        }
        if tuple.1 == TrackType.Spotify{
            let track = tuple.0 as! SPTTrack
            cell.trackArtistLabel.text = track.artists[0].name
            cell.trackTitleLabel.text = track.name
        }
        if indexPath.row > self.playlist?.playlistPosition{
            cell.backgroundColor = .whiteColor()
        }else{
            cell.backgroundColor = .grayColor()
        }
//        cell.trackArtistLabel.text = self.playlist![indexPath.row].artist
//        cell.trackTitleLabel.text = self.playlist![indexPath.row].title
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
