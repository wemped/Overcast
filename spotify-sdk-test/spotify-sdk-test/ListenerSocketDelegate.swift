//
//  ListenerSocketDelegate.swift
//  spotify-sdk-test
//
//  Created by Drake Wempe on 9/15/15.
//  Copyright © 2015 Drake Wempe. All rights reserved.
//

import Foundation

protocol ListenerSocketDelegate : class {
    func gotNextSongForced()
    func gotNextSong()
    func requestCurrentTime()
    func joinStation()
    func likeTrack()
    func recievedCurrentTimeReply()
}