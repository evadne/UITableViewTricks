//
//  BBTableView.m
//  CircleView
//
//  Created by Bhagya on 9/11/12.
//  Copyright (c) 2012 Integral Development Corporation. All rights reserved.
//

#import <objc/runtime.h>
#import "BBTableView.h"
#import "BBTableViewInterceptor.h"

CGFloat BBTableViewLandscapeDistanceRatio = 1.2f;
CGFloat BBTableViewPortraitDistanceRatio = 0.8f;

@interface BBTableView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, readonly, strong) BBTableViewInterceptor *dataSourceInterceptor;

- (id<UITableViewDataSource>) superDataSource;
- (BOOL) isMaskingCustomDataSourceHackery;
- (void) beginMaskingCustomDataSourceHackery;
- (void) endMaskingCustomDataSourceHackery;
@property (nonatomic, readwrite, assign) NSUInteger dataSourceOverridingCount;

@end

@implementation BBTableView
@synthesize distanceRatio = _distanceRatio;
@synthesize extrusionDirection = _extrusionDirection;
@synthesize dataSourceInterceptor = _dataSourceInterceptor;
@synthesize dataSourceOverridingCount = _dataSourceOverridingCount;

- (id) initWithFrame:(CGRect)frame style:(UITableViewStyle)style {

	self = [super initWithFrame:frame style:style];
	if (!self)
		return nil;
	
	[self commonInit];
	
	return self;

}

- (id) initWithCoder:(NSCoder *)aDecoder {

	self = [super initWithCoder:aDecoder];
	if (!self)
		return nil;
	
	[self commonInit];
	
	return self;

}

- (void) commonInit {

	_distanceRatio = BBTableViewLandscapeDistanceRatio;
	_extrusionDirection = BBTableViewExtrusionRight;
	
	[self dataSourceInterceptor];

}

- (BBTableViewInterceptor *) dataSourceInterceptor {

	if (!_dataSourceInterceptor) {
	
		_dataSourceInterceptor = [BBTableViewInterceptor new];
		_dataSourceInterceptor.middleMan = self;
	
		[super setDataSource:(id<UITableViewDataSource>)_dataSourceInterceptor];
	
	}
	
	return _dataSourceInterceptor;

}

- (id<UITableViewDataSource>) superDataSource {

	return [super dataSource];

}

- (id<UITableViewDataSource>) dataSource {

	if ([self isMaskingCustomDataSourceHackery])
		return self;
	
	return _dataSourceInterceptor.receiver;

}

- (BOOL) isMaskingCustomDataSourceHackery {

	NSCParameterAssert([NSThread isMainThread]);
	
	return !!_dataSourceOverridingCount;

}
- (void) beginMaskingCustomDataSourceHackery {

	NSCParameterAssert([NSThread isMainThread]);
	
	_dataSourceOverridingCount++;

}
- (void) endMaskingCustomDataSourceHackery {

	NSCParameterAssert([NSThread isMainThread]);
	NSCParameterAssert(_dataSourceOverridingCount);
	
	_dataSourceOverridingCount--;
	
}

- (void) setDataSource:(id<UITableViewDataSource>)dataSource {

	if (_dataSourceInterceptor.receiver != dataSource)
		[super setDataSource:nil];
	
	_dataSourceInterceptor.receiver = dataSource;
	
	if ([super dataSource] != _dataSourceInterceptor)
		[super setDataSource:(id<UITableViewDataSource>)_dataSourceInterceptor];
	
}

- (void) setDistanceRatio:(CGFloat)distanceRatio {
	
	if (distanceRatio == _distanceRatio)
		return;
	
	_distanceRatio = distanceRatio;
	
	[self setNeedsLayout];

}

- (void) setExtrusionDirection:(BBTableViewExtrusionDirection)extrusionDirection {

	if (extrusionDirection == _extrusionDirection)
		return;
	
	_extrusionDirection = extrusionDirection;
	
	[self setNeedsLayout];

}

- (void) layoutSubviews {
	
	NSCParameterAssert(![self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]);
	
	NSUInteger mTotalCellsVisible = CGRectGetHeight(self.frame) / self.rowHeight;
	
	[self adjustContentOffsetWithOptions:@{
		@"numberOfRows": @(mTotalCellsVisible)
	}];
	
	[self beginMaskingCustomDataSourceHackery];
	[super layoutSubviews];
	[self endMaskingCustomDataSourceHackery];
	
	[self adjustVisibleCellsWithOptions:@{
		@"numberOfRows": @(mTotalCellsVisible)
	}];
	
}

