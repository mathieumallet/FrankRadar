//
//  DataSourceViewController.h
//  Frank Radar
//
//  Created by Mathieu Mallet on 2013-09-24.
//  Copyright (c) 2013 Equinox Synthetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataSourceViewController : UITableViewController
{
    NSMutableArray* groups; // index is section number
    NSMutableDictionary* items; // key is section number, value is mutable array of radar station codes
}
@end
