//
//  XTViewController.m
//  XTGameCenterHelper
//
//  Created by ronniechen888 on 11/30/2017.
//  Copyright (c) 2017 ronniechen888. All rights reserved.
//

#import "XTViewController.h"
#import "XTRealTimeGameViewController.h"

@interface XTViewController ()

@end

@implementation XTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	

	[[XTGameCenterHelper sharedGameCenter] authenticateLocalPlayerWithSuccessHandler:^{
		NSLog(@"Login Succeed!");
		
		_aliasLabel.text = [XTGameCenterHelper localPlayerAlias];
		_displayLabel.text = [XTGameCenterHelper localDisplayName];
		_playIdLabel.text = [XTGameCenterHelper localPlayerId];
		
		[XTGameCenterHelper loadPlayerPhoto:[GKLocalPlayer localPlayer] size:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
			if (photo) {
				_headView.image = photo;
			}
			
		}];
	} failedHandler:^(NSError *error){
		NSLog(@"Login Failed!");
		[[XTGameCenterHelper sharedGameCenter] showGameCenterLoginViewControllerFailedHandler:^{
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请前往设置的Game Center中心进行登录" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//			[alertView show];
		}];
	}];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showLeaderBoard:(id)sender
{
	[[XTGameCenterHelper sharedGameCenter] showLeaderboardInCurrentViewController:self viewStatus:GKGameCenterViewControllerStateLeaderboards timeScope:GKLeaderboardTimeScopeToday leadboardIdentifier:nil failedHandle:nil finishHandle:nil];
	
}

-(void)invite:(id)sender
{
	[[XTGameCenterHelper sharedGameCenter] setMatchMakeViewControllerDelegateDidFindMatch:^(GKMatch *match) {
		XTRealTimeGameViewController *realTimeViewController = [[XTRealTimeGameViewController alloc] init];
		realTimeViewController.match = match;
		[self presentViewController:realTimeViewController animated:YES completion:nil];
	} 
																			 wasCancelled:nil 
																		 didFailWithError:nil 
																	 didFindHostedPlayers:nil 
																	hostedPlayerDidAccept:nil];
	
	[[XTGameCenterHelper sharedGameCenter] createAndShowMatchMakeViewControllerInCurrentViewController:self minPlayers:2 maxPlayers:2];
}

-(void)anoymousLogin:(id)sender{
	[[XTGameCenterHelper sharedGameCenter] anonymousGuestPlayerWithIdentifier:@"asdsadfsf"];
}

@end
