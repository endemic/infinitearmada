//
//  AppDelegate.h
//  infinitearmada
//
//  Created by Nathan Demick on 9/26/11.
//  Copyright Ganbaru Games 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
