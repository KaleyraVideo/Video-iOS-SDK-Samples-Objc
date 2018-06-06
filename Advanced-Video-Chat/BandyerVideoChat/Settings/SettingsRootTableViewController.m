//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "SettingsRootTableViewController.h"


@interface SettingsRootTableViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneBarButtonItem;

@end

@implementation SettingsRootTableViewController


- (IBAction)doneButtonItemTouched:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
