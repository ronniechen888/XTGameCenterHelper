//
//  XTGameCenterHelper.m
//  Pods-XTGameCenterHelper_Example
//
//  Created by Ronnie Chen on 2017/11/30.
//

#import "XTGameCenterHelper.h"

@interface XTGameCenterHelper()

@property (nonatomic,strong) UIViewController *gameCenterLoginViewController;
@property (nonatomic,assign) BOOL isGameCenterLoginViewControllerShowed;
@property (nonatomic,copy) void (^gameCenterViewControllerDidFinishedHandle)(void);

@property (nonatomic,copy) void (^matchMakerViewControllerDidFindMatchHandle)(GKMatch *match);
@property (nonatomic,copy) void (^matchMakerViewControllerWasCancelledHandle)(void);
@property (nonatomic,copy) void (^matchMakerViewControllerDidFailedHandle)(NSError *error);
@property (nonatomic,copy) void (^matchMakerViewControllerDidFindHostedPlayersHandle)(NSArray<GKPlayer *> *players);
@property (nonatomic,copy) void (^matchMakerViewControllerHostedPlayerDidAcceptHandle)(GKPlayer *player);

@property (nonatomic,copy) void (^receiveDataHandle)(NSData *data,GKPlayer *recipient,GKPlayer *remotePlayer);
@end

@implementation XTGameCenterHelper

+(instancetype)sharedGameCenter
{
	static XTGameCenterHelper *gameCenter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gameCenter = [[XTGameCenterHelper alloc] init];
		
	});
	
	return gameCenter;
}

-(instancetype)init
{
	self = [super init];
	if (self) {
		self.isGameCenterLoginViewControllerShowed = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterToBackGround) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	
	return self;
}

-(void)authenticateLocalPlayerWithSuccessHandler:(void (^)(void))successHandler failedHandler:(void (^)(NSError *error))failedHandler{
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
	[localPlayer registerListener:self];
	
	__weak GKLocalPlayer *weakPlayer = localPlayer;
	localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
		_gameCenterLoginViewController = viewController;
		
		if (!_gameCenterLoginViewController) {
			self.isGameCenterLoginViewControllerShowed = NO;
		}
		
		if (weakPlayer.isAuthenticated)
		{
			if (successHandler) {
				successHandler();
			}
		}else
		{
			if (failedHandler) {
				failedHandler(error);
			}
			
			if (error) {
				if (error.code == GKErrorGameUnrecognized) {
					NSLog(@"Please check your itunes connect configuration");
				}else if (error.code == GKErrorNotSupported){
					NSLog(@"Your device does not support Game Center");
				}
			}
		}
		
	};
}

-(void)showGameCenterLoginViewControllerFailedHandler:(void (^)(void))failedHandler
{
	if (_gameCenterLoginViewController && !self.isGameCenterLoginViewControllerShowed) {
		[[UIApplication sharedApplication].keyWindow addSubview:_gameCenterLoginViewController.view];
		self.isGameCenterLoginViewControllerShowed = YES;
	}else if (!_gameCenterLoginViewController && !self.isGameCenterLoginViewControllerShowed){
		if (failedHandler) {
			failedHandler();
		}
	}
}

-(void)hideGameCenterLoginViewController
{
	if (_gameCenterLoginViewController && self.isGameCenterLoginViewControllerShowed) {
		[_gameCenterLoginViewController.view removeFromSuperview];
		self.isGameCenterLoginViewControllerShowed = NO;
	}
}

-(void)didEnterToBackGround{
	[self hideGameCenterLoginViewController];
}

+(GKLocalPlayer *)localPlayer
{
	return [GKLocalPlayer localPlayer];
}

+(NSString *)localPlayerId
{
	return [[GKLocalPlayer localPlayer] playerID];
}

+(NSString *)localDisplayName{
	return [[GKLocalPlayer localPlayer] displayName];
}

+(NSString *)localPlayerAlias
{
	return [XTGameCenterHelper getPlayerAlias:[GKLocalPlayer localPlayer]];
}

+(NSString *)getPlayerId:(GKPlayer *)player{
	return [player playerID];
}

+(NSString *)getDisplayName:(GKPlayer *)player{
	return [player displayName];
}

+(NSString *)getPlayerAlias:(GKPlayer *)player{
	return [player alias];
}

+(void)loadPlayerPhoto:(GKPlayer *)player size:(GKPhotoSize)photoSize withCompletionHandler:(void (^)(UIImage *photo, NSError *error))completionHandle
{
	[player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
		if (completionHandle) {
			completionHandle(photo,error);
		}
	}];
}

+(void)loadPlayersForIdentifiers:(NSArray<NSString *> *)identifiers withCompletionHandler:(void (^)(NSArray<GKPlayer *> *players, NSError *error))completionHandler
{
	[GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:^(NSArray<GKPlayer *> * _Nullable players, NSError * _Nullable error) {
		if (completionHandler) {
			completionHandler(players,error);
		}
	}];
}

