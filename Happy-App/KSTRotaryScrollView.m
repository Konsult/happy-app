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
    self.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.directionalLockEnabled = YES;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.bouncesZoom = NO;
    
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

// To allow the native intertial bouncing, this is a hacky way to set the private contentOffset
- (CGPoint)contentOffset
{
    return linearContentOffset;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    for (int i = 0; i < self.subviews.count; i++) {
        UIButton *button = self.subviews[i];
        
        double evenlySpacedAngle = -1 * DEGREES_TO_RADIANS(contentOffset.y) + i * BUTTON_RAD_INTERVAL;
        
        // Need to calcualte a displayAngle (different from evenlySpacedAngle) to prevent buttons' text from overlapping
        double displayAngle = [self calculateDisplayAngleBasedOnEvenlySpacedAngle:evenlySpacedAngle AndOffsetOriginAngle:MULTIPLIER_BASE_ANGLE AndMultipler:MULTIPLER_COEFFICIENT];

        if (displayAngle >= -HIDING_ANGLE_THRESHOLD && displayAngle <= M_PI + HIDING_ANGLE_THRESHOLD) {
            [button.layer setOpacity:1];
        } else {
            [button.layer setOpacity:0];
        }
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformRotate(transform, displayAngle);
        transform = CGAffineTransformTranslate(transform, 0, -CIRCLE_RADIUS);
        transform = CGAffineTransformRotate(transform, -displayAngle);
        
        [button setTransform:transform];
    }
    
    linearContentOffset = contentOffset;
}

- (double)calculateDisplayAngleBasedOnEvenlySpacedAngle:(double)evenlySpacedAngle AndOffsetOriginAngle:(double)offsetOriginAngle AndMultipler:(float)multiplier
{
    // The multAngle mirrored over the horizontal axis
    double inverseOfMultAngle = M_PI - offsetOriginAngle;
    
    // The normalized distance from PI/2
    double distanceFromPI_2N = (M_PI_2 - evenlySpacedAngle) / M_PI_2;
    
    // The normaled distance from the base angle
    double distanceFromMultAngle = evenlySpacedAngle > M_PI_2 ? (evenlySpacedAngle - inverseOfMultAngle) / offsetOriginAngle : (offsetOriginAngle - evenlySpacedAngle) / offsetOriginAngle;

    // The final display angle difference from PI/2 normalized
    double displayAngleFromPI_2N = (1 + multiplier * distanceFromMultAngle) * distanceFromPI_2N;
    
    // The final display angle denormalized
    double displayAngleFromPI_2 = displayAngleFromPI_2N * M_PI_2;
    
    // The final display angle with respect to vertical origin
    double displayAngle = M_PI_2 - displayAngleFromPI_2;
    
    return displayAngle;
}

@end
