
/*******************************************************
 * Copyright (C) 2011-2012 Converser contact@converser.io
 *
 * This file is part of the Converser iOS SDK.
 *
 * This code may not be copied and/or distributed without the express
 * permission of Converser. Please email contact@converser.io for
 * all redistribution and reuse enquiries.
 *******************************************************/

#if !__has_feature(objc_arc)
#error ConverserSDK must be built with ARC.
// You can turn on ARC for only ConverserSDK files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "SwrveConversationResource.h"
#import "SwrveSimpleChoiceTableViewControllerViewController.h"
#import "SwrveSetup.h"

@interface SwrveSimpleChoiceTableViewControllerViewController () {
    NSIndexPath *refreshIndex;
}
@end

@implementation SwrveSimpleChoiceTableViewControllerViewController
@synthesize choiceValues = _choiceValues;

-(void) viewWillAppear:(BOOL)animated {
#pragma unused (animated)
    self.title = self.choiceValues.title;
    if(refreshIndex) {
        [(UITableView *)self.view reloadRowsAtIndexPaths:[NSArray arrayWithObject:refreshIndex] withRowAnimation:UITableViewRowAnimationNone];
        refreshIndex = nil;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        UIImage *img = [SwrveConversationResource imageFromBundleNamed:@"layer_1_background"];
        [(UITableView *)self.view setBackgroundView:[[UIImageView alloc] initWithImage:img]];
    } else {
        // iOS 7 background style
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#pragma unused (tableView)
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#pragma unused (tableView, section)
    return (NSInteger)self.choiceValues.choices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"SwrveSimpleChoiceCell";
    static NSString *CellIdentifierMore = @"SwrveSimpleChoiceMoreCell";
    if(self.choiceValues.hasMore) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierMore];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierMore];
        }
        SwrveChoiceArray *inner = [self.choiceValues.choices objectAtIndex:(NSUInteger)indexPath.row];
        cell.textLabel.text = inner.title;
        cell.detailTextLabel.text = inner.selectedItem;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [self.choiceValues.choices objectAtIndex:(NSUInteger)indexPath.row];
        if(indexPath.row == self.choiceValues.selectedIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.choiceValues.hasMore) {
        SwrveChoiceArray *inner = [self.choiceValues.choices objectAtIndex:(NSUInteger)indexPath.row];
        SwrveSimpleChoiceTableViewControllerViewController *next = [[SwrveSimpleChoiceTableViewControllerViewController alloc] initWithStyle:UITableViewStyleGrouped];
        next.choiceValues = inner;
        [self.navigationController pushViewController:next animated:YES];
        refreshIndex = indexPath;
    } else {
        self.choiceValues.selectedIndex = indexPath.row;
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:(NSUInteger)indexPath.section];
        [tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end