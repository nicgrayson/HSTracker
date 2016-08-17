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
    @IBOutlet weak var showPushNotification: NSButton!
    private var getAccountTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = Settings.instance
        
        synchronizeMatches.state = settings.hsReplaySynchronizeMatches ? NSOnState : NSOffState
        showPushNotification.state = settings.showHSReplayPushNotification ? NSOnState : NSOffState
        updateStatus()
    }
    
    override func viewDidDisappear() {
        if let timer = getAccountTimer {
            timer.invalidate()
        }
    }
    
    @IBAction func checkboxClicked(sender: NSButton) {
        let settings = Settings.instance
        
        if sender == synchronizeMatches {
            settings.hsReplaySynchronizeMatches = synchronizeMatches.state == NSOnState
        } else if sender == showPushNotification {
            settings.showHSReplayPushNotification = showPushNotification.state == NSOnState
        }
    }
    
    @IBAction func claimAccount(sender: AnyObject) {
        HSReplayAPI.getUploadToken { _ in
            HSReplayAPI.claimAccount()
            
            self.getAccountTimer = NSTimer.scheduledTimerWithTimeInterval(5,
                target: self,
                selector: #selector(self.checkAccountInfo),
                userInfo: nil,
                repeats: true)
        }
    }
    
    @objc private func checkAccountInfo() {
        HSReplayAPI.updateAccountStatus() { (status) in
            if status {
                self.getAccountTimer?.invalidate()
            }
            self.updateStatus()
        }
    }
    
    private func updateStatus() {
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