//
//  Drone.h
//  infinitearmada
//
//  Created by Nathan Demick on 9/26/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameConfig.h"
#import "Entity.h"

@interface Drone : Entity 
{
    
}

+ (Drone *)create;

// Have to override this method in order to subclass CCSprite
- (id)initWithTexture:(CCTexture2D *)texture rect:(CGRect)rect;

- (void)update:(ccTime)dt;

@end
