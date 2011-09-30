//
//  Shooter.m
//  infinitearmada
//
//  Created by Nathan Demick on 9/29/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "Shooter.h"


@implementation Shooter

+ (Shooter *)create
{
	return [Shooter spriteWithFile:@"shooter.png"];
}

- (id)initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	// Call the init method of the parent class (CCSprite)
	if ((self = [super initWithTexture:texture rect:rect]))
	{
		// Add any additional code here
		speed = kShooterSpeed;
		cooldown = shotDelay = kShooterCooldown;
	}
	return self;
}

// Gets updated every game loop iteration
- (void)update:(ccTime)dt
{
	// call the parent update method
	[super update:dt];
}

@end
