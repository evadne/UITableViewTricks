//
//  BBCell.m
//  CircleView
//
//  Created by Bharath Booshan on 6/8/12.
//  Copyright (c) 2012 Bharath Booshan Inc. All rights reserved.
//

#import "BBCell.h"

@implementation BBCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (!self)
		return nil;
	
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.contentView.backgroundColor = [UIColor clearColor];
	
	mImageLayer =[CALayer layer];
	[self.contentView.layer addSublayer:mImageLayer];

	mImageLayer.actions = nil;
	mImageLayer.cornerRadius = 16.0f;
	mImageLayer.borderWidth = 4.0f;
	mImageLayer.borderColor = [UIColor whiteColor].CGColor;

	mCellTtleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0, 10.0, self.contentView.bounds.size.width - 44.0, 21.0)];
	[self.contentView addSubview:mCellTtleLabel];
	mCellTtleLabel.backgroundColor= [UIColor clearColor];
	mCellTtleLabel.textColor = [UIColor whiteColor];
	mCellTtleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
  
	return self;
	
}

- (void) layoutSubviews {
	
	[super layoutSubviews];
	
	CGFloat const imageY = 4.0;
	CGFloat const heightOfImageLayer = floorf(CGRectGetHeight(self.bounds) - imageY * 2.0);
	
	mImageLayer.cornerRadius = heightOfImageLayer / 2.0f;
	mImageLayer.frame = (CGRect){
		4.0,
		imageY,
		heightOfImageLayer,
		heightOfImageLayer
	};
	
	mCellTtleLabel.frame = (CGRect){
		heightOfImageLayer + 10.0f,
		floorf(heightOfImageLayer / 2.0 - (21/2.0f)) + 4.0,
		CGRectGetWidth(self.contentView.bounds) - heightOfImageLayer + 10.0f,
		21.0f
	};
  
}

- (void) setCellTitle:(NSString*)title {
	
	mCellTtleLabel.text = title;
	
}

- (void) setIcon:(UIImage*)image {
	
	mImageLayer.contents = (id)image.CGImage;
	
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
	if (selected) {
		mImageLayer.borderColor = [UIColor orangeColor].CGColor;
		mCellTtleLabel.textColor = [UIColor orangeColor];
	} else {
		mImageLayer.borderColor = [UIColor whiteColor].CGColor;
		mCellTtleLabel.textColor = [UIColor whiteColor];
	}
	
}

@end