-(void)showLeaderboardInCurrentViewController:(UIViewController *)currentController viewStatus:(GKGameCenterViewControllerState)viewState timeScope:(GKLeaderboardTimeScope)timeScope leadboardIdentifier:(NSString *)leaderIdentifier failedHandle:(void (^)(void))failedHandle finishHandle:(void (^)(void))finishHandle
{
	GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
	if (gameCenterController != nil)
	{
		gameCenterController.gameCenterDelegate = self;
		gameCenterController.viewState = viewState;
		gameCenterController.leaderboardIdentifier = leaderIdentifier;
		gameCenterController.leaderboardTimeScope = timeScope;
		[currentController presentViewController: gameCenterController animated: YES completion:nil];
		
		if(finishHandle)
		{
			self.gameCenterViewControllerDidFinishedHandle = finishHandle;
		}
	}else{
		if (failedHandle) {
			failedHandle();
		}
	}
}

-(void)setMatchMakeViewControllerDelegateDidFindMatch:(void (^)(GKMatch *))findMatchHandle wasCancelled:(void (^)(void))cancelledHandle didFailWithError:(void (^)(NSError *))failedHandle didFindHostedPlayers:(void (^)(NSArray<GKPlayer *> *))findHostedPlayersHandle hostedPlayerDidAccept:(void (^)(GKPlayer *))hostedPlayerDidAcceptHandle{
	self.matchMakerViewControllerDidFindMatchHandle = findMatchHandle;
	self.matchMakerViewControllerWasCancelledHandle = cancelledHandle;
	self.matchMakerViewControllerDidFailedHandle = failedHandle;
	self.matchMakerViewControllerDidFindHostedPlayersHandle = findHostedPlayersHandle;
	self.matchMakerViewControllerHostedPlayerDidAcceptHandle = hostedPlayerDidAcceptHandle;
}

-(void)createAndShowMatchMakeViewControllerInCurrentViewController:(UIViewController *)currentController minPlayers:(NSInteger)minNum maxPlayers:(NSInteger)maxNum{
	GKMatchRequest *request = [[GKMatchRequest alloc] init];
	request.minPlayers = minNum;
	request.maxPlayers = maxNum;
	
	GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
	mmvc.matchmakerDelegate = self;
	
	[currentController presentViewController:mmvc animated:YES completion:nil];
}

-(void)setGKMatchDelegateDidReceiveDataHandle:(void (^)(NSData *, GKPlayer *, GKPlayer *))receiveDataHandle
{
	self.receiveDataHandle = receiveDataHandle;
}
#pragma mark - GKGameCenterControllerDelegate
-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
	[gameCenterViewController dismissViewControllerAnimated:YES completion:^{
		if (self.gameCenterViewControllerDidFinishedHandle) {
			self.gameCenterViewControllerDidFinishedHandle();
		}
	}];
}

#pragma mark - GKMatchmakerViewControllerDelegate

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController{
	[viewController dismissViewControllerAnimated:YES completion:nil];
	if (self.matchMakerViewControllerWasCancelledHandle) {
		self.matchMakerViewControllerWasCancelledHandle();
	}
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error{
	
	if (self.matchMakerViewControllerDidFailedHandle) {
		self.matchMakerViewControllerDidFailedHandle(error);
	}
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match{
	[viewController dismissViewControllerAnimated:YES completion:^{
		if (self.matchMakerViewControllerDidFindMatchHandle) {
			match.delegate = self;
			self.matchMakerViewControllerDidFindMatchHandle(match);
		}
	}];
	
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindHostedPlayers:(NSArray<GKPlayer *> *)players{
	if (self.matchMakerViewControllerDidFindHostedPlayersHandle) {
		self.matchMakerViewControllerDidFindHostedPlayersHandle(players);
	}
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController hostedPlayerDidAccept:(GKPlayer *)player{
	if (self.matchMakerViewControllerHostedPlayerDidAcceptHandle) {
		self.matchMakerViewControllerHostedPlayerDidAcceptHandle(player);
	}
}

#pragma mark - GKInviteEventListener
-(void)player:(GKPlayer *)player didAcceptInvite:(GKInvite *)invite{
	GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:invite];
	mmvc.matchmakerDelegate = self;
	
	[[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:mmvc animated:YES completion:nil];
}

-(void)player:(GKPlayer *)player didRequestMatchWithRecipients:(NSArray<GKPlayer *> *)recipientPlayers{
	
}

#pragma mark - GKMatchDelegate

-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromRemotePlayer:(GKPlayer *)player{
	
}

-(void)match:(GKMatch *)match didReceiveData:(NSData *)data forRecipient:(GKPlayer *)recipient fromRemotePlayer:(GKPlayer *)player{
	
	if (self.receiveDataHandle) {
		self.receiveDataHandle(data, recipient, player);
	}
}

-(void)match:(GKMatch *)match player:(GKPlayer *)player didChangeConnectionState:(GKPlayerConnectionState)state{
	
}

-(void)match:(GKMatch *)match didFailWithError:(NSError *)error{
	
}

- (BOOL)match:(GKMatch *)match shouldReinviteDisconnectedPlayer:(GKPlayer *)player{
	
	return YES;
}
@end
