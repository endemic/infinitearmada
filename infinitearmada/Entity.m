//
//  Entity.m
//  infinitearmada
//
//  Created by Nathan Demick on 9/26/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "Entity.h"


@implementation Entity

// Automatically create "setters" and "getters"
@synthesize velocity, speed, isShooting, cooldown, shotDelay;

// The init method we have to override - http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:sprites (bottom of page)
- (id)initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	// Call the init method of the parent class (CCSprite)
	if ((self = [super initWithTexture:texture rect:rect]))
	{
		// The only custom stuff here is scheduling an update method
		[self scheduleUpdate];
		
		isShooting = NO;
		cooldown = shotDelay = kDefaultCooldown;
		
		// Set up speed/velocity
		velocity = ccp(0, 0);
		speed = kDefaultSpeed;
		
		// Default HP
		life = 1;
	}
	return self;
}

// Gets updated every game loop iteration
- (void)update:(ccTime)dt
{
	// Get window size
	CGSize windowSize = [CCDirector sharedDirector].winSize;
	
	// Move the ship based on the "velocity" variable
	float x = self.position.x + velocity.x * speed * dt;
	float y = self.position.y + velocity.y * speed * dt;
	
	// Enforce movement within the bounds of the screen
	if (x > 0 && x < windowSize.width)
	{
		self.position = ccp(x, self.position.y);
	}
	else if (x > windowSize.width - self.contentSize.width / 2)
	{
		self.position = ccp(windowSize.width - self.contentSize.width / 2, self.position.y);
	}
	else if (x < self.contentSize.width / 2)
	{
		self.position = ccp(self.contentSize.width / 2, self.position.y);
	}
	
	if (y > 0 && y < windowSize.height)
	{
		self.position = ccp(self.position.x, y);
	}
	else if (y > windowSize.height - windowSize.height - self.contentSize.height / 2)
	{
		self.position = ccp(self.position.x, windowSize.height - self.contentSize.height / 2);
	}
	else if (y < self.contentSize.height / 2)
	{
		self.position = ccp(self.position.x, self.contentSize.height / 2);
	}
	
}

// Super-basic AABB collision detection
- (BOOL)collidesWith:(CCSprite *)obj
{
	// Create two rectangles with CGRectMake, using each sprite's x/y position and width/height
	CGRect ownRect = CGRectMake(self.position.x - (self.contentSize.width / 2), self.position.y - (self.contentSize.height / 2), self.contentSize.width, self.contentSize.height);
	CGRect otherRect = CGRectMake(obj.position.x - (obj.contentSize.width / 2), obj.position.y - (obj.contentSize.height / 2), obj.contentSize.width, obj.contentSize.height);
	
	// Feed the results into CGRectIntersectsRect() which tells if the rectangles intersect (obviously)
	return CGRectIntersectsRect(ownRect, otherRect);
}

@end
