//
//  GameLayer.m
//  infinitearmada
//
//  Created by Nathan Demick on 9/26/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "GameLayer.h"

@implementation GameLayer
+ (id)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

- (id)init
{
	if ((self = [super init])) 
	{
		// Register touches on the layer
		[self setIsTouchEnabled:YES];
        [self setIsAccelerometerEnabled:YES];
		
		// Set this layer property so I don't have to query the director in every method
		windowSize = [CCDirector sharedDirector].winSize;
		
		// This string gets appended onto all image filenames based on whether the game is on iPad or not
		if ([GameSingleton sharedGameSingleton].isPad)
		{
			hdSuffix = @"-hd";
			fontMultiplier = 2;
		}
		else
		{
			hdSuffix = @"";
			fontMultiplier = 1;
		}
		
		// score = 0
		score = 0;
		scoreLabel = [CCLabelTTF labelWithString:@"0" dimensions:CGSizeMake(100, 20) alignment:CCTextAlignmentRight fontName:@"Helvetica" fontSize:15.0];
		scoreLabel.position = ccp(windowSize.width - scoreLabel.contentSize.width / 2, windowSize.height - scoreLabel.contentSize.height / 2);
		[self addChild:scoreLabel z:2];
		
		// Create/add control overlay
		moveController = [CCSprite spriteWithFile:@"control-circle.png"];
		shootController = [CCSprite spriteWithFile:@"control-circle.png"];
		
		// Hide the controllers until the player touches the screen
		moveController.opacity = 0;
		shootController.opacity = 0;
		
		// Add controllers to layer
		[self addChild:moveController z:1];
		[self addChild:shootController z:1];
		
		// Create ship object and add it to layer
		ship = [Entity spriteWithFile:@"ship.png"];
		[ship setPosition:ccp(windowSize.width / 2, windowSize.height / 2)];
		[self addChild:ship z:1];
		
		// Set the default interval between shots
		ship.cooldown = ship.shotDelay = kShipCooldown;
		ship.speed = kShipSpeed;
		
		// Instantiate the arrays that store enemies/bullets
		playerBullets = [[NSMutableArray alloc] init];
		enemyBullets = [[NSMutableArray alloc] init];
		enemies = [[NSMutableArray alloc] init];
		
		// Schedule an update method that spawns enemies
//		[self schedule:@selector(spawnDrone) interval:1.0];
        
        level = 1;
        
        for (int i = 0; i < level + 5; i++)
        {
            [self spawnDrone];
        }
		
		// Schedule the regular update method
		[self scheduleUpdate];
		
		// Preload some SFX
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"enemy-die.caf"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"enemy-shoot.caf"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"player-shoot.caf"];
	}
	return self;
}

/**
 * Debug method which creates drone enemies every second
 */
- (void)spawnDrone
{
//	if ([enemies count] < 5)
	{
		// Create drone obj
		Drone *d = [Drone create];
		
		// Randomly position it at the edges of the screen
		int x = arc4random() % 2 == 1 ? 0 + d.contentSize.width : windowSize.width - d.contentSize.width;
		int y = arc4random() % 2 == 1 ? 0 + d.contentSize.height : windowSize.height - d.contentSize.height;
		
		d.position = ccp(x, y);
		
		// Add to organizational array
		[enemies addObject:d];
		
		// Display on layer
		[self addChild:d z:1];
	}
}

/**
 * Main game loop method which moves the player/enemies, bullets, and checks for collisions
 */