- (void) reloadData {

	[self beginMaskingCustomDataSourceHackery];
	[super reloadData];
	[self endMaskingCustomDataSourceHackery];

}

- (void) adjustContentOffsetWithOptions:(NSDictionary *)options {

	NSUInteger numberOfRows = [[options objectForKey:@"numberOfRows"] unsignedIntegerValue];
	NSArray *indexPathsForVisibleRows = [self indexPathsForVisibleRows];
	NSUInteger numberOfVisibleCellIndexPaths =[indexPathsForVisibleRows count];
	
	//	If we dont have enough content to generate scroll
	if (numberOfRows > numberOfVisibleCellIndexPaths)
		return;

	//	check the top condition
	//	check if the scroll view reached its top.. if so.. move it to center.. remember center is the start of the data repeating for 2nd time.
		
	CGFloat unitHeight = self.contentSize.height / 3.0f;
	if (unitHeight) {
	
		[self setContentOffset:(CGPoint){
			self.contentOffset.x,
			fmodf(unitHeight + self.contentOffset.y, unitHeight)
		}];
	
	}
	
}

- (void) adjustVisibleCellsWithOptions:(NSDictionary *)options {

	//	Iterate through all visible cells and lay them in a circular shape
	
	NSUInteger numberOfRows = [[options objectForKey:@"numberOfRows"] unsignedIntegerValue];
	NSArray *visibleIndexPaths = [self indexPathsForVisibleRows];
	NSUInteger numberOfVisibleCells = [visibleIndexPaths count];

	CGFloat shift = ((int)self.contentOffset.y % (int)self.rowHeight);
	CGFloat angleGap = M_PI / ( numberOfRows + 1);
	CGFloat percentage_visible = shift / self.rowHeight;
	CGFloat radius = CGRectGetHeight(self.frame) / 2.0f;
	CGFloat xRadius = radius * 2.0f / 3.0f;
  
	for (NSUInteger index = 0; index < numberOfVisibleCells; index++) {
		
		UITableViewCell *cell = [self cellForRowAtIndexPath:[visibleIndexPaths objectAtIndex:index]];
		CGRect cellFrame = cell.frame;
    
		//	We can find the x Point by finding the Angle from the Ellipse Equation of finding y
		//	i.e. Y= vertical_radius * sin(t )
		//	t = asin(Y/vertical_radius) or asin = sin inverse
		
		CGFloat angle = (index + 1) * angleGap - (percentage_visible * angleGap);
		switch (_extrusionDirection) {
			case BBTableViewExtrusionLeft: {
				angle += M_PI_2;
				break;
			}
			case BBTableViewExtrusionRight: {
				angle -= M_PI_2;
				break;
			}
			default: {
				NSCParameterAssert(NO);
				break;
			}
		}
				
		//	Apply Angle in X point of Ellipse equation
		//	i.e. X = horizontal_radius * cos( t )
		//	here horizontal_radius would be some percentage off the vertical radius. percentage is defined by BBTableViewLandscapeDistanceRatio; 1.0f is equal to circle
		
		float x = (floorf(xRadius * _distanceRatio)) * cosf(angle);
    
		//	Assuming, you have laid your tableview so that the entire frame is visible
		//	TO DISPLAY RIGHT: then to display the circle towards right move the cellX (var x here) by half the width towards the right
		//	TO DISPLAY LEFT : move the cellX by quarter the radius
		//	FEEL FREE to play with x to allign the circle as per your needs
				
		switch (_extrusionDirection) {
			case BBTableViewExtrusionLeft: {
				x = x + self.frame.size.width/2;// we have to shift the center of the circle toward the right
				break;
			}
			case BBTableViewExtrusionRight: {
				x = x - self.frame.size.width/2;//HORIZONTAL_TRANSLATION;
				break;
			}
			default: {
				NSCParameterAssert(NO);
				break;
			}
		}
    
		if (isfinite(x) && !isnan(x)) {
			cellFrame.origin.x = x;
			cell.frame = cellFrame;
		}
	
	}
	
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	id<UITableViewDataSource> dataSource = _dataSourceInterceptor.receiver;
	NSInteger answer = [dataSource tableView:tableView numberOfRowsInSection:section];
	
	return answer * 3;

}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	id<UITableViewDataSource> dataSource = _dataSourceInterceptor.receiver;
	
	NSUInteger section = indexPath.section;
	NSUInteger numberOfRows = [dataSource tableView:tableView numberOfRowsInSection:section];
	NSUInteger row = indexPath.row % numberOfRows;

	NSIndexPath *fitIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
	UITableViewCell *cell = [dataSource tableView:tableView cellForRowAtIndexPath:fitIndexPath];
	
	return cell;

}

@end
