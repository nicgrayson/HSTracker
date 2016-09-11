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
    
    func onGameStart(time: Double) {
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
    
    func turnStart(player: String, turn: Int) {
        plugins.forEach {
            $0.turnStart?(player, turn: turn)
        }
    }

    private func translateEntity(entity: Entity) -> PluginEntity {
        let pluginEntity = PluginEntity()
        pluginEntity.id = entity.id
        pluginEntity.isPlayer = entity.isPlayer
        pluginEntity.cardId = entity.cardId
        pluginEntity.name = entity.name
        pluginEntity.tags = entity.tags
        pluginEntity.info = entity.info
        pluginEntity.isActiveDeathrattle = entity.isActiveDeathrattle
        pluginEntity.isCurrentPlayer = entity.isCurrentPlayer
        pluginEntity.isSecret = entity.isSecret
        pluginEntity.isSpell = entity.isSpell
        pluginEntity.isOpponent = entity.isOpponent
        pluginEntity.isMinion = entity.isMinion
        pluginEntity.isWeapon = entity.isWeapon
        pluginEntity.isHero = entity.isHero
        pluginEntity.isHeroPower = entity.isHeroPower
        pluginEntity.isInHand = entity.isInHand
        pluginEntity.isInDeck = entity.isInDeck
        pluginEntity.isInPlay = entity.isInPlay
        pluginEntity.isInGraveyard = entity.isInGraveyard
        pluginEntity.isInSetAside = entity.isInSetAside
        pluginEntity.isInSecret = entity.isInSecret
        pluginEntity.health = entity.health
        pluginEntity.attack = entity.attack
        pluginEntity.hasCardId = entity.hasCardId

        pluginEntity.discarded = entity.info.discarded
        pluginEntity.returned = entity.info.returned
        pluginEntity.mulliganed = entity.info.mulliganed
        pluginEntity.stolen = entity.info.stolen
        pluginEntity.created = entity.info.created
        pluginEntity.hasOutstandingTagChanges = entity.info.hasOutstandingTagChanges
        pluginEntity.originalController = entity.info.originalController
        pluginEntity.hidden = entity.info.hidden
        pluginEntity.turn = entity.info.turn
        pluginEntity.costReduction = entity.info.costReduction
        pluginEntity.originalZone = entity.info.originalZone
        pluginEntity.createdInDeck = entity.info.createdInDeck
        pluginEntity.createdInHand = entity.info.createdInHand

        return pluginEntity
    }

    // MARK: Player
    func onPlayerHero(cardId: String) {
        plugins.forEach {
            $0.onPlayerHero?(cardId)
        }
    }
    func onPlayerName(name: String) {
        plugins.forEach {
            $0.onPlayerName?(name)
        }
    }
    func onPlayerGet(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerGet?(pluginEntity, turn: turn)
        }
    }
    func onPlayerBackToHand(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerBackToHand?(pluginEntity, turn: turn)
        }
    }
    func onPlayerPlayToDeck(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerPlayToDeck?(pluginEntity, turn: turn)
        }
    }
    func onPlayerPlay(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerPlay?(pluginEntity, turn: turn)
        }
    }
    func onPlayerHandDiscard(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerHandDiscard?(pluginEntity, turn: turn)
        }
    }
    func onPlayerSecretPlayed(entity: Entity, turn: Int, fromZone: Zone) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerSecretPlayed?(pluginEntity,
                turn: turn,
                fromZone: fromZone.rawValue)
        }
    }
    func onPlayerMulligan(entity: Entity) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerMulligan?(pluginEntity)
        }
    }
    func onPlayerDraw(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerDraw?(pluginEntity, turn: turn)
        }
    }
    func onPlayerRemoveFromDeck(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerRemoveFromDeck?(pluginEntity, turn: turn)
        }
    }
    func onPlayerDeckDiscard(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerDeckDiscard?(pluginEntity, turn: turn)
        }
    }
    func onPlayerDeckToPlay(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerDeckToPlay?(pluginEntity, turn: turn)
        }
    }
    func onPlayerPlayToGraveyard(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerPlayToGraveyard?(pluginEntity, turn: turn)
        }
    }
    func onPlayerJoust(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerJoust?(pluginEntity, turn: turn)
        }
    }
    func onPlayerGetToDeck(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerGetToDeck?(pluginEntity, turn: turn)
        }
    }
    func onPlayerFatigue(value: Int) {
        plugins.forEach {
            $0.onPlayerFatigue?(value)
        }
    }
    func onPlayerCreateInPlay(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerCreateInPlay?(pluginEntity, turn: turn)
        }
    }
    func onPlayerRemoveFromPlay(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onPlayerRemoveFromPlay?(pluginEntity, turn: turn)
        }
    }
    func onPlayerHeroPower(cardId: String, turn: Int) {
        plugins.forEach {
            $0.onPlayerHeroPower?(cardId, turn: turn)
        }
    }

    // MARK: Opponent
    func onOpponentHero(cardId: String) {
        plugins.forEach {
            $0.onOpponentHero?(cardId)
        }
    }
    func onOpponentName(name: String) {
        plugins.forEach {
            $0.onOpponentName?(name)
        }
    }
    func onOpponentGet(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentGet?(pluginEntity, turn: turn)
        }
    }
    func onOpponentBackToHand(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentBackToHand?(pluginEntity, turn: turn)
        }
    }
    func onOpponentPlayToDeck(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentPlayToDeck?(pluginEntity, turn: turn)
        }
    }
    func onOpponentPlay(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentPlay?(pluginEntity, turn: turn)
        }
    }
    func onOpponentHandDiscard(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentHandDiscard?(pluginEntity, turn: turn)
        }
    }
    func onOpponentSecretPlayed(entity: Entity, turn: Int, fromZone: Zone) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentSecretPlayed?(pluginEntity,
                turn: turn,
                fromZone: fromZone.rawValue)
        }
    }
    func onOpponentMulligan(entity: Entity) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentMulligan?(pluginEntity)
        }
    }
    func onOpponentDraw(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentDraw?(pluginEntity, turn: turn)
        }
    }
    func onOpponentRemoveFromDeck(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentRemoveFromDeck?(pluginEntity, turn: turn)
        }
    }
    func onOpponentDeckDiscard(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentDeckDiscard?(pluginEntity, turn: turn)
        }
    }
    func onOpponentDeckToPlay(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentDeckToPlay?(pluginEntity, turn: turn)
        }
    }
    func onOpponentPlayToGraveyard(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentPlayToGraveyard?(pluginEntity, turn: turn)
        }
    }
    func onOpponentJoust(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentJoust?(pluginEntity, turn: turn)
        }
    }
    func onOpponentGetToDeck(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentGetToDeck?(pluginEntity, turn: turn)
        }
    }
    func onOpponentFatigue(value: Int) {
        plugins.forEach {
            $0.onOpponentFatigue?(value)
        }
    }
    func onOpponentPlayToHand(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentPlayToHand?(pluginEntity, turn: turn)
        }
    }
    func onOpponentSecretTrigger(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentSecretTrigger?(pluginEntity, turn: turn)
        }
    }
    func onOpponentCreateInPlay(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentCreateInPlay?(pluginEntity, turn: turn)
        }
    }
    func onOpponentRemoveFromPlay(entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onOpponentRemoveFromPlay?(pluginEntity, turn: turn)
        }
    }
    func onOpponentHeroPower(cardId: String, turn: Int) {
        plugins.forEach {
            $0.onOpponentHeroPower?(cardId, turn: turn)
        }
    }

    func onStolenByOpponent(player: PlayerType, entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onStolenByOpponent?(player.rawValue, entity: pluginEntity, turn: turn)
        }
    }
    func onStolenFromOpponent(player: PlayerType, entity: Entity, turn: Int) {
        let pluginEntity = translateEntity(entity)
        plugins.forEach {
            $0.onStolenFromOpponent?(player.rawValue, entity: pluginEntity, turn: turn)
        }
    }

}