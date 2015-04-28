//
//  PeripheralsDetailSettingViewController.h
//  BLECB
//
//  Created by Huang Shan on 15/4/24.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Peripherals.h"
#import "SVProgressHUD.h"
#import <CoreBluetooth/CoreBluetooth.h>
@import CoreBluetooth;

@class SCPCoreBluetoothCentralManager;
@class CBPeripheral;

@interface PeripheralsDetailSettingViewController : UIViewController

@property (strong, nonatomic) NSString *textName;


@property (weak, nonatomic) IBOutlet UITextField *textFieldName;

@property (weak, nonatomic) IBOutlet UISwitch *switchProtect;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segemetDistance;

@property (weak, nonatomic) IBOutlet UIButton *butDisconnect;

-(IBAction)actionDisconnect:(id)sender;
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *Peripheralsub;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *nServices;
//@property (strong,nonatomic) NSMutableArray *nCharacteristics;
@property (strong ,nonatomic) CBCharacteristic *writeCharacteristicsub;

@end