- (void)update:(ccTime)dt
{
	// Stores objects that need to be removed from other arrays
	NSMutableArray *removedBullets = [NSMutableArray array];	// Autoreleased
	NSMutableArray *removedEnemies = [NSMutableArray array];	// Autoreleased
	BOOL willReset = NO;
	
	// Iterate over list of enemies to do various checks
	for (Entity *e in enemies) 
	{
		// Check whether enemy is touching the player
		if ([e collidesWith:ship])
		{
			CCLOG(@"Game over!");
			
			willReset = YES;
		}
		
		// If enemy is a drone class, just set its' velocity towards the player
		if ([e isKindOfClass:[Drone class]])
		{
			// Angle towards the player
			float angle = CC_RADIANS_TO_DEGREES(atan2(e.position.x - ship.position.x, e.position.y - ship.position.y)) + 90;
			
			// Set the enemy's velocity
			e.velocity = ccp(cos(CC_DEGREES_TO_RADIANS(angle)), -sin(CC_DEGREES_TO_RADIANS(angle)));
			
			// Also tell it to rotate towards the player
			e.rotation = angle;
		}
		else if ([e isKindOfClass:[Shooter class]])
		{
			// Find angle between enemy and player
			float angle = CC_RADIANS_TO_DEGREES(atan2(e.position.x - ship.position.x, e.position.y - ship.position.y)) + 90;
			
			// Set the enemy's velocity - away from player
			e.velocity = ccp(cos(CC_DEGREES_TO_RADIANS(-angle)), -sin(CC_DEGREES_TO_RADIANS(-angle)));
			
			// Tell enemy to rotate towards the player
			e.rotation = angle;
			
			// Determine whether or not the Shooter can shoot
			e.cooldown -= dt;
			
			if (e.cooldown <= 0)
			{
				// Reset the cooldown value
				e.cooldown = e.shotDelay;
				
				// Shoot!
				Bullet *b = [Bullet create];
				
				// Set the bullet's position by starting w/ the ship's position, then adding the rotation vector, so the bullet appears to come from the ship's nose
				b.position = ccp(e.position.x + cos(CC_DEGREES_TO_RADIANS(e.rotation)) * e.contentSize.width, e.position.y - sin(CC_DEGREES_TO_RADIANS(e.rotation)) * e.contentSize.height);
				
				// Set the bullet's velocity to be in the same direction as the ship is pointing, plus whatever the ship's velocity is
				b.velocity = ccp(cos(CC_DEGREES_TO_RADIANS(e.rotation)), -sin(CC_DEGREES_TO_RADIANS(e.rotation)));
				
				// Try to change color?
				b.color = ccc3(255, 0, 255);
				
				// Add bullet to organizational array
				[enemyBullets addObject:b];
				
				// Add bullet to layer
				[self addChild:b];
				
				// Play SFX
				[[SimpleAudioEngine sharedEngine] playEffect:@"enemy-shoot.caf"];
			}
		}
		else if ([e isKindOfClass:[Factory class]])
		{
			// Find angle between enemy and player
			float angle = CC_RADIANS_TO_DEGREES(atan2(e.position.x - ship.position.x, e.position.y - ship.position.y)) + 90;
			
			// Set the enemy's velocity - away from player
			e.velocity = ccp(cos(CC_DEGREES_TO_RADIANS(-angle)), -sin(CC_DEGREES_TO_RADIANS(-angle)));
			
			// Tell enemy to rotate towards the player
			//e.rotation = angle;
			
			// Determine whether or not the Factory can spawn a new enemy
			e.cooldown -= dt;
			
			if (e.cooldown <= 0)
			{
				// Reset the cooldown value
				e.cooldown = e.shotDelay;
				
				// Spawn a new shooter
				Shooter *s = [Shooter create];
				
				s.position = e.position;
				
				// Add bullet to organizational array
				[enemies addObject:s];
				
				// Add bullet to layer
				[self addChild:s];
				
				// Play SFX
				[[SimpleAudioEngine sharedEngine] playEffect:@"enemy-shoot.caf"];
			}
		}
		
		
		// Check collision of enemies vs. player shots
		for (Bullet *b in playerBullets)
		{
			// If player bullet has travelled far enough, delete it
			if (b.expired)
			{
				[removedBullets addObject:b];
			}
			// Otherwise, check if it hits an enemy
			else if ([e collidesWith:b])
			{
				[removedBullets addObject:b];
				[removedEnemies addObject:e];
				
				// Particle effect here
				[self createExplosionAt:e.position];
				
				// Update score
				[self updateScore:kDronePoints];
				
				// Play SFX
				[[SimpleAudioEngine sharedEngine] playEffect:@"enemy-die.caf"];
			}
		}
	}
	
	// Check collision of player vs. enemy shots
	for (Bullet *b in enemyBullets)
	{
		// If bullet has travelled far enough, delete it
		if (b.expired)
		{
			[removedBullets addObject:b];
		}
		// Otherwise, check if it hits the player
		else if ([ship collidesWith:b])
		{
			// Particle effect here
			[self createExplosionAt:ship.position];
			
			willReset = YES;
		}
	}
	
	// Remove any objects that were added to the "removal" arrays
	for (Bullet *b in removedBullets)
	{
		[self removeChild:b cleanup:YES];
	}
	[playerBullets removeObjectsInArray:removedBullets];
	
	for (Entity *e in removedEnemies)
	{
		[self removeChild:e cleanup:YES];
	}
	[enemies removeObjectsInArray:removedEnemies];
	
	// Create player bullets here if the "isShooting" flag is set
	if (ship.isShooting)
	{
		ship.cooldown -= dt;
		
		// If the "cooldown" value is zero, it means you can shoot again
		if (ship.cooldown <= 0)
		{
			// Reset the cooldown value
			ship.cooldown = ship.shotDelay;
			
			// Shoot!
			Bullet *b = [Bullet create];
			
			// Set the bullet's position by starting w/ the ship's position, then adding the rotation vector, so the bullet appears to come from the ship's nose
			b.position = ccp(ship.position.x + cos(CC_DEGREES_TO_RADIANS(ship.rotation)) * ship.contentSize.width, ship.position.y - sin(CC_DEGREES_TO_RADIANS(ship.rotation)) * ship.contentSize.height);
			
			// Set the bullet's velocity to be in the same direction as the ship is pointing, plus whatever the ship's velocity is
			b.velocity = ccp(cos(CC_DEGREES_TO_RADIANS(ship.rotation)), -sin(CC_DEGREES_TO_RADIANS(ship.rotation)));
			
			// Add bullet to organizational array
			[playerBullets addObject:b];
			
			// Add bullet to layer
			[self addChild:b];
			
			// Play SFX
			[[SimpleAudioEngine sharedEngine] playEffect:@"player-shoot.caf"];
		}
	}
	
	// Reset the game if this boolean flag is set
	if (willReset)
	{
		[self reset];
	}
    
    if ([enemies count] == 0)
    {
        [self nextLevel];
    }
}

