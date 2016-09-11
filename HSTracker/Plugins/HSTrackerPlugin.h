//
//  HSTrackerPlugin.h
//  HSTracker
//
//  Created by Benjamin Michotte on 7/09/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

#ifndef HSTrackerPlugin_h
#define HSTrackerPlugin_h

@import Foundation;
@class GameStats;
@class PluginEntity;

/// HSTracker plugins have to conform to this protocol
@protocol HSTrackerPlugin <NSObject>

/// The name of the plugin. **required**
@property (nonatomic, copy, readonly) NSString *_Nonnull name;

@optional
/// This event is called as soon as the plugin has been loaded
-(void) onLoad;

-(void) onGameReset;

-(void) onGameStart:(NSNumber *_Nonnull)time;

-(void) onGameEnd;

-(void) onSaveMatch;

-(void) turnStart:(NSString *_Nonnull)player turn:(NSNumber *_Nonnull)turn;

//
-(void) onPlayerHero:(NSString *_Nonnull)cardId;
-(void) onPlayerName:(NSString *_Nonnull)name;
-(void) onPlayerGet:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerBackToHand:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerPlayToDeck:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerPlay:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerHandDiscard:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerSecretPlayed:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn fromZone: (NSNumber *_Nonnull)zone;
-(void) onPlayerMulligan:(PluginEntity *_Nonnull)entity;
-(void) onPlayerDraw:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerRemoveFromDeck:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerDeckDiscard:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerDeckToPlay:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerPlayToGraveyard:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerJoust:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerGetToDeck:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerFatigue:(NSNumber *_Nonnull)value;
-(void) onPlayerCreateInPlay:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerRemoveFromPlay:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onPlayerHeroPower:(NSString *_Nonnull)cardId turn:(NSNumber *_Nonnull)turn;

//
-(void) onOpponentHero:(NSString *_Nonnull)cardId;
-(void) onOpponentName:(NSString *_Nonnull)name;
-(void) onOpponentGet:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentBackToHand:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentPlayToDeck:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentPlayToHand:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentPlay:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentHandDiscard:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentSecretTrigger:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentSecretPlayed:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn fromZone: (NSNumber *_Nonnull)zone;
-(void) onOpponentMulligan:(PluginEntity *_Nonnull)entity;
-(void) onOpponentDraw:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentRemoveFromDeck:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentDeckDiscard:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentDeckToPlay:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentPlayToGraveyard:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentJoust:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentGetToDeck:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentFatigue:(NSNumber *_Nonnull)value;
-(void) onOpponentCreateInPlay:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentRemoveFromPlay:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onOpponentHeroPower:(NSString *_Nonnull)cardId turn:(NSNumber *_Nonnull)turn;

//
-(void) onStolenByOpponent:(NSNumber *_Nonnull)player entity:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;
-(void) onStolenFromOpponent:(NSNumber *_Nonnull)player entity:(PluginEntity *_Nonnull)entity turn:(NSNumber *_Nonnull)turn;

@end

#endif /* HSTrackerPlugin_h */
