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
    circleView = [[UIView alloc] initWithFrame:CGRectMake(-157, 145, 400, 400)];
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
        [happyItemButton addTarget:self action:@selector(updateAndSaveHappyItem:) forControlEvents:UIControlEventTouchUpInside];
        CGRect frame = happyItemButton.frame;
        frame.origin = CGPointMake(-150, (200 + (i * 55)));
        happyItemButton.frame = frame;

        [happyItemsContainerView addSubview:happyItemButton];

        [self rotateButton:happyItemButton];
    }
}

-(void)updateAndSaveHappyItem:(UIButton*)button
{
    NSMutableDictionary *happyItem = [happyItems objectAtIndex:[button tag]];
    NSNumber *newHappyValue = [NSNumber numberWithInt:[happyItem[@"value"] intValue] + 1];
    happyItem[@"value"] = newHappyValue;

    NSLog(@"Updated happy item: %@", happyItem);

    [happyItems writeToFile:happyItemsPlistPath atomically:YES];
}

#define SCREEN_WIDTH 320
#define MAIN_WIDTH 640
#define MAIN_HEIGHT 568
#define BG_WIDTH 600
#define SLIDE_THRESHOLD 150
#define VELOCITY_THRESHOLD 1000

- (void)slideViewWithPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];

    // move views by translation amount
    [bgImageView setFrame:CGRectMake((bgImageView.frame.origin.x + translation.x), 0, BG_WIDTH, MAIN_HEIGHT)];
    [bgBlurView setFrame:CGRectMake((bgImageView.frame.origin.x + translation.x * 1.5), 0, BG_WIDTH, MAIN_HEIGHT)];
    [containerView setFrame:CGRectMake(containerView.frame.origin.x + (translation.x * 2), 0, MAIN_WIDTH, MAIN_HEIGHT)];

    // reset translation to 0 for next move
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];


    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.view];

        // slide left ended
        if (velocity.x < 0) {
            if (bgImageView.frame.origin.x < -SLIDE_THRESHOLD || velocity.x < -VELOCITY_THRESHOLD) {
                [UIView animateWithDuration:0.5f animations:^{
                    [bgImageView setFrame:CGRectMake((-BG_WIDTH + 320), 0, BG_WIDTH, MAIN_HEIGHT)];
                    [bgBlurView setFrame:CGRectMake((-BG_WIDTH + 320), 0, BG_WIDTH, MAIN_HEIGHT)];
                    [containerView setFrame:CGRectMake(-SCREEN_WIDTH, 0, MAIN_WIDTH, MAIN_HEIGHT)];
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
            if (bgImageView.frame.origin.x > (-SCREEN_WIDTH + SLIDE_THRESHOLD) || velocity.x > 1000) {
                [UIView animateWithDuration:0.3f animations:^{
                    [bgImageView setFrame:CGRectMake(0, 0, BG_WIDTH, MAIN_HEIGHT)];
                    [bgBlurView setFrame:CGRectMake(0, 0, BG_WIDTH, MAIN_HEIGHT)];
                    [containerView setFrame:CGRectMake(0, 0, MAIN_WIDTH, MAIN_HEIGHT)];
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
#define CIRCLE_RADIUS 190

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
//    button.center = endPoint;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{

}

- (void)showHappyItemStats
{
    int max = [self findMaxHappyValue:happyItems];

    graphScrollView.contentSize = CGSizeMake((happyItems.count * 64), 470);
  
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
        rectangle.alpha = 0.58;

        [happyItemBarView addSubview:rectangle];
        
        UIImage *circleIcon = [UIImage imageNamed:happyItem[@"imageRef"]];
        UIImageView *circleIconView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 360, 50, 50)];
        [circleIconView setImage:circleIcon];
        
        [happyItemBarView addSubview:circleIconView];
        
        UIImage *graphBarBottom = [UIImage imageNamed:@"GraphBarBottom"];
        UIImageView *graphBarBottomView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 360, 50, 25)];
        [graphBarBottomView setImage:graphBarBottom];
        graphBarBottomView.alpha = 0.8;
        
        [happyItemBarView addSubview:graphBarBottomView];
        
        [UIView animateWithDuration:0.8f delay:(float)i * 0.2f usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [graphScrollView addSubview:happyItemBarView];
            [happyItemBarView setFrame:CGRectMake((i * 64), 0, 75, 450)];
        } completion:^(BOOL finished){
            if (finished == YES) {
                [self animateHappyBarGraph:rectangle :[happyItem[@"value"] intValue] :max];
            }
        }];
    }
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

- (void)animateHappyBarGraph:(UIView *)rectangle :(int)value :(int)max
{
    CGRect frame = rectangle.frame;
    float height = 360 * ((float)value / (float)max);
    frame.size.height = height;
    frame.origin.y = 360 - height;
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [valueLabel setText:[NSString stringWithFormat:@"%d", value]];
    [valueLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24.0]];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [valueLabel setTextColor:[UIColor blackColor]];
    valueLabel.alpha = 0.8;
    
    [UIView animateWithDuration:0.8 delay:0.25 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [rectangle addSubview:valueLabel];
        [rectangle setFrame:frame];
    } completion:NULL];
}

@end
