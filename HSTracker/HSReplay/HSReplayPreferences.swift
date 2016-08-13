//
//  HSReplayPreferences.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 13/08/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import MASPreferences

class HSReplayPreferences: NSViewController {
    @IBOutlet weak var synchronizeMatches: NSButton!
    @IBOutlet weak var hsReplayAccountStatus: NSTextField!
    @IBOutlet weak var claimAccountButton: NSButtonCell!
    @IBOutlet weak var claimAccountInfo: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = Settings.instance
        
        synchronizeMatches.state = settings.hsReplaySynchronizeMatches ? NSOnState : NSOffState
        if let username = Settings.instance.hsReplayUsername {
            hsReplayAccountStatus.stringValue =
                String(format: NSLocalizedString("Connected as %@", comment: ""), username)
            claimAccountInfo.enabled = false
            claimAccountButton.enabled = false
        } else {
            hsReplayAccountStatus.stringValue = NSLocalizedString("Account status : Anonymous",
                                                                  comment: "")
        }
    }
    
    @IBAction func checkboxClicked(sender: NSButton) {
        let settings = Settings.instance
        
        if sender == synchronizeMatches {
            settings.hsReplaySynchronizeMatches = synchronizeMatches.state == NSOnState
        }
    }
    
    @IBAction func claimAccount(sender: AnyObject) {
        HSReplayAPI.claimAccount()
    }
}

// MARK: - MASPreferencesViewController
extension HSReplayPreferences: MASPreferencesViewController {
    override var identifier: String? {
        get {
            return "hsreplay"
        }
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage! {
        return NSImage(named: "hsreplay_icon")
    }
    
    var toolbarItemLabel: String! {
        return "HSReplay"
    }
}