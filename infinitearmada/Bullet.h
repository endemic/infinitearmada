//
//  Bullet.h
//  infinitearmada
//
//  Created by Nathan Demick on 9/27/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Entity.h"

@interface Bullet : Entity 
{
    // Stores how far the bullet has moved!
	float distanceMoved;
	
	// Whether or not the bullet has traveled so far that it disappears
	BOOL expired;
}

// Declare properties so setters/getters can be automatically synthesized
@property float distanceMoved;
@property BOOL expired;

+ (Bullet *)create;
- (id)initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;
- (void)update:(ccTime)dt;

@end
