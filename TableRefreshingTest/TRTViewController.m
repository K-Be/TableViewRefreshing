//
//  TRTViewController.m
//  TableRefreshingTest
//
//  Created by Andrew Romanov on 26.06.14.
//  Copyright (c) 2014 Andrew Romanov. All rights reserved.
//

#import "TRTViewController.h"

#define CLEARING_TIME (2.0)

@interface TRTViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* data;
@property (nonatomic, weak) NSTimer* clearingTimer;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* startClearingButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* refreshButton;

- (IBAction)refreshDataAction:(id)sender;
- (IBAction)startClearingTimerAction:(id)sender;

@end


@interface TRTViewController (Private)

- (void)_startRemoveDatasTimer;
- (void)_refreshData;
- (void)_removeData;

- (NSString*)dataForIndexPath:(NSIndexPath*)indexPath;
- (NSInteger)_indexPathToIndex:(NSIndexPath*)indexPath;

@end



@implementation TRTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.navigationItem.leftBarButtonItem = self.refreshButton;
	self.navigationItem.rightBarButtonItem = self.startClearingButton;
	[self _refreshData];
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.data count];
}


// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* cellUId = @"UITableViewCell";
	UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellUId];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellUId];
	}
	
	cell.textLabel.text = [self dataForIndexPath:indexPath];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.editing = YES;
	
	return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger index = [self _indexPathToIndex:indexPath];
	[self.tableView beginUpdates];
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.data removeObjectAtIndex:index];
	[self.tableView endUpdates];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* string = [self dataForIndexPath:indexPath];
	BOOL canEdit = (string != nil);
	return canEdit;
}


#pragma mark UITableViewDelegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}


#pragma mark Actions
- (IBAction)refreshDataAction:(id)sender
{
	[self _refreshData];
}


- (IBAction)startClearingTimerAction:(id)sender
{
	if (!_clearingTimer)
	{
		UIBarButtonItem* activityItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
		[self.activityIndicator startAnimating];
		self.navigationItem.rightBarButtonItem = activityItem;
		
		[self _startRemoveDatasTimer];
	}
}
@end


#pragma mark -
@implementation TRTViewController (Private)

- (void)_startRemoveDatasTimer
{
	self.clearingTimer = [NSTimer scheduledTimerWithTimeInterval:CLEARING_TIME
																			target:self
																		 selector:@selector(_removeData)
																		 userInfo:nil
																		  repeats:NO];
}


- (void)_refreshData
{
	self.data = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", nil];
	[self.tableView reloadData];
	if (_clearingTimer) {
		[self.clearingTimer invalidate];
		self.clearingTimer = nil;
	}
	self.navigationItem.rightBarButtonItem = self.startClearingButton;
	[self.activityIndicator stopAnimating];
}


- (void)_removeData
{
	self.data = [[NSMutableArray alloc] init];
	[self.tableView reloadData];
	self.navigationItem.rightBarButtonItem = self.startClearingButton;
	[self.activityIndicator stopAnimating];
}


- (NSString*)dataForIndexPath:(NSIndexPath*)indexPath
{
	NSInteger index = [self _indexPathToIndex:indexPath];
	NSString* data = [self.data objectAtIndex:index];
	
	return data;
}


- (NSInteger)_indexPathToIndex:(NSIndexPath*)indexPath
{
	NSInteger index = indexPath.row;
	return index;
}

@end