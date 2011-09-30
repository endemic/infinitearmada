//
//  GameLayer.h
//  infinitearmada
//
//  Created by Nathan Demick on 9/26/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "GameSingleton.h"
#import "GameConfig.h"

#import "Entity.h"
#import "Drone.h"
#import "Shooter.h"
#import "Factory.h"
#import "Bullet.h"

@interface GameLayer : CCLayer 
{
	// Organizational data structures to store lists of bullets, enemies, etc.
	NSMutableArray *playerBullets, *enemyBullets, *enemies;
	
	// The player
	Entity *ship;
	
	// Sprites that control the movement/shooting of player
	CCSprite *moveController, *shootController;
	
	// Oh score, how worthless you are!
	int score;
	CCLabelTTF *scoreLabel;

	// Store the size of the viewport so we don't have to ask the director in each method
	CGSize windowSize;
	
	// String to be appended to sprite filenames if required to use a high-rez file (e.g. iPhone 4 assets on iPad)
	NSString *hdSuffix;
	int fontMultiplier; 
}

+ (id)scene;									// returns a Scene that contains a GameLayer as the only child
- (void)spawnDrone;								// Creates an enemy at a random location
- (void)createExplosionAt:(CGPoint)position;	// Creates an "explosion" particle effect
- (void)updateScore:(int)points;				// Updates the player's score and the score display
- (void)removeNodeFromParent:(CCNode *)node;	// Removes a CCNode from the layer
- (void)reset;									// Resets the player & enemies

@end
