//
//  PeripheralsDetailSettingViewController.m
//  BLECB
//
//  Created by Huang Shan on 15/4/24.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "PeripheralsDetailSettingViewController.h"
#import "SVProgressHUD.h"

BOOL _isActiveView;
@interface PeripheralsDetailSettingViewController ()
@property(nonatomic,strong)UIBarButtonItem *rightbutton;
@property(nonatomic,strong)UIBarButtonItem *leftbutton;
@end

@implementation PeripheralsDetailSettingViewController
@synthesize textName;
- (void)ation_done:(id)sender
{
    [_textFieldName resignFirstResponder];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"已保存",nil)];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
//    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)actionAlert:(id)sender
{
    [self BLEwriteValue:kSearchDevice];
}
- (void)viewWillAppear:(BOOL)animated
{
    _isActiveView = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"断开",nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(actionDisconnect:)];
    [self.navigationItem setHidesBackButton:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
}
- (void)viewDidDisappear:(BOOL)animated
{
    _isActiveView = NO;
}
- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(popViewFromPeripheralsDetail)
                                                 name: @"disConnect_nofiy"
                                               object: nil];

    [super viewDidLoad];
    self.tabBarController.delegate = self;
    _rightbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                 target:self
                                                                 action:@selector(ation_done:)];
    [_rightbutton setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.rightBarButtonItem = _rightbutton;

    
    self.textFieldName.delegate =self;
    [self.textFieldName addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.textFieldName setCenter:CGPointMake(self.view.center.x+10.0f, self.textFieldName.center.y)];
    [self.switchProtect setCenter:CGPointMake(self.view.center.x+20.0f, self.switchProtect.center.y)];
    [self.segemetDistance setCenter:CGPointMake(self.view.center.x, self.segemetDistance.center.y)];
    [self.butDisconnect setFrame:CGRectMake((self.view.frame.size.width-107.0f)/2.0, self.butDisconnect.frame.origin.y, self.butDisconnect.frame.size.width, self.butDisconnect.frame.size.height)];
    
    self.textFieldName.text = textName;
    // Do any additional setup after loading the view from its nib.
    [self.switchProtect addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.switchProtect setTintColor:[UIColor redColor]];
    [self.segemetDistance setTintColor:[UIColor redColor]];
    [self.segemetDistance addTarget:self action:@selector(_segment_select:) forControlEvents:UIControlEventValueChanged];
    if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"] isEqualToString:kOpenString]))
    {
        [self.switchProtect setOn:YES];
    }
    else
    {
        [self.switchProtect setOn:NO];
    }
    if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAOJULI"] isEqualToString:@"0"]))
    {
        [self.segemetDistance setSelectedSegmentIndex:0];
    }
    else if ((([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAOJULI"] isEqualToString:@"1"])))
    {
        [self.segemetDistance setSelectedSegmentIndex:1];
    }
    else
    {
        [self.segemetDistance setSelectedSegmentIndex:2];
    }
    [_btAlert setTitle:NSLocalizedString(@"报  警",nil) forState:UIControlStateNormal];
    [_btAlert setCenter:CGPointMake(self.view.center.x, _btAlert.center.y)];
}
- (void)textFieldEditChanged:(UITextField *)textField
{
    NSLog(@"textfield text %@",textField.text);
    [nPerpherName setObject:textField.text forKey:self.Peripheralsub.identifier];
    [PeripheralsDetailSettingViewController saveFordicName:nPerpherName];
    
}
+(void)saveFordicName:(NSMutableDictionary *)dic
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"name_dic_perpher"];
}
+(NSMutableDictionary *)getFordicName
{
    NSData *data =[[NSUserDefaults standardUserDefaults] objectForKey:@"name_dic_perpher"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
- (void)DisConnectBLE
{
    if (self.Peripheralsub.state != CBPeripheralStateDisconnected)
    {
        [self.manager cancelPeripheralConnection:self.Peripheralsub];
    }
}
- (void)BLEwriteValue:(NSString *)command
{
    if (command != nil) {
        [_Peripheralsub writeValue:[command dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_writeCharacteristicsub type:CBCharacteristicWriteWithResponse];
    }
}
- (void)_segment_select:(id)sender
{
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    switch (control.selectedSegmentIndex) {
        case 0:
        {
            NSLog(@"近");
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"FANGDAOJULI"];
            [self BLEwriteValue:kSetAlarmDist2m];
            [self setSuccesfullPop];
        }
            break;
        case 1:
        {
            NSLog(@"中");
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"FANGDAOJULI"];
            [self BLEwriteValue:kSetAlarmDist5m];
            [self setSuccesfullPop];
        }
            break;
        case 2:
        {
            NSLog(@"远");
            [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"FANGDAOJULI"];
            [self BLEwriteValue:kSetAlarmDist10m];
            [self setSuccesfullPop];
        }
            break;
        default:
            break;
    }
    
}
- (void)setSuccesfullPop
{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"设置成功",nil)];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
}

-(void)actionDisconnect:(id)sender
{
    NSLog(@"断开");
    
    [self popViewFromPeripheralsDetail];
    
    [self DisConnectBLE];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisConnectBLE_NS" object:self];

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
        [[NSUserDefaults standardUserDefaults] setObject:kOpenString forKey:@"FANGDAO"];
        [self setSuccesfullPop];
        [self BLEwriteValue:kCloseSecurity];

    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:kCloseString forKey:@"FANGDAO"];
        [self setSuccesfullPop];
        [self BLEwriteValue:kOpenSecurity];
        NSLog(@"关闭防盗");
    }
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{

}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (viewController == [tabBarController.viewControllers objectAtIndex:0] &&(_isActiveView == YES))
    {
        // Enable all but the last tab.
        return NO;
    }
    
    return YES;
}
- (void)popViewFromPeripheralsDetail
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
