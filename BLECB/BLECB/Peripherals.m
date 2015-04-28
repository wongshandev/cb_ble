//
//  Peripherals.m
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "Peripherals.h"


CBCentralManager *manager;
CBPeripheral *peripheral;
NSMutableArray *nDevices;
NSMutableArray *nServices;
NSMutableArray *nCharacteristics;
CBCharacteristic *writeCharacteristic;

NSMutableArray *allBleArray;
CBPeripheral * peripheralDeviceSelect;
@interface Peripherals ()
@property(nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong) UIActivityIndicatorView *activity;

@property (nonatomic)BOOL AllowRefreshing;
@property(nonatomic) float batteryValue;
@property (strong,nonatomic) NSMutableArray *nWriteCharacteristics;
@property (strong,nonatomic)UIBarButtonItem *rightbutton;
@end

@implementation Peripherals

- (void)re_scan:(id)sender
{
    if (_AllowRefreshing == YES)
    {
        [self initBLE];
    }
    else if(peripheralDeviceSelect.state == CBPeripheralStateConnected)
    {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"已经连接上，请先断开链接再刷新。",nil)];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];

    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"正在查找中，别刷新太快哦...",nil)];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
    }

}
- (void)active_display
{
    _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activity.frame = CGRectMake(85.0f,10.0f,30.0f,30.0f);
    _activity.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
    [_activity setCenter:CGPointMake(90.0f, self.navigationController.navigationBar.center.y-[[UIApplication sharedApplication] statusBarFrame].size.height)];
    _activity.hidesWhenStopped = YES;
    [self.navigationController.navigationBar addSubview:_activity];
    [_activity startAnimating];
}
- (void)viewDidLoad {
    _AllowRefreshing = YES;
    [self initTableView];
    [self initBLE];
    [self active_display];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    self.title=NSLocalizedString(@"设备列表",nil);
    
    [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"设备",nil)];
    NSDictionary *attributes = @{
                                 NSUnderlineStyleAttributeName: @1,
                                 NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                                 };
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _rightbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                            target:self
                                                                                            action:@selector(re_scan:)];
    [_rightbutton setImage:[UIImage imageNamed:@"scan_normal"]];
    [_rightbutton setTintColor:[UIColor whiteColor]];
    [_rightbutton setEnabled:NO];
    self.navigationItem.rightBarButtonItem = _rightbutton;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)initBLE
{
    nDevices = [[NSMutableArray alloc]init];
    nServices = [[NSMutableArray alloc]init];
    nCharacteristics = [[NSMutableArray alloc]init];

    _nWriteCharacteristics = [[NSMutableArray alloc]init];
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    //断开BLE NTtackePhontos
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(DisConnectBLE)
                                                 name: @"DisConnectBLE_NS"
                                               object: nil];
}
- (void)initNotice
{
    //本地通知
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    if (notification != nil) {
        // 初始化本地通知
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        // 通知触发时间
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        // 触发后，弹出警告框中显示的内容
        localNotification.alertBody = @"移动电源报警";
        // 触发时的声音（这里选择的系统默认声音）
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        // 触发频率（repeatInterval是一个枚举值，可以选择每分、每小时、每天、每年等）
        localNotification.repeatInterval = NSCalendarUnitDay;
        // 需要在App icon上显示的未读通知数（设置为1时，多个通知未读，系统会自动加1，如果不需要显示未读数，这里可以设置0）
        localNotification.applicationIconBadgeNumber = 0;
        // 设置通知的id，可用于通知移除，也可以传递其他值，当通知触发时可以获取
        localNotification.userInfo = @{@"id" : @"notificationIdBLE"};
        localNotification.alertBody = @"报警";
        localNotification.soundName = @"雷达咚咚音效.mp3";
        // 注册本地通知
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}
- (void)removeLocalNotification {
    
    // 取出全部本地通知
    NSArray *notifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    // 设置要移除的通知id
    NSString *notificationId = @"notificationIdBLE";
    
    // 遍历进行移除
    for (UILocalNotification *localNotification in notifications) {
        
        // 将每个通知的id取出来进行对比
        if ([[localNotification.userInfo objectForKey:@"id"] isEqualToString:notificationId]) {
            
            // 移除某一个通知
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }
}

- (void)BLEscan
{
    [_activity startAnimating];
    //扫描所有的外设
//    [manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    [manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    _AllowRefreshing = NO;
    double delayInSeconds = 10.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [manager stopScan];
        [_activity stopAnimating];
        _AllowRefreshing = YES;
        NSLog(@"扫描超时");
    });

}
- (void)viewDidAppear:(BOOL)animated
{
}
- (void)viewWillDisappear:(BOOL)animated
{
    [_activity stopAnimating];
}
- (void)initTableView
{
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Table Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [nDevices count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *peripherCustCell = @"peripherCustCell_";
    
    
    PeripheralsCell * cell =(PeripheralsCell *)[tableView
                                        dequeueReusableCellWithIdentifier:peripherCustCell];
    if (cell == nil)
    {
        NSArray *nib=[[NSBundle mainBundle]loadNibNamed:@"PeripheralsCell"
                                                  owner:self
                                                options:nil];
        cell=[nib objectAtIndex:0];
    }
    CBPeripheral * peripheralDevice = [nDevices objectAtIndex:indexPath.row];
    if (peripheralDevice.state == CBPeripheralStateDisconnected)
    {
        [cell.cellHeardImgview setImage:[UIImage imageNamed:@"device_icon_off"]];
        [cell.PeripherConnectBut setBackgroundImage:[UIImage imageNamed:@"connect_bottom_off"] forState:UIControlStateNormal];
        [cell.PeripherConnectBut setTitle:NSLocalizedString(@"连接",nil) forState:UIControlStateNormal];
        [cell.PerpherConectStatueLabel setText:NSLocalizedString(@"未连接",nil)];
        [cell.PeripherConnectBut setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [cell.PerpherConectStatueLabel setTextColor:[UIColor grayColor]];
    }
    else
    {
        [cell.cellHeardImgview setImage:[UIImage imageNamed:@"device_icon_on"]];
        [cell.PeripherConnectBut setBackgroundImage:[UIImage imageNamed:@"connect_bottom_on"] forState:UIControlStateNormal];
        [cell.PeripherConnectBut setTitle:NSLocalizedString(@"报警",nil) forState:UIControlStateNormal];
        [cell.PeripherConnectBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cell.PerpherConectStatueLabel setText:NSLocalizedString(@"已连接",nil)];
        [cell.PerpherConectStatueLabel setTextColor:[UIColor greenColor]];
    }
    cell.PeripherConnectBut.tag = indexPath.row;
    cell.PeripherNextBut.tag = indexPath.row;
    cell.PeripherNameLabel.text = peripheralDevice.name;
//    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];//显示小箭头
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 3;
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)DisConnectBLE
{
    if (peripheralDeviceSelect.state != CBPeripheralStateDisconnected)
    {
        [manager cancelPeripheralConnection:peripheralDeviceSelect];
    }
    [_tableView reloadData];

}
- (IBAction)BLEConnectAction:(id)sender
{
    
    NSLog(@"连接开始");
    UIButton *btn = (UIButton *)sender;
    CBPeripheral * peripheralDevice = [nDevices objectAtIndex:btn.tag];

    if (peripheralDevice.state == CBPeripheralStateDisconnected)
    {
        for (CBPeripheral *p in nDevices) {
            if (p.state == CBPeripheralStateConnected)
            {
                NSLog(@"有链接先断开");
                //如果有连接的设备，先断开
                [self DisConnectBLE];
            }
        }

        [manager connectPeripheral:[nDevices objectAtIndex:btn.tag] options:nil];
    }
    else
    {
        //kTTSetABC
        writeCharacteristic = [_nWriteCharacteristics objectAtIndex:btn.tag];
        [peripheralDevice readValueForCharacteristic:writeCharacteristic];
        [peripheralDevice writeValue:[kSearchDevice dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"发送中...",nil)];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
    }
}
- (void)BLEwriteValue:(NSString *)command
{
    if (command != nil)
    {
        [peripheral writeValue:[command dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}
- (IBAction)PeripherSettingAction:(id)sender
{
    NSLog(@"进入设置");
    UIButton *btn = (UIButton *)sender;
    
    peripheralDeviceSelect = [nDevices objectAtIndex:btn.tag];
    
    if (peripheralDeviceSelect.state == CBPeripheralStateConnected)
    {
        PeripheralsDetailSettingViewController *vc = [[PeripheralsDetailSettingViewController alloc]init];
        vc.manager = manager;
        [vc setPeripheralsub:[nDevices objectAtIndex:0]];
        [vc setWriteCharacteristicsub:[_nWriteCharacteristics objectAtIndex:0]];
        vc.textName = peripheralDeviceSelect.name;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"连接已断开，请重新连接。",nil)];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
    }
}
//开始查看服务，蓝牙开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙已打开,请扫描外设");
            [_rightbutton setEnabled:YES];
            [self BLEscan];
            break;
        case CBCentralManagerStateUnsupported:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"设备不支持BLE哦。",nil)];
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
            [_rightbutton setEnabled:NO];
            [_activity stopAnimating];
            NSLog(@"设备不支持BLE4.0");
            break;
        default:
            [_activity stopAnimating];
            [_rightbutton setEnabled:NO];
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请打开本机蓝牙哦",nil)];
            NSLog(@"没打开蓝牙");
            break;
    }
}
//查到外设后，停止扫描，连接设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.UUID, advertisementData);
    peripheral = peripheral;
    
    BOOL replace = NO;
    for (int i=0; i < nDevices.count; i++) {
        CBPeripheral *p = [nDevices objectAtIndex:i];
        if ([p isEqual:peripheral]) {
            [nDevices replaceObjectAtIndex:i withObject:peripheral];
            replace = YES;
        }
    }
    if (!replace)
    {
        [nDevices addObject:peripheral];
        [_tableView reloadData];
    }
    
}
- (NSString *)getConfig
{
    NSString * cmdString = [[NSString alloc]initWithFormat:@"@TTSet"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:kCloseString forKey:@"MIANDARAO"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:kOpenString forKey:@"FANGDAO"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAOJULI"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"FANGDAOJULI"];
    }
    
    cmdString = [cmdString stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"]];
    cmdString = [cmdString stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"]];
    cmdString = [cmdString stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAOJULI"]];
    cmdString = [cmdString stringByAppendingString:@"#"];
    return cmdString;
}
//连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"成功连接 peripheral: %@ with UUID: %@ ->>>>>>mac:  %s",peripheral,peripheral.UUID,[self UUIDToString:peripheral.UUID]);
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    
    //连接上了就断开搜索服务
    [manager stopScan];
    [_activity stopAnimating];
    _AllowRefreshing = NO;
    
}
//外设断开了
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"断开了。。。。");
    _AllowRefreshing = YES;
    if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] isEqualToString:kCloseString])
        ||([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"] isEqualToString:kOpenString]))
    {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"设备已断开",nil)];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
        [self initNotice];
    }
    [self initBLE];
    [_tableView reloadData];
}
/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using printf()
 *
 */
