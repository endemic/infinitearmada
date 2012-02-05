//
//  Ship.m
//  infinitearmada
//
//  Created by Nathan Demick on 11/22/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "Ship.h"

@implementation Ship

+ (Ship *)create
{
	Ship *s = [Ship spriteWithFile:@"ship.png"];
	
	return s;
}

- (id)initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	// Call the init method of the parent class (CCSprite)
	if ((self = [super initWithTexture:texture rect:rect]))
	{
		// Add any additional code here
        reverseShoot = NO;
	}
	return self;
}

- (void)update:(ccTime)dt
{
	// Get window size
//	CGSize windowSize = [CCDirector sharedDirector].winSize;
	
	
	// Call parent update method
	[super update:dt];
}

@end
