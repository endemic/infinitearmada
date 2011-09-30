//
//  Entity.h
//  infinitearmada
//
//  Created by Nathan Demick on 9/26/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameConfig.h"

@interface Entity : CCSprite 
{
	// Store how fast the entity is moving
	CGPoint velocity;
	
	// The base multiplier for how fast the entity can move
	float speed;
	
	// How many HP the obj has. 1 HP = 1 shot
	int life;
	
	// Whether the entity is shooting or not (really for ship only)
	BOOL isShooting;
	
	// These vars control rate of fire & ability to fire
	float cooldown;
	float shotDelay;
}

@property CGPoint velocity;
@property float speed;
@property BOOL isShooting;
@property float cooldown;
@property float shotDelay;

// Have to override this method in order to subclass CCSprite
- (id)initWithTexture:(CCTexture2D *)texture rect:(CGRect)rect;

// This method gets called each time the object is updated in the game loop
- (void)update:(ccTime)dt;

// Basic AABB collision detection
- (BOOL)collidesWith:(CCSprite *)obj;
@end