/**
 * Resets the player location & removes all enemies/bullets
 */
- (void)reset
{
	// Reset the ship's position
	ship.position = ccp(windowSize.width / 2, windowSize.height / 2);
	
	// Remove player bullets
	for (Bullet *b in playerBullets)
	{
		[self removeChild:b cleanup:YES];
	}
	[playerBullets removeAllObjects];
	
	// Remove enemy bullets
	for (Bullet *b in enemyBullets)
	{
		[self removeChild:b cleanup:YES];
	}
	[enemyBullets removeAllObjects];
	
	// Remove enemies
	for (Entity *e in enemies)
	{
		[self removeChild:e cleanup:YES];
	}
	[enemies removeAllObjects];
}

- (void)nextLevel
{
    // Remove enemy/player bullets and move ship back to center
    [self reset];
    
    // Increment level counter
    level++;
    
    // Spawn some more enemies at random locations
    for (int i = 0; i < level + 5; i++)
    {
        [self spawnDrone];
    }
}

/**
 * Convenience method used to update the in-game score label
 */
- (void)updateScore:(int)points
{
	score += points;
	[scoreLabel setString:[NSString stringWithFormat:@"%i", score]];
}

/**
 * Reverse the shooting direction
 */
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

/**
 * Reset the shooting direction back forwards
 */
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    // Accelerometer values are given from "portrait" orientation, so manually convert them to landscape

    // X accel is negative when rotated left
    float x = -acceleration.y;// - damping < 0 ? 0 : acceleration.y - damping;
    float y = acceleration.x;// - damping < 0 ? 0 : acceleration.x - damping;
    
    // acceleration has .x and .y properties that range from (0,0) (neutral) to (1, 1) tilted upper left
    ship.rotation = CC_RADIANS_TO_DEGREES(atan2(x, y)) - 90;
    ship.velocity = ccp(x, y);
    
    ship.isShooting = YES;
	NSLog(@"Accelerometer values: %f, %f, %f", acceleration.x, acceleration.y, acceleration.z);
}

