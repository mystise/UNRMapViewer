//
//  UNRMapSelectionView.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRMapSelectionViewController.h"
#import "UNRMapViewerViewController.h"

#import <dispatch/dispatch.h>

@implementation UNRMapSelectionViewController

@synthesize maps = maps_, mapViewController = mapViewController_;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if(self){
		
    }
    return self;
}

- (void)awakeFromNib{
	NSMutableArray *mapNames = [[[NSBundle mainBundle] pathsForResourcesOfType:@"unr" inDirectory:@"Maps"] mutableCopy];
	self.maps = mapNames;
	[mapNames release];
}

- (void)dealloc{
	[maps_ release];
	maps_ = nil;
	[mapViewController_ release];
	mapViewController_ = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.maps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = [[[self.maps objectAtIndex:indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
	UIProgressView *progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	UILabel *label = [[UILabel alloc] init];
	//UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	//activity.contentMode = UIViewContentModeCenter;
	//[alert addSubview:activity];
	[alert addSubview:progress];
	[alert addSubview:label];
	[alert show];
	//[activity startAnimating];
	CGRect alertFrame = alert.bounds;
	//const float actSize = 10.0f;
	const float disp = 10.0f;
	label.frame = CGRectMake(disp, alertFrame.size.height-disp*6.0f, alertFrame.size.width-2*disp, 25.0f);
	label.text = @"Hello...";
	label.opaque = NO;
	label.backgroundColor = [UIColor clearColor];
	//[label setB]
	progress.frame = CGRectMake(disp, alertFrame.size.height-disp*3.0f, alertFrame.size.width-2*disp, disp);
	//activity.frame = CGRectMake(alertFrame.size.width*0.5f-actSize*0.5f, alertFrame.size.height-actSize*5.0f, actSize, actSize);
	
	dispatch_queue_t loadingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, (unsigned long)NULL);
	
	dispatch_block_t loadingBlock = ^(void){
		[self.mapViewController loadMap:[self.maps objectAtIndex:indexPath.row] withLabel:label andBar:progress];
		[self.mapViewController setAnimationFrameInterval:2];
		dispatch_block_t finishBlock = ^(void){
			[self presentModalViewController:self.mapViewController animated:YES];
			[alert dismissWithClickedButtonIndex:0 animated:YES];
			[alert release];
			[progress release];
			//[activity release];
		};
		dispatch_async(dispatch_get_main_queue(), finishBlock);
	};
	
	dispatch_async(loadingQueue, loadingBlock);
}

@end
