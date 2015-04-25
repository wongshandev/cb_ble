//
//  Peripherals.m
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "Peripherals.h"
NSMutableArray *allBleArray;
CBPeripheral * peripheralDeviceSelect;
@interface Peripherals ()
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property(nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong) UIActivityIndicatorView *activity;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *nServices;
@property (strong,nonatomic) NSMutableArray *nCharacteristics;
@property(nonatomic) float batteryValue;
@property (strong ,nonatomic) CBCharacteristic *writeCharacteristic;
@property (nonatomic)BOOL isRefreshing;
@end

@implementation Peripherals

- (void)viewDidLoad {
    
    //test
//    BleStatus * arry1 = [BleStatus new];
    BleStatus * arry2 = [BleStatus new];
    BleStatus * arry3 = [BleStatus new];
    BleStatus * arry4 = [BleStatus new];

    
    allBleArray = [[NSMutableArray alloc]initWithObjects:@"sfsfd",arry2,arry3,arry4,nil];
    
    _isRefreshing = YES;
    [self initTableView];
    [self initBLE];
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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)initBLE
{
    _nDevices = [[NSMutableArray alloc]init];
    _nServices = [[NSMutableArray alloc]init];
    _nCharacteristics = [[NSMutableArray alloc]init];
    //本地通知
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    if (notification != nil) {
        NSDate *now = [NSDate new];
        notification.fireDate = [now dateByAddingTimeInterval:10];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.alertBody = @"报警";
        notification.soundName = @"雷达咚咚音效.mp3";
        notification.applicationIconBadgeNumber = 1;
        notification.alertAction = @"关闭";
        
        [[UIApplication sharedApplication]scheduleLocalNotification:notification];
    }
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(DisConnectBLE)
                                                 name: @"DisConnectBLE_NS"
                                               object: nil];
}
- (void)BLEscan
{
    //扫描所有的外设
    [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
//    [_manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"]] options:nil];
    double delayInSeconds = 30.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.manager stopScan];
        [_activity stopAnimating];
        NSLog(@"扫描超时");
    });

}
- (void)viewDidAppear:(BOOL)animated
{
    if (_isRefreshing == YES)
    {
        _isRefreshing = NO;
        _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.frame = CGRectMake(85.0f,10.0f,30.0f,30.0f);
        _activity.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
        [_activity setCenter:CGPointMake(90.0f, self.navigationController.navigationBar.center.y-[[UIApplication sharedApplication] statusBarFrame].size.height)];
        _activity.hidesWhenStopped = YES;
        [self.navigationController.navigationBar addSubview:_activity];
        [_activity startAnimating];
    }
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
    return [_nDevices count];
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
    CBPeripheral * peripheralDevice = [_nDevices objectAtIndex:indexPath.row];
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
        [self.manager cancelPeripheralConnection:peripheralDeviceSelect];
    }
    [_tableView reloadData];

}
- (IBAction)BLEConnectAction:(id)sender
{
    
    NSLog(@"连接开始");
    UIButton *btn = (UIButton *)sender;
    
//    static BOOL _cbReady = false;
    
    CBPeripheral * peripheralDevice = [_nDevices objectAtIndex:btn.tag];

    if (peripheralDevice.state == CBPeripheralStateDisconnected)
    {
        [self.manager connectPeripheral:[_nDevices objectAtIndex:btn.tag] options:nil];
    }
    else
    {
        unsigned char data = 0x02;

        [peripheralDevice writeValue:[NSData dataWithBytes:&data length:1] forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }

    [_tableView reloadData];
}
- (IBAction)PeripherSettingAction:(id)sender
{
    NSLog(@"进入设置");
    UIButton *btn = (UIButton *)sender;
//    peripheralDeviceSelect = [[CBPeripheral alloc]init];//[_nDevices objectAtIndex:btn.tag];
    
    peripheralDeviceSelect = [[_nDevices objectAtIndex:btn.tag] copy];
    PeripheralsDetailSettingViewController *vc = [[PeripheralsDetailSettingViewController alloc]init];
    
    vc.textName = peripheralDeviceSelect.name;
    [self.navigationController pushViewController:vc animated:YES];
}
//开始查看服务，蓝牙开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙已打开,请扫描外设");
            [self BLEscan];
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"设备不支持BLE4.0");
            break;
        default:
            NSLog(@"没打开蓝牙");
            break;
    }
}
//查到外设后，停止扫描，连接设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.UUID, advertisementData);
    _peripheral = peripheral;
    NSLog(@"%@",_peripheral);

    BOOL replace = NO;
    for (int i=0; i < _nDevices.count; i++) {
        CBPeripheral *p = [_nDevices objectAtIndex:i];
        if ([p isEqual:peripheral]) {
            [_nDevices replaceObjectAtIndex:i withObject:peripheral];
            replace = YES;
        }
    }
    if (!replace)
    {
        [_nDevices addObject:peripheral];
        [_tableView reloadData];
    }
}
//连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"成功连接 peripheral: %@ with UUID: %@",peripheral,peripheral.UUID);
    [self.peripheral setDelegate:self];
    [self.peripheral discoverServices:nil];
    
    //连接上了就断开服务
    [self.manager stopScan];
    [_activity stopAnimating];
}
//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",error);
}
-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    //NSLog(@"%s,%@",__PRETTY_FUNCTION__,peripheral);
    int rssi = abs([peripheral.RSSI intValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    NSString *length = [NSString stringWithFormat:@"发现BLT4.0热点:%@,距离:%.1fm",_peripheral,pow(10,ci)];
    NSLog(@"距离：%@",length);
}
//已发现服务
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    NSLog(@"已发现服务");
    int i=0;
    for (CBService *s in peripheral.services) {
        [self.nServices addObject:s];
    }
    for (CBService *s in peripheral.services) {
        NSLog(@"%d :服务 UUID: %@(%@)",i,s.UUID.data,s.UUID);
        i++;
        NSLog(@"开始发现特征");
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"发现特征的服务:%@ (%@)",service.UUID.data ,service.UUID);
    self.peripheral = peripheral;
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@"特征 UUID: %@ (%@)",c.UUID.data,c.UUID);
        if (([c.UUID isEqual:[CBUUID UUIDWithString:@"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"]])&&(c.))
//        if (1)
        {
            [self.peripheral setNotifyValue:YES forCharacteristic:c];
        }
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A06"]]) {
            _writeCharacteristic = c;
        }
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
            [_peripheral readValueForCharacteristic:c];
        }
        
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
            [_peripheral readRSSI];
        }
        [_nCharacteristics addObject:c];
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
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        //_batteryValue = [value floatValue];
        NSLog(@"信号%@",value);
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
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
        
    } else { // Notification has stopped
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.manager cancelPeripheralConnection:self.peripheral];
    }
    
    //更新TBALEVIEW
    _peripheral = peripheral;
    NSLog(@"%@",_peripheral);
    
    BOOL replace = NO;
    for (int i=0; i < _nDevices.count; i++) {
        CBPeripheral *p = [_nDevices objectAtIndex:i];
        if ([p.identifier isEqual:peripheral.identifier]) {
            [_nDevices replaceObjectAtIndex:i withObject:peripheral];
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
        NSLog(@"=======%@",error.userInfo);
    }else{
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
