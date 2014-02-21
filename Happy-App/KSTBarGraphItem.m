//
//  KSTBarGraphItem.m
//  Happy-App
//
//  Created by Greg on 2/20/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTBarGraphItem.h"


#define BAR_WIDTH 50
#define BAR_HEIGHT 450
#define LABEL_HEIGHT 40
#define ICON_HEIGHT_WIDTH 50

@implementation KSTBarGraphItem

- (id)initWithFrame:(CGRect)frame
{
    assert(@"Do not call initWithFrame, use initWithTitle:andImageName: intead." == nil);
    return nil;
}

- (id)initWithTitle:(NSString *)title andImageName:(NSString *)imageName andValue:(NSNumber *)barValue
{
    self = [super initWithFrame:CGRectMake(-BAR_WIDTH, 0, BAR_WIDTH, BAR_HEIGHT)];
    if (!self) {
        return nil;
    }
    
    value = barValue;
    
    UILabel *happyItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, BAR_HEIGHT - LABEL_HEIGHT, BAR_WIDTH, LABEL_HEIGHT)];
    [happyItemLabel setText:title];
    [happyItemLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0]];
    [happyItemLabel setLineBreakMode:NSLineBreakByWordWrapping];
    happyItemLabel.numberOfLines = 0;
    happyItemLabel.textAlignment = NSTextAlignmentCenter;
    [happyItemLabel setTextColor:[UIColor whiteColor]];
    
    [self addSubview:happyItemLabel];
    
    UIImage *circleIcon = [UIImage imageNamed:imageName];
    UIImageView *circleIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, BAR_HEIGHT - LABEL_HEIGHT - ICON_HEIGHT_WIDTH, ICON_HEIGHT_WIDTH, ICON_HEIGHT_WIDTH)];
    [circleIconView setImage:circleIcon];
    
    [self addSubview:circleIconView];
    
    return self;
}

- (void)slideInBarToCenterPoint:(NSValue *)centerPointValue
{
    CGPoint center = [centerPointValue CGPointValue];
    
    [UIView animateWithDuration:0.8f delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setCenter:center];
    } completion:NULL];
}

- (void)animateBarWithMax:(NSNumber *)maxValue
{
    int max = [maxValue integerValue];
    
    UIView *rectangle = [[UIView alloc] initWithFrame:CGRectMake(0, BAR_HEIGHT - LABEL_HEIGHT - ICON_HEIGHT_WIDTH, BAR_WIDTH, 0)];
    [rectangle setBackgroundColor:[UIColor whiteColor]];
    rectangle.alpha = 0.70;
    
    [self addSubview:rectangle];
    
    UIImage *graphBarBottom = [UIImage imageNamed:@"GraphBarBottom"];
    UIImageView *graphBarBottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, BAR_HEIGHT - LABEL_HEIGHT - ICON_HEIGHT_WIDTH, ICON_HEIGHT_WIDTH, ICON_HEIGHT_WIDTH / 2)];
    [graphBarBottomView setImage:graphBarBottom];
    
    CGRect frame = rectangle.frame;
    float height = 360 * ([value floatValue] / (float)max);
    if (height > 0) {
        frame.size.height = height;
        frame.origin.y = 360 - height;
    }
    
    CGRect labelRect = CGRectMake(0, 0, 50, 30);
    UIColor *labelColor = [UIColor blackColor];
    if (height < 30) {
        labelRect.origin.y = -30;
        labelColor = [UIColor whiteColor];
    }
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:labelRect];
    [valueLabel setText:[NSString stringWithFormat:@"%@", value]];
    [valueLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24.0]];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [valueLabel setTextColor:labelColor];
    valueLabel.alpha = 0.8;
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self addSubview:graphBarBottomView];
        [rectangle setFrame:frame];
    } completion:^(BOOL finished){
        [rectangle addSubview:valueLabel];
    }];
}

@end
