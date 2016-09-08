//
//  PluginManager.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 6/09/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import CleanroomLogger

class PluginManager {
    static let instance = PluginManager()
    var plugins = [HSTrackerPlugin]()
    
    func loadPlugins() {
        if let destination = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory,
                                                                 .UserDomainMask, true).first {
            let path = "\(destination)/HSTracker/plugins"
            do {
                try NSFileManager.defaultManager()
                    .createDirectoryAtPath(path,
                                           withIntermediateDirectories: true,
                                           attributes: nil)
            } catch {
                Log.error?.message("Can not create plugins dir")
                return
            }
            
            let pluginUrls: [NSURL]
            do {
                pluginUrls = try NSFileManager.defaultManager()
                    .contentsOfDirectoryAtURL(NSURL(fileURLWithPath: path),
                                              includingPropertiesForKeys: [],
                                              options: .SkipsHiddenFiles)
            } catch {
                Log.error?.message("Can not list \(path)")
                return
            }
            
            guard !pluginUrls.isEmpty else {
                Log.verbose?.message("No plugin to load")
                return
            }
            
            Log.verbose?.message("content : \(pluginUrls)")
            pluginUrls.forEach {
                guard $0.pathExtension == "hsplugin" else {
                    Log.verbose?.message("\($0.pathExtension) is not a valid extension")
                    return
                }
                
                guard let bundle = NSBundle(URL: $0) else {
                    Log.verbose?.message("\($0) is not a valid bundle (init)")
                    return
                }
                
                do {
                    try bundle.preflight()
                } catch {
                    Log.verbose?.message("\($0) is not a valid bundle (preflight)")
                    return
                }
                
                do {
                    try bundle.loadAndReturnError()
                } catch {
                    Log.verbose?.message("\($0) is not a valid bundle (load and return)")
                    return
                }
                
                Log.verbose?.message("\(bundle.principalClass)")
                guard let clazz = bundle.principalClass as? NSObject.Type else {
                    Log.verbose?.message("\($0) is not a valid bundle (principal class)")
                    return
                }
                guard let plugin = clazz.init() as? HSTrackerPlugin else {
                    Log.verbose?.message("\($0) is not a valid bundle (plugin init)")
                    return
                }
                Log.verbose?.message("Loading \(plugin.name)")
                self.plugins.append(plugin)
            }
        }
        
        plugins.forEach {
            $0.onLoad?()
        }
    }
    
    func onGameReset() {
        plugins.forEach {
            $0.onGameReset?()
        }
    }
    
    func onGameStart(time: NSDate) {
        plugins.forEach {
            $0.onGameStart?(time)
        }
    }
    
    func onGameEnd() {
        plugins.forEach {
            $0.onGameEnd?()
        }
    }
    
    func onSaveMatch() {
        plugins.forEach {
            $0.onSaveMatch?()
        }
    }
    
    func turnStart(player: PlayerTurn) {
        plugins.forEach {
            $0.turnStart?("\(player.player)", turn: player.turn)
        }
    }
}