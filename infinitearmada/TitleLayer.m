//
//  TitleLayer.m
//  nonogrammadness
//
//  Created by Nathan Demick on 8/31/11.
//  Copyright 2011 Ganbaru Games. All rights reserved.
//

#import "TitleLayer.h"
#import "GameLayer.h"
#import "InfoLayer.h"

#import "GameSingleton.h"
#import "SimpleAudioEngine.h"
#import "GameConfig.h"

@implementation TitleLayer
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TitleLayer *layer = [TitleLayer node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
- (id)init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init]))
	{
		// ask director the the window size
		CGSize windowSize = [CCDirector sharedDirector].winSize;
		
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

		// Authenticate with Game Center
		[[GameSingleton sharedGameSingleton] authenticateLocalPlayer];

		// Create/add background
		CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background%@.png", hdSuffix]];
		bg.position = ccp(windowSize.width / 2, windowSize.height / 2);
		[self addChild:bg z:0];
		
		// Create/add title
		CCSprite *title = [CCSprite spriteWithFile:[NSString stringWithFormat:@"title%@.png", hdSuffix]];
		title.position = ccp(windowSize.width / 2, windowSize.height - title.contentSize.height);
		[self addChild:title z:1];
		
		// Add some buttons
		CCMenuItemImage *startButton = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"start-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"start-button-selected%@.png", hdSuffix] block:^(id sender){
			// Play sound effect
			[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
			
			// Transition to level select
			CCTransitionTurnOffTiles *transition = [CCTransitionTurnOffTiles transitionWithDuration:0.5 scene:[GameLayer node]];
			[[CCDirector sharedDirector] replaceScene:transition];
		}];
		
		CCMenuItemImage *tutorialButton = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"tutorial-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"tutorial-button-selected%@.png", hdSuffix] block:^(id sender){
			// Play sound effect
			[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
			
			// This signifies the tutorial level
			[GameSingleton sharedGameSingleton].level = -1;
			
			// Transition to game scene select
			CCTransitionTurnOffTiles *transition = [CCTransitionTurnOffTiles transitionWithDuration:0.5 scene:[GameLayer node]];
			[[CCDirector sharedDirector] replaceScene:transition];
		}];
		

		CCMenu *titleMenu = [CCMenu menuWithItems:startButton, tutorialButton, nil];
		titleMenu.position = ccp(windowSize.width / 2, startButton.contentSize.height * 2);
		[titleMenu alignItemsVerticallyWithPadding:11];
		[self addChild:titleMenu z:1];	

		// Add "info" button
		CCMenuItemImage *infoButton = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"info-button%@.png", hdSuffix] selectedImage:[NSString stringWithFormat:@"info-button-selected%@.png", hdSuffix] block:^(id sender) {
			// Play sound effect
			[[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
			
			// Transition to info scene
			CCTransitionTurnOffTiles *transition = [CCTransitionTurnOffTiles transitionWithDuration:0.5 scene:[InfoLayer node]];
			[[CCDirector sharedDirector] replaceScene:transition];
		}];
		
		CCMenu *infoMenu = [CCMenu menuWithItems:infoButton, nil];
		infoMenu.position = ccp(windowSize.width - infoButton.contentSize.width / 2, infoButton.contentSize.height / 2);
		[self addChild:infoMenu z:1];
		
		// Add copyright text
		NSString *copyrightString = @"© 2011 Ganbaru Games";

		CCLabelTTF *copyrightLabel = [CCLabelTTF labelWithString:copyrightString fontName:@"pf_westa_seven.ttf" fontSize:10];
		copyrightLabel.position = ccp(windowSize.width / 2, copyrightLabel.contentSize.height);
		[self addChild:copyrightLabel z:1];
		
		// Play random music track
		if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
		{
			int trackNumber = (float)(arc4random() % 100) / 100 * 2 + 1;	// 1 - 3
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic:[NSString stringWithFormat:@"%i.mp3", trackNumber]];
		}
	}
	return self;
}

/**
 * Handle clicking of the alert view
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) 
	{
		case 0:
			// Do nothing - dismiss
			break;
		case 1:
#if TARGET_IPHONE_SIMULATOR
			CCLOG(@"App Store is not supported on the iOS simulator. Unable to open App Store page.");
#else
			// they want to buy it
			//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=386461624"]];
			[self openReferralURL:[NSURL URLWithString:@"http://click.linksynergy.com/fs-bin/stat?id=0VdnAOV054A&offerid=146261&type=3&subid=0&tmpid=1826&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fus%252Fapp%252Fnonogram-madness%252Fid386461624%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30"]];
#endif
			break;
		default:
			break;
		}
}

// Process a LinkShare/TradeDoubler/DGM URL to something iPhone can handle
- (void)openReferralURL:(NSURL *)referralURL 
{
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:referralURL] delegate:self startImmediately:YES];
    [conn release];
}

// Save the most recent URL in case multiple redirects occur
// "iTunesURL" is an NSURL property in your class declaration
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response 
{
    iTunesURL = [response URL];
    return request;
}

// No more redirects; use the last URL saved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    [[UIApplication sharedApplication] openURL:iTunesURL];
}


// on "dealloc" you need to release all your retained objects
- (void)dealloc
{
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
