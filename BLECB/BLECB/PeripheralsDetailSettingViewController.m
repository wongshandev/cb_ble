//
//  PeripheralsDetailSettingViewController.m
//  BLECB
//
//  Created by Huang Shan on 15/4/24.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "PeripheralsDetailSettingViewController.h"

@interface PeripheralsDetailSettingViewController ()

@end

@implementation PeripheralsDetailSettingViewController
@synthesize textName;
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.textFieldName setCenter:CGPointMake(self.view.center.x+10.0f, self.textFieldName.center.y)];
    [self.switchProtect setCenter:CGPointMake(self.view.center.x+20.0f, self.switchProtect.center.y)];
    [self.segemetDistance setCenter:CGPointMake(self.view.center.x, self.segemetDistance.center.y)];
//    [self.butDisconnect setCenter:CGPointMake(0, self.butDisconnect.center.y)];
    [self.butDisconnect setFrame:CGRectMake((self.view.frame.size.width-107.0f)/2.0, self.butDisconnect.frame.origin.y, self.butDisconnect.frame.size.width, self.butDisconnect.frame.size.height)];
    self.textFieldName.text = textName;
    // Do any additional setup after loading the view from its nib.
    [self.switchProtect addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.segemetDistance setTintColor:[UIColor redColor]];
    [self.segemetDistance addTarget:self action:@selector(_segment_select:) forControlEvents:UIControlEventValueChanged];

}
- (void)_segment_select:(id)sender
{
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    switch (control.selectedSegmentIndex) {
        case 0:
        {
            NSLog(@"近");
        }
            break;
        case 1:
        {
            NSLog(@"中");
        }
            break;
        case 2:
        {
            NSLog(@"远");
        }
            break;
        default:
            break;
    }
    
}

-(void)actionDisconnect:(id)sender
{
    NSLog(@"断开");
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisConnectBLE_NS" object:self];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn)
    {
        NSLog(@"打开防盗");
    }else
    {
        NSLog(@"关闭防盗");
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
