//
//  Bullet.m
//  infinitearmada
//
//  Created by Nathan Demick on 9/27/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "Bullet.h"
#import "GameConfig.h"

@implementation Bullet

@synthesize distanceMoved, expired;

+ (Bullet *)create
{
	Bullet *b = [Bullet spriteWithFile:@"bullet.png"];
	b.distanceMoved = 0;
	
	return b;
}

- (id)initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	// Call the init method of the parent class (CCSprite)
	if ((self = [super initWithTexture:texture rect:rect]))
	{
		// Add any additional code here
		self.distanceMoved = 0;
		self.speed = kBulletSpeed;
	}
	return self;
}

- (void)update:(ccTime)dt
{
	// Get window size
	CGSize windowSize = [CCDirector sharedDirector].winSize;
	
	// Increment the distance moved by the velocity vector
	distanceMoved += sqrt(pow(velocity.x, 2) + pow(velocity.y, 2));
	
	// Determine if bullet is expired -- check to see if its gone at least half the width of the screen
	if (distanceMoved > windowSize.width / 2)
	{
		expired = YES;
	}
	
	// Call parent update method
	[super update:dt];
}

@end
