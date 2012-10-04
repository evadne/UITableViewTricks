//
//  BBTableView.h
//  CircleView
//
//  Created by Bhagya on 9/11/12.
//  Copyright (c) 2012 Integral Development Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
	BBTableViewExtrusionRight = 1,
	BBTableViewExtrusionLeft = 0
}; typedef NSUInteger BBTableViewExtrusionDirection;

@interface BBTableView : UITableView

@property (nonatomic, readwrite, assign) CGFloat distanceRatio;
@property (nonatomic, readwrite, assign) BBTableViewExtrusionDirection extrusionDirection;

@end

extern CGFloat BBTableViewLandscapeDistanceRatio;
extern CGFloat BBTableViewPortraitDistanceRatio;
