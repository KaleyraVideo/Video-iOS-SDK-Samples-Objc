//
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddressBook;

NS_ASSUME_NONNULL_BEGIN

@interface ContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) AddressBook *addressBook;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
