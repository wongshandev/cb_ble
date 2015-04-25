//
//  PeripheralsDetailSettingViewController.h
//  BLECB
//
//  Created by Huang Shan on 15/4/24.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeripheralsDetailSettingViewController : UIViewController

@property (strong, nonatomic) NSString *textName;


@property (weak, nonatomic) IBOutlet UITextField *textFieldName;

@property (weak, nonatomic) IBOutlet UISwitch *switchProtect;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segemetDistance;

@property (weak, nonatomic) IBOutlet UIButton *butDisconnect;

-(IBAction)actionDisconnect:(id)sender;
@end
