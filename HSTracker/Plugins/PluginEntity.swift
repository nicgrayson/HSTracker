//
//  PluginEntity.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 11/09/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation

@objc class PluginEntity: NSObject {
    var id: Int?
    var isPlayer: Bool?
    var cardId: String?
    var name: String?
    var tags: [GameTag: Int]?
    var info: EntityInfo?
    var isActiveDeathrattle: Bool?
    var isCurrentPlayer: Bool?
    var isSecret: Bool?
    var isSpell: Bool?
    var isOpponent: Bool?
    var isMinion: Bool?
    var isWeapon: Bool?
    var isHero: Bool?
    var isHeroPower: Bool?
    var isInHand: Bool?
    var isInDeck: Bool?
    var isInPlay: Bool?
    var isInGraveyard: Bool?
    var isInSetAside: Bool?
    var isInSecret: Bool?
    var health: Int?
    var attack: Int?
    var hasCardId: Bool?

    var discarded: Bool?
    var returned: Bool?
    var mulliganed: Bool?
    var stolen: Bool?
    var created: Bool?
    var hasOutstandingTagChanges: Bool?
    var originalController: Int?
    var hidden: Bool?
    var turn: Int?
    var costReduction: Int?
    var originalZone: Zone?
    var createdInDeck: Bool?
    var createdInHand: Bool?
}