//
//  Copyright © 2019-2021 Bandyer. All rights reserved.
//

#import "CallOptionsTableViewController.h"
#import "CallOptionsItem.h"

#define CALL_TYPE_SECTION 0
#define CALL_OPTIONS_SECTION 1

@interface CallOptionsTableViewController () <UITextFieldDelegate>

@end

@implementation CallOptionsTableViewController

//-------------------------------------------------------------------------------------------
#pragma mark - Init
//-------------------------------------------------------------------------------------------

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (void)commonInit
{
    _options = [CallOptionsItem new];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Table view datasource/delegate
//-------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if (indexPath.section == CALL_TYPE_SECTION)
    {
        cell.accessoryType = indexPath.row == (NSInteger) self.options.type ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if (indexPath.section == CALL_OPTIONS_SECTION)
    {
        if (indexPath.row == 0)
        {
            UISwitch *recordingSwitch = (UISwitch *) cell.accessoryView;
            recordingSwitch.on = self.options.record;
        } else if (indexPath.row == 1)
        {
            UITextField *textField = (UITextField *) cell.accessoryView;
            textField.text = [@(self.options.maximumDuration) stringValue];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == CALL_TYPE_SECTION)
    {
        self.options.type = (BDKCallType)indexPath.row;
        [self.tableView reloadData];
        [self.delegate controllerDidUpdateOptions:self];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Text Field
//-------------------------------------------------------------------------------------------

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.options.maximumDuration = (NSUInteger) [textField.text longLongValue];
    [self.tableView reloadData];
    [self.delegate controllerDidUpdateOptions:self];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)recordingSwitchValueChanged:(UISwitch *)sender
{
    self.options.record = sender.isOn;
    [self.tableView reloadData];
    [self.delegate controllerDidUpdateOptions:self];
}

@end
