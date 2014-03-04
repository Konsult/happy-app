//
//  KSTRotaryScrollView.m
//  Happy-App
//
//  Created by Greg on 3/3/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTRotaryScrollView.h"
#import "KSTHappyTypeButton.h"

#define WINDOW_WIDTH 320.0
#define WINDOW_HEIGHT 568.0
#define SCROLL_WIDTH 320
#define SCROLL_HEIGHT 568
#define BOUNCE_MULTIPLIER 1

// Rotation helper functions
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define X_POINT_ON_CIRCLE(centerX, radius, angle) centerX + radius * cos(angle)
#define Y_POINT_ON_CIRCLE(centerY, radius, angle) centerY + radius * sin(angle)
#define ANGLE_BETWEEN_XAXIS_AND_POINT(y, x) atan2(y, x)

// Rotation properties
#define CIRCLE_RADIUS 185.0
#define CIRCLE_CENTER_X 75.0
#define CIRCLE_CENTER_Y 340.0

@implementation KSTRotaryScrollView

- (id)init
{
    buttonStartPositions = [[NSMutableArray alloc] init];
    
    self = [super initWithFrame:CGRectMake(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)];
    self.contentSize = CGSizeMake(SCROLL_WIDTH, SCROLL_HEIGHT);
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.directionalLockEnabled = YES;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.bouncesZoom = NO;
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    assert(@"Do not call initWithFrame, use init intead." == nil);
    return nil;
}

- (CGPoint)contentOffset
{
    return otherContentOffset;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    for (int i = 0; i < self.subviews.count; i++) {
        UIButton *button = self.subviews[i];
        
        double theta = -1 * DEGREES_TO_RADIANS(contentOffset.y);
        double offset = DEGREES_TO_RADIANS(30);
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformRotate(transform, theta + i * offset);
        transform = CGAffineTransformTranslate(transform, 0, -CIRCLE_RADIUS);
        transform = CGAffineTransformRotate(transform, -1 * theta - i * offset);
        
        [button setTransform:transform];
    }
    
    otherContentOffset = contentOffset;
}

@end
