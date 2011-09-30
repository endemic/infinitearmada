//
//  Shooter.h
//  infinitearmada
//
//  Created by Nathan Demick on 9/29/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Entity.h"
#import "GameConfig.h"

@interface Shooter : Entity 
{
    
}

+ (Shooter *)create;

// Have to override this method in order to subclass CCSprite
- (id)initWithTexture:(CCTexture2D *)texture rect:(CGRect)rect;

- (void)update:(ccTime)dt;

@end
