//
//  KSTViewController.m
//  Happy-App
//
//  Created by Greg on 2/10/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTViewController.h"

#import "KSTHappyTypeButton.h"

@interface KSTViewController (Private)

@end

@implementation KSTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self getAndShowDate];
    [self initPanRecognizer];
    // add circle for debug
    circleView = [[UIView alloc] initWithFrame:CGRectMake(-157, 140, 400, 400)];
    circleView.alpha = 0.5;
    circleView.layer.cornerRadius = 200;
    circleView.backgroundColor = [UIColor darkGrayColor];
//    [happyItemsContainerView addSubview:circleView];

    [self loadHappyItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"selected"] && [object isKindOfClass:[KSTHappyTypeButton class]]) {
        [self updateAndSaveHappyItem:object];
    }
}

#pragma mark Helper methods
- (IBAction)initPanRecognizer
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideViewWithPan:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panRecognizer];
}

- (void)getAndShowDate
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:systemTimeZone];
    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
    NSString *dateString = [dateFormatter stringFromDate:today];
    [dateLabel setText:dateString];
}

-(void)loadHappyItems
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDir stringByAppendingPathComponent:@"HappyItems.plist"];
    happyItemsPlistPath = plistPath;

    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:plistPath]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"HappyItems" ofType:@"plist"];

        [fileManager copyItemAtPath:bundle toPath:plistPath error:&error];
    }

    NSMutableArray *happyItemsArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
    happyItems = happyItemsArray;

    NSLog(@"Init with happy items: %@", happyItems);

    [self performSelector:@selector(showHappyItems) withObject:self afterDelay:0.6];
//    [self showHappyItems];
}

-(void)showHappyItems
{
    for (int i = 0; i <= happyItems.count; i++) {
        NSDictionary *happyItem;

        if (i == happyItems.count) {
            happyItem = [[NSDictionary alloc] initWithObjectsAndKeys:@"Add",@"title",@"ButtonAdd",@"imageRef", nil];
        } else {
            happyItem = [happyItems objectAtIndex:i];
        }
        
        KSTHappyTypeButton *happyItemButton = [[KSTHappyTypeButton alloc]
                                               initWithTitle:happyItem[@"title"]
                                               andImageName:happyItem[@"imageRef"]];
        
        [happyItemButton setTag:i];

        [happyItemButton addObserver:self forKeyPath:@"selected" options:0 context:nil];
        CGRect frame = happyItemButton.frame;
        frame.origin = CGPointMake(-150, (200 + (i * 55)));
        happyItemButton.frame = frame;

        [happyItemsContainerView addSubview:happyItemButton];

        [self rotateButton:happyItemButton];
    }
}

-(void)updateAndSaveHappyItem:(KSTHappyTypeButton *)button
{
    NSMutableDictionary *happyItem = [happyItems objectAtIndex:[button tag]];
    int change = button.selected ? 1 : -1;
    NSNumber *newHappyValue = [NSNumber numberWithInt:[happyItem[@"value"] intValue] + change];
    happyItem[@"value"] = newHappyValue;

    NSLog(@"Updated happy item: %@", happyItem);

    [happyItems writeToFile:happyItemsPlistPath atomically:YES];
}

#define SCREEN_WIDTH 320
#define MAIN_WIDTH 640
#define MAIN_HEIGHT 568
#define BG_WIDTH 600
#define SLIDE_THRESHOLD 80
#define VELOCITY_THRESHOLD 750

-(void)showAddView:(UIButton*)button
{
//    NSData *archivedButton = [NSKeyedArchiver archivedDataWithRootObject:button];
//    UIButton *newButton = [NSKeyedUnarchiver unarchiveObjectWithData:archivedButton];

    NSLog(@"center after (%f, %f)", button.center.x, button.center.y);
    [UIView animateWithDuration:0.5f delay:0.1f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [bgBlurView setCenter:CGPointMake((-BG_WIDTH/2) + 321, MAIN_HEIGHT/2)];
        [containerView setCenter:CGPointMake(MAIN_WIDTH/2, 110)];
    } completion:^(BOOL finished){
        NSLog(@"center after (%f, %f)", button.center.x, button.center.y);
//        [button removeFromSuperview];
//        [button setCenter:CGPointMake(<#CGFloat x#>, <#CGFloat y#>)]
//        [addItemView addSubview:button];
        
//        [UIView animateWithDuration:0.5f delay:0.1f options:UIViewAnimationOptionCurveEaseOut animations:^{
//            [containerView setFrame:CGRectMake(0, -MAIN_HEIGHT, MAIN_WIDTH, MAIN_HEIGHT)];
//        } completion:NULL];
    }];
}

