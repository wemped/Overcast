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
    var playlist : [OVCTrack]?
    var player : SPTAudioStreamingController!
    var session : SPTSession!
    var listener : ListenerSocketDelegate!
    var broadcaster_id : String!
    var playlist_id : String!
    var broadcaster_username : String!
    
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
        self.playlist = tracks
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    func beginListenAt(trackPosition : Double, playlistPosition : Int, onTrackSpotifyID : String){
        let partialTrack = self.playlist![playlistPosition]
        let playableUri = partialTrack.playableURI
        let trackUri = partialTrack.spotifyURI
        self.player!.loginWithSession(self.session) {
            (error: NSError!) -> Void in
            
            SPTRequest.requestItemAtURI(trackUri, withSession: nil, callback: {
                (error: NSError!, object: AnyObject!) -> Void in
                let track = object as! SPTTrack
                self.player!.playURI(track.playableUri, callback: {
                    (error : NSError!) -> Void in
                    self.player.seekToOffset(NSTimeInterval(trackPosition), callback: {
                        (error: NSError!) -> Void in
                        print("SEEKING")
                    })
                })
            })
        }
    }
    // MARK: - UI Button handlers
    @IBAction func playButtonPressed(sender: UIButton) {
        print("^_^_^_^_^_^_")
        self.listener.joinStation(self.playlist_id, broadcaster_id: broadcaster_id)
        self.listener.requestPlaybackInfo(self.playlist_id, broadcaster_id: broadcaster_id)
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
        cell.trackArtistLabel.text = self.playlist![indexPath.row].artist
        cell.trackTitleLabel.text = self.playlist![indexPath.row].title
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
