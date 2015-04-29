//
//  settings.m
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "settings.h"
#import "SBJSON.h"
@interface settings ()

@property (nonatomic,strong)UITableView *tableview;
@property (strong, nonatomic)UISwitch *switchmiandarao;

@end

@implementation settings
- (void)setProsessPop
{
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"正在发送请求...",nil)];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
}
- (void)BLEwriteValue:(NSString *)command
{
    for (CBPeripheral *p in nDevices)
    {
        if (p.state == CBPeripheralStateConnected)
        {
            [p writeValue:[command dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:[_nWriteCharacteristics objectAtIndex:0] type:CBCharacteristicWriteWithResponse];
        }
    }
}
-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn)
    {
        NSLog(@"打开免打扰");
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"MIANDARAO"];
        [self BLEwriteValue:@"@OpenNoDisturb#"];
        [self setProsessPop];
        
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"MIANDARAO"];
        [self setProsessPop];
        [self BLEwriteValue:@"@CloseSecurity#"];
        NSLog(@"关闭免打扰");
    }
}

- (void)viewDidLoad {
    
    _tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableview.delegate=self;
    _tableview.dataSource = self;
    _tableview.rowHeight = 55.0f;
    
    _tableview.separatorColor = [UIColor darkGrayColor];
    _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableview];
    
    self.switchmiandarao = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2.0 + 80.0f, 0, 80.0f, 35.0f)];
    [self.switchmiandarao setTintColor:[UIColor redColor]];
    [self.switchmiandarao addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] isEqualToString:@"0"])
    {
        [self.switchmiandarao setOn:YES];
    }
    else
        [self.switchmiandarao setOn:NO];
    
    self.title=NSLocalizedString(@"设置",nil);
    [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"设置",nil)];

    NSDictionary *attributes = @{
                                 NSUnderlineStyleAttributeName: @1,
                                 NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                                 };
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell_deafult";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        //cell的四种样式
        //UITableViewCellStyleDefault,       只显示图片和标题
        //UITableViewCellStyleValue1,		显示图片，标题和子标题（子标题在右边）
        //UITableViewCellStyleValue2,		标题和子标题
        //UITableViewCellStyleSubtitle		显示图片，标题和子标题（子标题在下边）
    }
    if (indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"免打扰设置",nil);
        [self.switchmiandarao setCenter:CGPointMake(self.switchmiandarao.center.x, cell.center.y)];
        [cell addSubview:self.switchmiandarao];
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"当前版本",nil);
        cell.detailTextLabel.text = @"Ver1.0.0";
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];//显示小箭头
    }
    else
    {
        
    }
    cell.textLabel.textColor = [UIColor darkGrayColor];//设置标题字体颜色
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;//默认为1
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1)
    {
        [SVProgressHUD showProgress:0.0f status:@"正在检查..."];
        [self performSelector:@selector(increateProgress) withObject:nil afterDelay:0.2f];
        [self getVersion];
    }
}
static float progressVaule = 0.0f;
static bool isGetResult = false;
- (void)increateProgress
{
    progressVaule += 0.05f;
    [SVProgressHUD showProgress:progressVaule status:@"正在检查..."];
    
    if (isGetResult == true)
    {
        isGetResult = false;
        [SVProgressHUD dismiss];
        return;
    }
    if (progressVaule < 1.0f)
    {
        [self performSelector:@selector(increateProgress) withObject:nil afterDelay:0.05f];
    }
    else
    {
        progressVaule = 0.0;
        isGetResult = false;
        [SVProgressHUD dismiss];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getVersion
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDic));
//    NSString *app_Name = [infoDic objectForKey:@"CFBundleDisplayName"];
    NSString *app_Version = [infoDic objectForKey:@"CFBundleShortVersionString"];
    // app build版本
//    NSString *app_build = [infoDic objectForKey:@"CFBundleVersion"];
    
    float ver = [app_Version floatValue];
    
    NSString * ota_url = [NSString stringWithFormat:@"http://iosvoipapp.qiniudn.com/BLE_CB.txt"];
    [SVHTTPRequest POST:ota_url
             parameters:nil
             completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                 
                 NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
                 NSString * ReturnData = [[NSString alloc] initWithData:response encoding:enc];
                 NSLog(@"return data [%@]",ReturnData);
                 
                 isGetResult = true;
                 NSMutableArray * arry = [[NSMutableArray alloc]init];
                 SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                 
                 arry = [jsonParser objectWithString:ReturnData];
                 
                 {
                     float version = 0.0;
                     NSString * definition = nil;
                     NSDictionary * info = [[arry objectAtIndex:0] objectForKey:@"app_info"];
                     
                     version = [[info objectForKey:@"version"] floatValue];
                     
                     version = (int)(version*10);
                     if (version > (int)ver*10)
                     {
                         //需要升级
                         NSString * ota_url =nil;
                         
                         ota_url = [[NSString alloc]initWithFormat:@"%@",[info objectForKey:@"download_url"]];
                         
                         NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                         [defaults setObject:ota_url forKey:@"updata_url"];
                         [defaults synchronize];
                         
                         
                         definition =[[NSString alloc]initWithFormat:@"%@",[info objectForKey:@"version_definition"]];
                         
                         UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"有更新了" message:definition delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"现在去更新", nil];
                         alert.delegate =self;
                         alert.tag = 99;
                         [alert show];
                     }
                     
                     //以下是保护
                     NSString * isProtect = nil;
                     
                     NSDictionary * app_protect = [[arry objectAtIndex:0] objectForKey:@"app_protect"];
                     isProtect = [[NSString alloc]initWithFormat:@"%@",[app_protect objectForKey:@"protect"]];
                     if ([isProtect isEqualToString:@"YES"])
                     {
                         NSString *msgContent = [app_protect objectForKey:@"protect_definition"];
                         UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:msgContent delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                         [alert show];
                     }
                     
                 }
             }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex == 1)&&(alertView.tag == 99)) {
        NSURL * url_open = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"updata_url"]];
        [[UIApplication sharedApplication]openURL:url_open];
        
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
