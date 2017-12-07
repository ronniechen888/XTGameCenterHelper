//
//  XTGameCenterHelper.h
//  Pods-XTGameCenterHelper_Example
//
//  Created by Ronnie Chen on 2017/11/30.
//

#import <Foundation/Foundation.h>
#import <GameKit/Gamekit.h>

@interface XTGameCenterHelper : NSObject<GKGameCenterControllerDelegate,GKMatchmakerViewControllerDelegate,GKLocalPlayerListener,GKMatchDelegate
>

+(instancetype)sharedGameCenter;

-(void)authenticateLocalPlayerWithSuccessHandler:(void (^)(void))successHandler
								   failedHandler:(void (^)(NSError *error))failedHandler;

-(void)showGameCenterLoginViewControllerFailedHandler:(void (^)(void))failedHandler;

-(GKLocalPlayer *)anonymousGuestPlayerWithIdentifier:(NSString *)guestIdentifier;
+(GKLocalPlayer *)localPlayer;

+(NSString *)localPlayerId;

+(NSString *)localDisplayName;

+(NSString *)localPlayerAlias;

+(NSString *)getPlayerId:(GKPlayer *)player;

+(NSString *)getDisplayName:(GKPlayer *)player;

+(NSString *)getPlayerAlias:(GKPlayer *)player;

+(void)loadPlayerPhoto:(GKPlayer *)player size:(GKPhotoSize)photoSize withCompletionHandler:(void (^)(UIImage *photo, NSError *error))completionHandle;

+(void)loadPlayersForIdentifiers:(NSArray<NSString *> *)identifiers withCompletionHandler:(void (^)(NSArray<GKPlayer *> *players, NSError *error))completionHandler;

-(void)showLeaderboardInCurrentViewController:(UIViewController *)currentController 
								   viewStatus:(GKGameCenterViewControllerState)viewState 
									timeScope:(GKLeaderboardTimeScope)timeScope 
						  leadboardIdentifier:(NSString *)leaderIdentifier 
								 failedHandle:(void (^)(void))failedHandle 
								 finishHandle:(void (^)(void))finishHandle;

-(void)setMatchMakeViewControllerDelegateDidFindMatch:(void (^)(GKMatch *match))findMatchHandle
										 wasCancelled:(void (^)(void))cancelledHandle
									 didFailWithError:(void (^)(NSError *error))failedHandle
								 didFindHostedPlayers:(void (^)(NSArray<GKPlayer *> *players))findHostedPlayersHandle
								hostedPlayerDidAccept:(void (^)(GKPlayer *player))hostedPlayerDidAcceptHandle;

-(void)createAndShowMatchMakeViewControllerInCurrentViewController:(UIViewController *)currentController
														minPlayers:(NSInteger)minNum
														maxPlayers:(NSInteger)maxNum;

-(void)setGKMatchDelegateDidReceiveDataHandle:(void (^)(NSData *data,GKPlayer *recipient,GKPlayer *remotePlayer))receiveDataHandle
			   didChangeConnectionStateHandle:(void (^)(GKPlayer *player,GKPlayerConnectionState state))changeConnectionHandle
							  didFailedHandle:(void (^)(NSError *error))failedHandle
						 shouldReInviteHandle:(BOOL (^)(GKPlayer *player))reInviteHandle;

+(void)startAudioSession;

+(GKVoiceChat *)startVoiceChatWithMatch:(GKMatch*)match channelName:(NSString *)name playerStateUpdateHandle:(void (^)(GKPlayer *player, GKVoiceChatPlayerState state))updateHandle deviceNotSupportHandle:(void (^)(void))notSupportHandle;
@end
