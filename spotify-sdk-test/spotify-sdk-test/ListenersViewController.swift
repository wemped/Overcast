//
//  ListenersViewController.swift
//  spotify-sdk-test
//
//  Created by Kai Bachmann on 9/15/15.
//  Copyright © 2015 Drake Wempe. All rights reserved.
//

import UIKit

class ListenersViewController: UITableViewController {
    weak var backButtonDelegate: BackButtonDelegate?
    
    @IBAction func backButtonClicked(sender: UIBarButtonItem) {
        backButtonDelegate?.backButtonPressedFrom(self)
    }
}
