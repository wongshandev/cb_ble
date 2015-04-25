//
//  Peripherals.h
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeripheralsCell.h"
#import "PeripheralsDetailSettingViewController.h"
#import "BleStatus.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface Peripherals : UIViewController<UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate,CBPeripheralDelegate>


- (IBAction)BLEConnectAction:(id)sender;
- (IBAction)PeripherSettingAction:(id)sender;
@end
