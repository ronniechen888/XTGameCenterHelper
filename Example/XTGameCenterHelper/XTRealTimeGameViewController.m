//
//  XTRealTimeGameViewController.m
//  XTGameCenterHelper_Example
//
//  Created by Ronnie Chen on 2017/12/6.
//  Copyright © 2017年 ronniechen888. All rights reserved.
//

#import "XTRealTimeGameViewController.h"

@interface XTRealTimeGameViewController ()

@end

@implementation XTRealTimeGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(100, 200, 100, 100);
	[button setBackgroundColor:[UIColor redColor]];
	[button addTarget:self action:@selector(doClick:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	
	[[XTGameCenterHelper sharedGameCenter] setGKMatchDelegateDidReceiveDataHandle:^(NSData *data, GKPlayer *recipient, GKPlayer *remotePlayer) {
		NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog(@"%@",dataString);
		NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
		
		[button setBackgroundColor:[UIColor colorWithRed:[jsonDic[@"R"] integerValue]/255.0 green:[jsonDic[@"G"] integerValue]/255.0 blue:[jsonDic[@"B"] integerValue]/255.0 alpha:1]];
	}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)doClick:(id)sender{
	int R = (arc4random() % 256) ;
	int G = (arc4random() % 256) ;
	int B = (arc4random() % 256) ;
	UIButton *button = (UIButton *)sender;
	[button setBackgroundColor:[UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1]];

	[self.match sendData:[[NSString stringWithFormat:@"{\"R\":%d,\"G\":%d,\"B\":%d}",R,G,B] dataUsingEncoding:NSUTF8StringEncoding] toPlayers:_match.players dataMode:GKMatchSendDataReliable error:nil];
}

@end