/*
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// This method is passed an NSSet of touches called (of course) "touches"
	// "allObjects" returns an NSArray of all the objects in the set
	NSArray *touchArray = [touches allObjects];
	
	// Loop through each touch and react accordingly
	for (int i = 0; i < [touchArray count]; i++)
	{
		UITouch *touch = [touchArray objectAtIndex:i];
		
		// Convert touch to OpenGL coords
		CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
		
		// If the touch is on the left side of the screen, and the moveController is hidden, show it
		if (moveController.opacity == 0 && touchPoint.x < windowSize.width / 2)
		{
			moveController.opacity = 255;
			moveController.position = touchPoint;
		}
		
		// If the touch is on the right side of the screen, and the shootController is hidden, show it
		if (shootController.opacity == 0 && touchPoint.x > windowSize.width / 2)
		{
			shootController.opacity = 255;
			shootController.position = touchPoint;
		}
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// This method is passed an NSSet of touches called (of course) "touches"
	// "allObjects" returns an NSArray of all the objects in the set
	NSArray *touchArray = [touches allObjects];
	
	// Add a bit of padding around the controller to allow for some slop
	int padding = 20;
	
	// Loop through each touch and react accordingly
	for (int i = 0; i < [touchArray count]; i++)
	{
		UITouch *touch = [touchArray objectAtIndex:i];
		
		// Convert location
		CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
		
		// Create a CGRect that represents the "move" circle - CGRect origin is upper left, so offset the center
		CGRect moveRect = CGRectMake(moveController.position.x - (moveController.contentSize.width / 2) - (padding / 2), moveController.position.y - (moveController.contentSize.height / 2) - (padding / 2), moveController.contentSize.width + padding, moveController.contentSize.height + padding);
		
		// The user's finger is in the "move" circle
		if (CGRectContainsPoint(moveRect, touchPoint))
		{
			// Determine the angle between the touch and the center of the "move" circle
			float moveAngle = CC_RADIANS_TO_DEGREES(atan2(moveController.position.x - touchPoint.x, moveController.position.y - touchPoint.y)) + 90;
			
			// Set the ship's velocity
			ship.velocity = ccp(cos(CC_DEGREES_TO_RADIANS(moveAngle)), -sin(CC_DEGREES_TO_RADIANS(moveAngle)));
			
			// If player is shooting, ship faces in direction of right stick. Otherwise, face in direction of left stick
			if (!ship.isShooting)
			{
				ship.rotation = moveAngle;
			}
		}
		
		// Create a CGRect that represents the "shoot" circle - CGRect origin is upper left, so offset the center
		CGRect shootRect = CGRectMake(shootController.position.x - (shootController.contentSize.width / 2) - (padding / 2), shootController.position.y - (shootController.contentSize.height / 2) - (padding / 2), shootController.contentSize.width + padding, shootController.contentSize.height + padding);
		
		// The user's finger is in the "shoot" circle
		if (CGRectContainsPoint(shootRect, touchPoint))
		{
			// Determine the angle between the touch and the center of the "shoot" circle
			int angle = CC_RADIANS_TO_DEGREES(atan2(shootController.position.x - touchPoint.x, shootController.position.y - touchPoint.y)) + 90;
			
			// Lock shooting angle in 45 degree increments
			int shootAngle = (angle / 45) * 45;
			CCLOG(@"Shooting angle: %i", shootAngle);
			
			ship.rotation = shootAngle;
			
			ship.isShooting = YES;
		}
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Determine if a control area has been abandoned
	
	// This method is passed an NSSet of touches called (of course) "touches"
	// "allObjects" returns an NSArray of all the objects in the set
	NSArray *touchArray = [touches allObjects];
	
	// If no touches, hide controllers and stop ship
	if ([touchArray count] < 1)
	{
		ship.velocity = ccp(0, 0);
		moveController.opacity = 0;
		shootController.opacity = 0;
	}
	else
	{
		// Loop through each touch and react accordingly
		for (int i = 0; i < [touchArray count]; i++)
		{
			UITouch *touch = [touchArray objectAtIndex:i];
			
			// Convert location
			CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
			
			// The user's finger has left the left side of the screen...
			if (touchPoint.x < windowSize.width / 2)
			{
				ship.velocity = ccp(0, 0);
				moveController.opacity = 0;
			}

			// The user's finger has left right side of the screen...
			if (touchPoint.x > windowSize.width / 2)
			{
				shootController.opacity = 0;
				ship.isShooting = NO;
			}
		}
	}
}
*/

