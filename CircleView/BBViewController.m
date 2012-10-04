//
//  BBViewController.m
//  CircleView
//
//  Created by Bharath Booshan on 6/8/12.
//  Copyright (c) 2012 Bharath Booshan Inc. All rights reserved.
//

#import "BBViewController.h"
#import "BBCell.h"
#import <QuartzCore/QuartzCore.h>
#import "BBTableViewInterceptor.h"

//Keys used in the plist file to read the data for the table
#define KEY_TITLE @"title"
#define KEY_IMAGE_NAME @"image_name"
#define KEY_IMAGE @"image"



@interface BBViewController ()
@property (nonatomic, readwrite, strong) NSArray *backingData;
@end

@implementation BBViewController
@synthesize tableView = _tableView;
@synthesize backingData = _backingData;

- (void) viewDidLoad {

	[super viewDidLoad];
	
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.opaque = NO;
	self.tableView.showsHorizontalScrollIndicator = NO;
	self.tableView.showsVerticalScrollIndicator = YES;

	UILabel *titleLabel = (UILabel*) [self.view viewWithTag:100];
	titleLabel.text = @"CRICKET \n LEGENDS";
	
	__weak BBViewController *wSelf = self;
	
	[self loadDataWithCompletion:^(NSArray *data) {
	
		if (!wSelf)
			return;

		wSelf.backingData = data;
		[wSelf.tableView reloadData];

	}];
	
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [self.backingData count];
	
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	//	Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:.
	//	Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

	static NSString *CellIdentifier = @"table";
	BBCell *cell = (BBCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[BBCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	}
	
	NSDictionary *info = [self.backingData objectAtIndex:indexPath.row];
	[cell setCellTitle:[info objectForKey:KEY_TITLE]];
	[cell setIcon:[info objectForKey:KEY_IMAGE]];
  
	return cell;
	
}

- (void) loadDataWithCompletion:(void(^)(NSArray *data))block {

	//	read the data from the plist and alos the image will be masked to form a circular shape
	
	NSMutableArray *dataSource = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];

	NSMutableArray *answer = [[NSMutableArray alloc] init];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

		for (NSDictionary *dataInfo in dataSource) {

			//	generate image clipped in a circle
			
			NSMutableDictionary *info = [dataInfo mutableCopy];

			[info setObject:((^ {

				UIImage *image = [UIImage imageNamed:[info objectForKey:KEY_IMAGE_NAME]];
				UIGraphicsBeginImageContext(image.size);
				CGContextRef ctx = UIGraphicsGetCurrentContext();
				CGAffineTransform trnsfrm = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeScale(1.0, -1.0));
				trnsfrm = CGAffineTransformConcat(trnsfrm, CGAffineTransformMakeTranslation(0.0, image.size.height));
				CGContextConcatCTM(ctx, trnsfrm);
				CGContextBeginPath(ctx);
				CGContextAddEllipseInRect(ctx, CGRectMake(0.0, 0.0, image.size.width, image.size.height));
				CGContextClip(ctx);
				CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
				UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();

				return finalImage;

			})()) forKey:KEY_IMAGE];

			[answer addObject:info];
			
		}

		dispatch_async(dispatch_get_main_queue(), ^{
		
			if (block)
				block(answer);
			
		});
		
	});
		
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
	
		self.tableView.distanceRatio = BBTableViewLandscapeDistanceRatio;
		
	} else {
	
		self.tableView.distanceRatio = BBTableViewPortraitDistanceRatio;
	
	}

}

@end
