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
#define OPACITY_ANGLE_OFFSET 1

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

    CAGradientLayer *enterGradient = [CAGradientLayer layer];
    enterGradient.frame = self.frame;
    enterGradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0f alpha:START_ALPHA].CGColor, (id)[UIColor colorWithWhite:1.0f alpha:END_ALPHA].CGColor, nil];
    enterGradient.startPoint = CGPointMake(0.0f, 1.0f);
    enterGradient.endPoint = CGPointMake(ENDPOINT_X, 1.0f);
    self.layer.mask = enterGradient;
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    assert(@"Do not call initWithFrame, use init instead." == nil);
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
        
        double calculatedAngle = -1 * DEGREES_TO_RADIANS(contentOffset.y) + i * BUTTON_RAD_INTERVAL;
        
        double displayAngle = [self calculateDisplayAngleBasedOnCalculatedAngle:calculatedAngle AndMultiplerBaseAngle:MULTIPLIER_BASE_ANGLE AndMultipler:MULTIPLER_COEFFICIENT];

        if (displayAngle >= 0 - OPACITY_ANGLE_OFFSET && displayAngle <= M_PI + OPACITY_ANGLE_OFFSET) {
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
    
    otherContentOffset = contentOffset;
}

- (double)calculateDisplayAngleBasedOnCalculatedAngle:(double)calculatedAngle AndMultiplerBaseAngle:(double)multAngle AndMultipler:(float)multiplier
{
    // The multAngle on horizontally mirrored quandrant of circle
    double inverseOfMultAngle = M_PI - multAngle;
    
    // The normalized distance from PI/2
    double distanceFromPI_2N = (M_PI_2 - calculatedAngle) / M_PI_2;
    
    // The normaled distance from the base angle
    double distanceFromMultAngle = calculatedAngle > M_PI_2 ? (calculatedAngle - inverseOfMultAngle) / multAngle : (multAngle - calculatedAngle) / multAngle;

    // The final display angle difference from PI/2 normalized
    double displayAngleFromPI_2N = (1 + multiplier * distanceFromMultAngle) * distanceFromPI_2N;
    
    // The final display angle denormalized
    double displayAngleFromPI_2 = displayAngleFromPI_2N * M_PI_2;
    
    // The final display angle with respect to vertical origin
    double displayAngle = M_PI_2 - displayAngleFromPI_2;
    
    return displayAngle;
}

@end