- (void)slideViewWithPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if (translation.x < 0) {
        [bgImageView setFrame:CGRectMake(MAX(bgImageView.frame.origin.x + translation.x, (-BG_WIDTH + 320)), 0, BG_WIDTH, MAIN_HEIGHT)];
        [bgBlurView setFrame:CGRectMake(MAX(bgBlurView.frame.origin.x + translation.x * 1.5, (-BG_WIDTH + 320)), 0, BG_WIDTH, MAIN_HEIGHT)];
        [containerView setFrame:CGRectMake(MAX(containerView.frame.origin.x + (translation.x * 2), (-MAIN_WIDTH / 2)), 0, MAIN_WIDTH, MAIN_HEIGHT)];
    } else if (translation.x > 0) {
        [bgImageView setFrame:CGRectMake(MIN(bgImageView.frame.origin.x + translation.x * 1.75, 0), 0, BG_WIDTH, MAIN_HEIGHT)];
        [bgBlurView setFrame:CGRectMake(MIN(bgBlurView.frame.origin.x + translation.x * 1.75, 0), 0, BG_WIDTH, MAIN_HEIGHT)];
        [containerView setFrame:CGRectMake(MIN(containerView.frame.origin.x + translation.x * 2, 0), 0, MAIN_WIDTH, MAIN_HEIGHT)];
    }

    // reset translation to 0 for next move
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];

    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        // slide left ended
        if (velocity.x < 0) {
            if (containerView.frame.origin.x < -SLIDE_THRESHOLD || velocity.x < -VELOCITY_THRESHOLD) {
                [UIView animateWithDuration:0.5f animations:^{
                    [bgImageView setFrame:CGRectMake((-BG_WIDTH + 320), 0, BG_WIDTH, MAIN_HEIGHT)];
                    [bgBlurView setFrame:CGRectMake((-BG_WIDTH + 320), 0, BG_WIDTH, MAIN_HEIGHT)];
                    [containerView setFrame:CGRectMake(-SCREEN_WIDTH, 0, MAIN_WIDTH, MAIN_HEIGHT)];
                } completion:^(BOOL finished) {
                    [self showHappyItemStats];
                }];
            } else {
                [UIView animateWithDuration:0.1f animations:^{
                    [bgImageView setFrame:CGRectMake(0, 0, BG_WIDTH, MAIN_HEIGHT)];
                    [bgBlurView setFrame:CGRectMake(0, 0, BG_WIDTH, MAIN_HEIGHT)];
                    [containerView setFrame:CGRectMake(0, 0, MAIN_WIDTH, MAIN_HEIGHT)];
                }];
            }
        // slide right ended
        } else if (velocity.x > 0) {
            if (containerView.frame.origin.x > (-SCREEN_WIDTH + SLIDE_THRESHOLD) || velocity.x > 1000) {
                [UIView animateWithDuration:0.3f animations:^{
                    [bgImageView setFrame:CGRectMake(0, 0, BG_WIDTH, MAIN_HEIGHT)];
                    [bgBlurView setFrame:CGRectMake(0, 0, BG_WIDTH, MAIN_HEIGHT)];
                    [containerView setFrame:CGRectMake(0, 0, MAIN_WIDTH, MAIN_HEIGHT)];
                } completion:^(BOOL finished) {
                    [[graphScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }];
            } else {
                [UIView animateWithDuration:0.1f animations:^{
                    [bgImageView setFrame:CGRectMake((-BG_WIDTH + 320), 0, MAIN_WIDTH, MAIN_HEIGHT)];
                    [bgBlurView setFrame:CGRectMake((-BG_WIDTH + 320), 0, MAIN_WIDTH, MAIN_HEIGHT)];
                    [containerView setFrame:CGRectMake(-SCREEN_WIDTH, 0, MAIN_WIDTH, MAIN_HEIGHT)];
                }];
            }
        }
    }
}

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define CIRCLE_RADIUS 185

- (void)rotateButton:(UIButton *)button
{
    CGPoint endPoint = CGPointMake((circleView.center.x + 30 + CIRCLE_RADIUS * cos(DEGREES_TO_RADIANS(270 + ([button tag] * 30)))), (circleView.center.y + CIRCLE_RADIUS * sin(DEGREES_TO_RADIANS(270 + ([button tag] * 30)))));
    endAnimationPoint = endPoint;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, circleView.center.x + 30, circleView.center.y, CIRCLE_RADIUS, DEGREES_TO_RADIANS(140), DEGREES_TO_RADIANS(270 + ([button tag] * 30)), YES);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);

    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];

    pathAnimation.removedOnCompletion = NO;
    pathAnimation.path = path;
    [pathAnimation setCalculationMode:kCAAnimationCubicPaced];
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.2 :0.8 :0.5 :0.9]];
    [pathAnimation setFillMode:kCAFillModeForwards];
    pathAnimation.duration = 0.8;
    pathAnimation.beginTime = CACurrentMediaTime() + ([button tag] * 0.1);

    [pathAnimation setDelegate:self];
    
    CGPathRelease(path);

    [button.layer addAnimation:pathAnimation forKey:nil];
    NSDictionary *buttonDic = [[NSDictionary alloc] initWithObjectsAndKeys:button,@"view",[NSValue valueWithCGPoint:endPoint],@"point",nil];
    [self performSelector:@selector(setButtonCenter:) withObject:buttonDic afterDelay: 0.8f];
}

