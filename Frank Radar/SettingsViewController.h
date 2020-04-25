//
//  SettingsViewController.h
//  Frank Radar
//
//  Created by Mathieu Mallet on 2013-09-22.
//  Copyright (c) 2013 Equinox Synthetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *dataSourceLabel;
@property (weak, nonatomic) IBOutlet UISwitch *showLocationSwitch;

@end
