//
//  KSTBarGraphItem.m
//  Happy-App
//
//  Created by Greg on 2/20/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTBarGraphItem.h"

#define BAR_WIDTH 50
#define ICON_LABEL_HEIGHT 40
#define ICON_HEIGHT_WIDTH 50
#define ICON_LABEL_FONT_SIZE 12.0f
#define ICON_INTRO_ANIM_DUR 0.8f
#define ICON_INTRO_SPRING 0.8f
#define GRAPH_BAR_BOTTOM_IMG @"GraphBarBottom"
#define GRAPH_LABEL_HEIGHT 30
#define BAR_ANIM_DUR 0.8f
#define BAR_ANIM_SPRING 0.8f
#define BAR_ALPHA 0.7f

@implementation KSTBarGraphItem

- (id)initWithFrame:(CGRect)frame
{
    assert(@"Do not call initWithFrame, use initWithTitle:andImageName: intead." == nil);
    return nil;
}

- (id)initWithHeight:(float)height andTitle:(NSString *)title andImageName:(NSString *)imageName andValue:(NSNumber *)barValue
{
    self = [super initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width + BAR_WIDTH, [UIScreen mainScreen].bounds.size.height - height, BAR_WIDTH, height)];
    if (!self) {
        return nil;
    }
    
    value = barValue;
    
    UILabel *happyItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height - ICON_LABEL_HEIGHT, BAR_WIDTH, ICON_LABEL_HEIGHT)];
    [happyItemLabel setText:title];
    [happyItemLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:ICON_LABEL_FONT_SIZE]];
    [happyItemLabel setLineBreakMode:NSLineBreakByWordWrapping];
    happyItemLabel.numberOfLines = 0;
    happyItemLabel.textAlignment = NSTextAlignmentCenter;
    [happyItemLabel setTextColor:[UIColor whiteColor]];
    
    [self addSubview:happyItemLabel];
    
    UIImage *circleIcon = [UIImage imageNamed:imageName];
    UIImageView *circleIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, height - ICON_LABEL_HEIGHT - ICON_HEIGHT_WIDTH, ICON_HEIGHT_WIDTH, ICON_HEIGHT_WIDTH)];
    [circleIconView setImage:circleIcon];
    
    [self addSubview:circleIconView];
    
    return self;
}

- (void)slideInBarToCenterPoint:(NSValue *)centerPointValue
{
    CGPoint center = [centerPointValue CGPointValue];
    
    UIView *superView = self.superview;
    UIScrollView *scrollView;
    if ([superView isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView *)superView;
    };

    [UIView animateWithDuration:ICON_INTRO_ANIM_DUR delay:0 usingSpringWithDamping:ICON_INTRO_SPRING initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setCenter:center];
        if (scrollView) {
            scrollView.scrollEnabled = NO;
        }
    } completion:^(BOOL finished){
        if (scrollView) {
            scrollView.scrollEnabled = YES;
        }
    }];
}

// Max value is greatest value across all happy items
- (void)animateInBarRelativeToMax:(NSNumber *)maxValue
{
    if ([value intValue] == 0) {
        return;
    }

    int max = [maxValue intValue];
    
    UIView *rectangle = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - ICON_LABEL_HEIGHT - ICON_HEIGHT_WIDTH, BAR_WIDTH, 0)];
    [rectangle setBackgroundColor:[UIColor whiteColor]];
    rectangle.alpha = BAR_ALPHA;
    
    [self addSubview:rectangle];
    
    UIImage *graphBarBottom = [UIImage imageNamed:GRAPH_BAR_BOTTOM_IMG];
    UIImageView *graphBarBottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - ICON_LABEL_HEIGHT - ICON_HEIGHT_WIDTH, ICON_HEIGHT_WIDTH, ICON_HEIGHT_WIDTH / 2)];
    [graphBarBottomView setImage:graphBarBottom];
    
    CGRect frame = rectangle.frame;
    float height = self.frame.size.height - ICON_LABEL_HEIGHT - ICON_HEIGHT_WIDTH * ([value floatValue] / (float)max);
    if (height > 0) {
        frame.size.height = height;
        frame.origin.y = self.frame.size.height - ICON_LABEL_HEIGHT - ICON_HEIGHT_WIDTH - height;
    }
    
    CGRect labelRect = CGRectMake(0, 0, BAR_WIDTH, GRAPH_LABEL_HEIGHT);
    UIColor *labelColor = [UIColor blackColor];
    if (height < GRAPH_LABEL_HEIGHT) {
        labelRect.origin.y = -GRAPH_LABEL_HEIGHT;
        labelColor = [UIColor whiteColor];
    }
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:labelRect];
    [valueLabel setText:[NSString stringWithFormat:@"%@", value]];
    [valueLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:ICON_LABEL_FONT_SIZE * 2]];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [valueLabel setTextColor:labelColor];
    valueLabel.alpha = BAR_ALPHA;
    
    [UIView animateWithDuration:BAR_ANIM_DUR delay:0 usingSpringWithDamping:BAR_ANIM_SPRING initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self addSubview:graphBarBottomView];
        [rectangle setFrame:frame];
    } completion:^(BOOL finished){
        [rectangle addSubview:valueLabel];
    }];
}

@end