-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}

//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",error);
}
-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    //NSLog(@"%s,%@",__PRETTY_FUNCTION__,peripheral);
//    int rssi = abs([peripheral.RSSI intValue]);
//    CGFloat ci = (rssi - 49) / (10 * 4.);
//    NSString *length = [NSString stringWithFormat:@"发现BLT4.0热点:%@,距离:%.1fm",_peripheral,pow(10,ci)];
//    NSLog(@"距离：%@",length);
}
//已发现服务
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
//    NSLog(@"已发现服务");
    int i=0;
    for (CBService *s in peripheral.services) {
        [nServices addObject:s];
    }
    for (CBService *s in peripheral.services) {
        NSLog(@"%d :服务 UUID: %@(%@)",i,s.UUID.data,s.UUID);
        i++;
//        NSLog(@"开始发现特征");
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    peripheral = peripheral;
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@"特征 UUID: %@ (%@)",c.UUID.data,c.UUID);
        if ([c.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]])
        {
            BOOL _isPlace = false;
            
            [peripheral setNotifyValue:YES forCharacteristic:c];

            for (int i=0; i < [nCharacteristics count]; i++)
            {
                CBCharacteristic *_tmpwriteCharacteristic = [nCharacteristics objectAtIndex:i];
                if ([_tmpwriteCharacteristic isEqual:c])
                {
                    _isPlace = true;
                }
            }
            
            if (_isPlace == false)
            {
                [nCharacteristics addObject:c];
            }
        }
        if ([c.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicWirteUUID]]) {
            [_nWriteCharacteristics addObject:c];
            [peripheral writeValue:[[self getConfig] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
        }
    }
}
//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // BOOL isSaveSuccess;
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        _batteryValue = [value floatValue];
        NSLog(@"电量%f",_batteryValue);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        //_batteryValue = [value floatValue];
        NSLog(@"信号%@",value);
    }
    else if ([[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] isEqualToString:kRevStartAlarm])
    {
        if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] isEqualToString:kCloseString])
            ||([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"] isEqualToString:kOpenString]))
        {
            [self initNotice];
        }
        else
        {
            NSLog(@"其它情况不打开通知");
        }
    }//nNoticeTakePhotos
    else if (([[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] isEqualToString:kRevTackPhotos]))
    {
        NSLog(@"拍照命令");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NTtackePhontos" object:self];
    }
    else
        NSLog(@"didUpdateValueForCharacteristic%@",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
}
//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    // Notification has started
    if (characteristic.isNotifying)
    {
        [peripheral readValueForCharacteristic:characteristic];
        
    } else { // Notification has stopped
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [manager cancelPeripheralConnection:peripheral];
    }
    
    //更新TBALEVIEW
    peripheral = peripheral;
    NSLog(@"%@",peripheral);
    
    BOOL replace = NO;
    for (int i=0; i < nDevices.count; i++) {
        CBPeripheral *p = [nDevices objectAtIndex:i];
        if ([p.identifier isEqual:peripheral.identifier]) {
            [nDevices replaceObjectAtIndex:i withObject:peripheral];
            replace = YES;
        }
    }
    if (replace)
    {
        [_tableView reloadData];
    }

}
//用于检测中心向外设写数据是否成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"ERROR: Result of writing to characteristic: %@ of service: %@ with error: %@", characteristic.UUID, characteristic.service.UUID, error);
    }else{
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"发送成功",nil)];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
        NSLog(@"发送数据成功");
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