/**
 * Creates simple particle effect
 */
- (void)createExplosionAt:(CGPoint)position
{
	// Create quad particle system (faster on 3rd gen & higher devices, only slightly slower on 1st/2nd gen)
	CCParticleSystemQuad *particleSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:50];
	
	// duration is for the emitter
	[particleSystem setDuration:0.1f];
	
	[particleSystem setEmitterMode:kCCParticleModeGravity];
	
	// Gravity Mode: gravity
	[particleSystem setGravity:ccp(0, 0)];
	
	// Gravity Mode: speed of particles
	[particleSystem setSpeed:70];
	[particleSystem setSpeedVar:40];
	
	// Gravity Mode: radial
	[particleSystem setRadialAccel:0];
	[particleSystem setRadialAccelVar:0];
	
	// Gravity Mode: tagential
	[particleSystem setTangentialAccel:0];
	[particleSystem setTangentialAccelVar:0];
	
	// angle
	[particleSystem setAngle:90];
	[particleSystem setAngleVar:360];
	
	// emitter position
	[particleSystem setPosition:position];
	[particleSystem setPosVar:CGPointZero];
	
	// life is for particles particles - in seconds
	[particleSystem setLife:1.0f];
	[particleSystem setLifeVar:1.0f];
	
	// size, in pixels
	[particleSystem setStartSize:1.0f];
	[particleSystem setStartSizeVar:1.0f];
	[particleSystem setEndSize:kCCParticleStartSizeEqualToEndSize];
	
	// emits per second
	[particleSystem setEmissionRate:[particleSystem totalParticles] / [particleSystem duration]];
	
	// color of particles
	ccColor4F startColor = {1.0f, 1.0f, 1.0f, 1.0f};
	ccColor4F endColor = {1.0f, 1.0f, 1.0f, 1.0f};
	[particleSystem setStartColor:startColor];
	[particleSystem setEndColor:endColor];
	
	[particleSystem setTexture:[[CCTextureCache sharedTextureCache] addImage:@"bullet.png"]];
	
	// additive
	[particleSystem setBlendAdditive:NO];
	
	// Auto-remove the emitter when it is done!
	[particleSystem setAutoRemoveOnFinish:YES];
	
	// Add to layer
	[self addChild:particleSystem z:10];
	
//	NSLog(@"Tryin' to make a particle emitter at %f, %f", position.x, position.y);
}

/**
 * Convenience method to remove a cocos2d obj from the layer
 */
- (void)removeNodeFromParent:(CCNode *)node
{
	[node.parent removeChild:node cleanup:YES];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[playerBullets release];
	[enemyBullets release];
	[enemies release];
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
