//
//  BTTalkToViewController.m
//  beaconTest
//
//  Created by Travis Heaver on 1/26/14.
//  Copyright (c) 2014 Travis Heaver. All rights reserved.
//

#import "BTTalkToViewController.h"

@interface BTTalkToViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BTTalkToViewController

-(NSMutableArray *)nearByUsers
{
    if (!_nearByUsers) {
        _nearByUsers = [[NSMutableArray alloc] init];
    }
    return _nearByUsers;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"View did load and nearby users include; %@", self.nearByUsers);
 //   NSLog(@"the first major value is %@", [NSNumber numberWithInt:[self.nearByUsers[0][@"major"] intValue]]);
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self updateNearByUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateNearByUsers
{
    
}

#pragma mark - UItable view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.nearByUsers count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"talkToCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSLog(@"index path row: %li", (long)indexPath.row);
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.nearByUsers[0]] ;
    
    return cell;
}


@end
