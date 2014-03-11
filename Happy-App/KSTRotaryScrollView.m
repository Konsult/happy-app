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
#define BUTTON_RAD_INTERVAL DEGREES_TO_RADIANS(30)
#define SET_OPACITY_OFFSET 0.02

@implementation KSTRotaryScrollView

- (id)init
{
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
        
        double theta = -1 * DEGREES_TO_RADIANS(contentOffset.y) + BUTTON_RAD_INTERVAL * i;

        if (theta >= SET_OPACITY_OFFSET && theta <= M_PI + SET_OPACITY_OFFSET) {
            [button.layer setOpacity:1];
        } else  if (theta < SET_OPACITY_OFFSET) {
            [button.layer setOpacity:(1 + theta)];
        } else {
            [button.layer setOpacity:(1 - (theta - M_PI))];
        }
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformRotate(transform, theta);
        transform = CGAffineTransformTranslate(transform, 0, -CIRCLE_RADIUS);
        transform = CGAffineTransformRotate(transform, -theta);
        
        [button setTransform:transform];
    }
    
    otherContentOffset = contentOffset;
}

@end
