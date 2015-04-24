//
//  settings.m
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "settings.h"

@interface settings ()

@end

@implementation settings

- (void)viewDidLoad {
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

@end