- (void)setButtonCenter:(id)button
{
    [button[@"view"] setCenter:[button[@"point"] CGPointValue]];
}

- (void)showHappyItemStats
{
    if (graphScrollView.subviews.count > 1) {
        return;
    }

    graphScrollView.contentSize = CGSizeMake((happyItems.count * 64), 470);
    
    NSMutableArray *barViewsToAnimate = [[NSMutableArray alloc] init];
    NSMutableArray *rectViewsToAnimate = [[NSMutableArray alloc] init];
  
    for (int i = (int)happyItems.count - 1; i >= 0; i--) {
        NSDictionary *happyItem = [happyItems objectAtIndex:i];
        UIView *happyItemBarView = [[UIView alloc] initWithFrame:CGRectMake(-75, 0, 75, 450)];
        
        UILabel *happyItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 410, 50, 40)];
        [happyItemLabel setText:happyItem[@"title"]];
        [happyItemLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0]];
        [happyItemLabel setLineBreakMode:NSLineBreakByWordWrapping];
        happyItemLabel.numberOfLines = 0;
        happyItemLabel.textAlignment = NSTextAlignmentCenter;
        [happyItemLabel setTextColor:[UIColor whiteColor]];
        [happyItemLabel setTintColor:[UIColor clearColor]];
        
        [happyItemBarView addSubview:happyItemLabel];
        
        UIView *rectangle = [[UIView alloc] initWithFrame:CGRectMake(14, 360, 50, 0)];
        [rectangle setBackgroundColor:[UIColor whiteColor]];
        rectangle.alpha = 0.70;

        [happyItemBarView addSubview:rectangle];
        
        UIImage *circleIcon = [UIImage imageNamed:happyItem[@"imageRef"]];
        UIImageView *circleIconView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 360, 50, 50)];
        [circleIconView setImage:circleIcon];
        
        [happyItemBarView addSubview:circleIconView];
        
        UIImage *graphBarBottom = [UIImage imageNamed:@"GraphBarBottom"];
        UIImageView *graphBarBottomView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 360, 50, 25)];
        [graphBarBottomView setImage:graphBarBottom];
        [happyItemBarView addSubview:graphBarBottomView];

        [graphScrollView addSubview:happyItemBarView];
        
        [barViewsToAnimate addObject:happyItemBarView];

        NSNumber *value = happyItem[@"value"];
        [rectViewsToAnimate addObject:[NSDictionary dictionaryWithObjectsAndKeys:rectangle, @"view", value, @"value", nil]];
    }
    
    for (int j = barViewsToAnimate.count - 1; j >= 0; --j) {
        UIView *barView = [barViewsToAnimate objectAtIndex:j];
        CGPoint center = CGPointMake(j * 64 + 25, barView.center.y);
        NSNumber *last = [NSNumber numberWithBool:NO];
        if (j == 0) {
            last = [NSNumber numberWithBool:YES];
        }
        NSDictionary *barViewObject = [[NSDictionary alloc] initWithObjectsAndKeys:barView, @"view", [NSValue valueWithCGPoint:center], @"center", last, @"last", nil];
        
        [self performSelector:@selector(slideInBarIcon:) withObject:barViewObject afterDelay:abs((j - barViewsToAnimate.count)) * 0.2f];
    }
    
    [self performSelector:@selector(slideBarGraphsUp:) withObject:rectViewsToAnimate afterDelay:1.5f];
}

- (void)slideInBarIcon:(NSDictionary *)barViewObject
{
    [UIView animateWithDuration:0.8f delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [barViewObject[@"view"] setCenter:[barViewObject[@"center"] CGPointValue]];
    } completion:NULL];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"animation stopped: %@", anim);
}

- (int)findMaxHappyValue:(NSArray *)items
{
    int max = 0;
    
    for (int i = 0; i < items.count; i++) {
        NSDictionary *item = [items objectAtIndex:i];
        if ([item[@"value"] intValue] > max) {
            max = [item[@"value"] intValue];
        }
    }
    
    return max;
}

- (void)slideBarGraphsUp:(NSMutableArray *)bars
{
    int max = [self findMaxHappyValue:happyItems];
    for (int i = 0; i < bars.count; i++) {
        NSDictionary *barObj = [bars objectAtIndex:i];
        NSInteger value = [barObj[@"value"] integerValue];
        
        [self animateHappyBarGraph:barObj[@"view"] value:value max:max];
    }
}

- (void)animateHappyBarGraph:(UIView *)rectangle value:(int)value max:(int)max
{
    CGRect frame = rectangle.frame;
    float height = 360 * ((float)value / (float)max);
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
    [valueLabel setText:[NSString stringWithFormat:@"%d", value]];
    [valueLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24.0]];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [valueLabel setTextColor:labelColor];
    valueLabel.alpha = 0.8;

    [UIView animateWithDuration:0.8 delay:0.25 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [rectangle setFrame:frame];
    } completion:^(BOOL finished){
        [rectangle addSubview:valueLabel];
    }];
}

@end
