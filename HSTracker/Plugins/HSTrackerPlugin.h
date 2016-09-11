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
@end

#endif /* HSTrackerPlugin_h */
