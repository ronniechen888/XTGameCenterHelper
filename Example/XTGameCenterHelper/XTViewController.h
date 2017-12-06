//
//  XTViewController.h
//  XTGameCenterHelper
//
//  Created by ronniechen888 on 11/30/2017.
//  Copyright (c) 2017 ronniechen888. All rights reserved.
//

@import UIKit;
#import "XTGameCenterHelper.h"

@interface XTViewController : UIViewController

@property (nonatomic,weak) IBOutlet UIImageView *headView;
@property (nonatomic,weak) IBOutlet UILabel *aliasLabel;
@property (nonatomic,weak) IBOutlet UILabel *displayLabel;
@property (nonatomic,weak) IBOutlet UILabel *playIdLabel;

-(IBAction)showLeaderBoard:(id)sender;
-(IBAction)invite:(id)sender;

@end
