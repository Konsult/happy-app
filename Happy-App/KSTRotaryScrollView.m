//
//  KSTRotaryScrollView.m
//  Happy-App
//
//  Created by Greg on 3/3/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTRotaryScrollView.h"
#import "KSTHappyTypeButton.h"

// Rotation helper functions
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define X_POINT_ON_CIRCLE(centerX, radius, angle) centerX + radius * cos(angle)
#define Y_POINT_ON_CIRCLE(centerY, radius, angle) centerY + radius * sin(angle)
#define ANGLE_BETWEEN_XAXIS_AND_POINT(y, x) atan2(y, x)

// Rotation properties (editable)
#define MULTIPLIER_BASE_ANGLE DEGREES_TO_RADIANS(25)
#define MULTIPLER_COEFFICIENT 0.075f
#define HIDING_ANGLE_THRESHOLD 1

// Enter/exit gradient properties (editable)
#define ENDPOINT_X 1.0f
#define START_ALPHA 1.0f
#define END_ALPHA 1.0f

// Circle properties
#define CIRCLE_RADIUS 185.0
#define CIRCLE_CENTER_X 75.0
#define CIRCLE_CENTER_Y 340.0
#define BUTTON_RAD_INTERVAL DEGREES_TO_RADIANS(30)

@implementation KSTRotaryScrollView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];

    if (!self)
        return nil;

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _scrollView.maximumZoomScale = 1;
    _scrollView.minimumZoomScale = 1;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.alwaysBounceHorizontal = NO;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.bouncesZoom = NO;
    
    _scrollView.delegate = self;
    
    [self addSubview:_scrollView];
    
    CAGradientLayer *fadingMask = [CAGradientLayer layer];
    fadingMask.frame = self.frame;
    fadingMask.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0f alpha:START_ALPHA].CGColor, (id)[UIColor colorWithWhite:1.0f alpha:END_ALPHA].CGColor, nil];
    fadingMask.startPoint = CGPointMake(0.0f, 1.0f);
    fadingMask.endPoint = CGPointMake(ENDPOINT_X, 1.0f);
    self.layer.mask = fadingMask;

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    assert(@"Do not call initWithFrame, use init instead." == nil);
    return nil;
}

- (void)setScrollViewContentSizeBasedOnSubviewCount:(int)count viewableCount:(int)viewableCount andSizeInterval:(float)interval
{
    [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height + ((count - (viewableCount - 1)) * interval))];
    
    [self bringSubviewToFront:_scrollView];
}

- (void)setScrollViewContentOffset:(CGPoint)contentOffset
{
    [_scrollView setContentOffset:contentOffset];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset
{
    [_scrollView setContentInset:contentInset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = _scrollView.contentOffset;

    for (int i = 1; i < self.subviews.count; i++) {
        UIView *view = self.subviews[i];
        
        // Subtract i by 1 to make it 0-indexed for calculations
        float evenlySpacedAngle = -1 * DEGREES_TO_RADIANS(contentOffset.y * 0.5f) + (i - 1) * BUTTON_RAD_INTERVAL;
        
        // Need to calcualte a displayAngle (different from evenlySpacedAngle) to prevent buttons' text from overlapping
        float displayAngle = [self calculateDisplayAngleBasedOnEvenlySpacedAngle:evenlySpacedAngle AndOffsetOriginAngle:MULTIPLIER_BASE_ANGLE AndMultipler:MULTIPLER_COEFFICIENT];
        
        if (displayAngle >= -HIDING_ANGLE_THRESHOLD && displayAngle <= M_PI + HIDING_ANGLE_THRESHOLD) {
            [view.layer setOpacity:1];
        } else {
            [view.layer setOpacity:0];
        }
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformRotate(transform, displayAngle);
        transform = CGAffineTransformTranslate(transform, 0, -CIRCLE_RADIUS);
        transform = CGAffineTransformRotate(transform, -displayAngle);
        
        [view setTransform:transform];
    }
    
}

- (float)calculateDisplayAngleBasedOnEvenlySpacedAngle:(float)evenlySpacedAngle AndOffsetOriginAngle:(float)offsetOriginAngle AndMultipler:(float)multiplier
{
    // The offsetOriginAngle mirrored over the horizontal axis
    float inverseOffsetOriginAngle = M_PI - offsetOriginAngle;
    
    // The normalized distance from PI/2
    float distanceFromPI_2N = (M_PI_2 - evenlySpacedAngle) / M_PI_2;
    
    // The normaled distance from the base angle
    float distanceFromOffsetOriginAngle = evenlySpacedAngle > M_PI_2 ? (evenlySpacedAngle - inverseOffsetOriginAngle) / offsetOriginAngle : (offsetOriginAngle - evenlySpacedAngle) / offsetOriginAngle;

    // The final display angle difference from PI/2 normalized
    float displayAngleFromPI_2N = (1 + multiplier * distanceFromOffsetOriginAngle) * distanceFromPI_2N;
    
    // The final display angle denormalized
    float displayAngleFromPI_2 = displayAngleFromPI_2N * M_PI_2;
    
    // The final display angle with respect to vertical origin
    float displayAngle = M_PI_2 - displayAngleFromPI_2;
    
    return displayAngle;
}

@end
