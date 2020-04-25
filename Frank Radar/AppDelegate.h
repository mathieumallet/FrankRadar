//
//  AppDelegate.h
//  Frank Radar
//
//  Created by Mathieu Mallet on 2013-09-14.
//  Copyright (c) 2013 Equinox Synthetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadarModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property RadarModel* model;

@end
