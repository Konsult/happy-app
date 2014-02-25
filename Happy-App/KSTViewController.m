//
//  KSTViewController.m
//  Happy-App
//
//  Created by Greg on 2/10/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTViewController.h"
#import "KSTHappyTypeButton.h"

#define HAPPY_ITEM_KEY_VALUE @"value"
#define HAPPY_ITEM_KEY_IMAGEREF @"imageRef"
#define HAPPY_ITEM_KEY_TITLE @"title"
#define SCREEN_WIDTH 320
#define CONTAINER_WIDTH 640
#define CONTAINER_HEIGHT 568
#define BG_WIDTH 600
#define SLIDE_THRESHOLD 80
#define VELOCITY_THRESHOLD 750
#define LAYER1_LTR_MULT 2
#define LAYER2_LTR_MULT 1.5
#define LAYER3_LTR_MULT 1
#define LAYER1_RTL_MULT 2
#define LAYER2_RTL_MULT 1.75
#define LAYER3_RTL_MULT 1.75
#define SWIPE_ANIM_DUR 0.5f
#define SWIPE_BOUNCEBACK_DUR 0.1f
#define BUTTON_START_X -150
#define BUTTON_START_Y 200
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define CIRCLE_RADIUS 185
#define CIRCLE_CENTER_X 75
#define CIRCLE_CENTER_Y 340
#define CIRCLE_ANIMATION_DUR 0.8f
#define CIRCLE_ANIMATION_INTERVAL 0.2f
#define BUTTON_DEGREE_INTEVAL 30
#define CIRCLE_ANIMATION_START_DEGREE 140
#define CIRCLE_ANIMATION_END_DEGREE 270
#define BEZIER_CURVE_P1_X 0.2f
#define BEZIER_CURVE_P1_Y 0.8f
#define BEZIER_CURVE_P2_X 0.5f
#define BEZIER_CURVE_P2_Y 0.9f

@interface KSTViewController (Private)

@end

@implementation KSTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initPanRecognizer];

    [self getAndShowDate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadHappyItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"selected"] && [object isKindOfClass:[KSTHappyTypeButton class]]) {
        [self updateAndSaveHappyItem:object];
    }
}

#pragma mark Init methods
- (IBAction)initPanRecognizer
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideViewWithPan:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panRecognizer];
}

#pragma mark Helper methods
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

- (void)slideViewWithPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if (translation.x < 0) {
        [backgroundImageView setFrame:CGRectMake(MAX(backgroundImageView.frame.origin.x + translation.x * LAYER3_LTR_MULT, (-BG_WIDTH + SCREEN_WIDTH)), 0, BG_WIDTH, CONTAINER_HEIGHT)];
        [blurImageView setFrame:CGRectMake(MAX(blurImageView.frame.origin.x + translation.x * LAYER2_LTR_MULT, (-BG_WIDTH + SCREEN_WIDTH)), 0, BG_WIDTH, CONTAINER_HEIGHT)];
        [containerView setFrame:CGRectMake(MAX(containerView.frame.origin.x + (translation.x * LAYER1_LTR_MULT), (-SCREEN_WIDTH)), 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
    } else if (translation.x > 0) {
        // FIXME: These translation multipliers do not give proper parallax effect.
        // Need to readjust BG sizes or find better way to move back to home view
        [backgroundImageView setFrame:CGRectMake(MIN(backgroundImageView.frame.origin.x + translation.x * LAYER3_RTL_MULT, 0), 0, BG_WIDTH, CONTAINER_HEIGHT)];
        [blurImageView setFrame:CGRectMake(MIN(blurImageView.frame.origin.x + translation.x * LAYER2_RTL_MULT, 0), 0, BG_WIDTH, CONTAINER_HEIGHT)];
        [containerView setFrame:CGRectMake(MIN(containerView.frame.origin.x + translation.x * LAYER1_RTL_MULT, 0), 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
    }
    
    // reset translation to 0 for next move
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        // slide left ended
        if (velocity.x < 0) {
            if (containerView.frame.origin.x < -SLIDE_THRESHOLD || velocity.x < -VELOCITY_THRESHOLD) {
                [UIView animateWithDuration:SWIPE_ANIM_DUR animations:^{
                    [backgroundImageView setFrame:CGRectMake((-BG_WIDTH + SCREEN_WIDTH), 0, BG_WIDTH, CONTAINER_HEIGHT)];
                    [blurImageView setFrame:CGRectMake((-BG_WIDTH + SCREEN_WIDTH), 0, BG_WIDTH, CONTAINER_HEIGHT)];
                    [containerView setFrame:CGRectMake(-SCREEN_WIDTH, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
                } completion:^(BOOL finished) {
                    // animate to right "graph" view has finished
                }];
            } else {
                [UIView animateWithDuration:SWIPE_BOUNCEBACK_DUR animations:^{
                    [backgroundImageView setFrame:CGRectMake(0, 0, BG_WIDTH, CONTAINER_HEIGHT)];
                    [blurImageView setFrame:CGRectMake(0, 0, BG_WIDTH, CONTAINER_HEIGHT)];
                    [containerView setFrame:CGRectMake(0, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
                }];
            }
            // slide right ended
        } else if (velocity.x > 0) {
            if (containerView.frame.origin.x > (-SCREEN_WIDTH + SLIDE_THRESHOLD) || velocity.x > VELOCITY_THRESHOLD) {
                [UIView animateWithDuration:SWIPE_ANIM_DUR animations:^{
                    [backgroundImageView setFrame:CGRectMake(0, 0, BG_WIDTH, CONTAINER_HEIGHT)];
                    [blurImageView setFrame:CGRectMake(0, 0, BG_WIDTH, CONTAINER_HEIGHT)];
                    [containerView setFrame:CGRectMake(0, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
                } completion:^(BOOL finished) {
                    // animate to left "home" view has finished
                }];
            } else {
                [UIView animateWithDuration:SWIPE_BOUNCEBACK_DUR animations:^{
                    [backgroundImageView setFrame:CGRectMake((-BG_WIDTH + SCREEN_WIDTH), 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
                    [blurImageView setFrame:CGRectMake((-BG_WIDTH + SCREEN_WIDTH), 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
                    [containerView setFrame:CGRectMake(-SCREEN_WIDTH, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
                }];
            }
        }
    }
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

    [self addHappyItems];
}

-(void)addHappyItems
{
    for (int i = 0; i <= happyItems.count; i++) {
        NSDictionary *happyItem;

        if (i == happyItems.count) {
            happyItem = [[NSDictionary alloc] initWithObjectsAndKeys:@"Add",HAPPY_ITEM_KEY_TITLE,@"ButtonAdd",HAPPY_ITEM_KEY_IMAGEREF, nil];
        } else {
            happyItem = [happyItems objectAtIndex:i];
        }

        KSTHappyTypeButton *happyItemButton = [[KSTHappyTypeButton alloc] initWithTitle:happyItem[HAPPY_ITEM_KEY_TITLE] andImageName:happyItem[HAPPY_ITEM_KEY_IMAGEREF]];

        [happyItemButton setTag:i];

        [happyItemButton addObserver:self forKeyPath:@"selected" options:0 context:nil];
        CGRect buttonFrame = happyItemButton.frame;
        buttonFrame.origin = CGPointMake(BUTTON_START_X, BUTTON_START_Y);
        happyItemButton.frame = buttonFrame;

        [homeView addSubview:happyItemButton];

        [self rotateHappyButton:happyItemButton];
    }
}

- (void)rotateHappyButton:(UIButton *)button
{
    CGPoint endPoint = CGPointMake((CIRCLE_CENTER_X + CIRCLE_RADIUS * cos(DEGREES_TO_RADIANS(CIRCLE_ANIMATION_END_DEGREE + ([button tag] * BUTTON_DEGREE_INTEVAL)))), (CIRCLE_CENTER_Y + CIRCLE_RADIUS * sin(DEGREES_TO_RADIANS(CIRCLE_ANIMATION_END_DEGREE + ([button tag] * BUTTON_DEGREE_INTEVAL)))));

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, CIRCLE_CENTER_X, CIRCLE_CENTER_Y, CIRCLE_RADIUS, DEGREES_TO_RADIANS(CIRCLE_ANIMATION_START_DEGREE), DEGREES_TO_RADIANS(CIRCLE_ANIMATION_END_DEGREE + ([button tag] * BUTTON_DEGREE_INTEVAL)), YES);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);

    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];

    pathAnimation.removedOnCompletion = NO;
    pathAnimation.path = path;
    [pathAnimation setCalculationMode:kCAAnimationCubicPaced];
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:BEZIER_CURVE_P1_X :BEZIER_CURVE_P1_Y :BEZIER_CURVE_P2_X :BEZIER_CURVE_P2_Y]];
    [pathAnimation setFillMode:kCAFillModeForwards];
    pathAnimation.duration = CIRCLE_ANIMATION_DUR;
    pathAnimation.beginTime = CACurrentMediaTime() + (([button tag] + 1) * CIRCLE_ANIMATION_INTERVAL);

    [pathAnimation setDelegate:self];

    CGPathRelease(path);

    [button.layer addAnimation:pathAnimation forKey:nil];
    NSDictionary *buttonDic = [[NSDictionary alloc] initWithObjectsAndKeys:button,@"view",[NSValue valueWithCGPoint:endPoint],@"point",nil];
    [self performSelector:@selector(setButtonCenter:) withObject:buttonDic afterDelay: happyItems.count * CIRCLE_ANIMATION_INTERVAL + CIRCLE_ANIMATION_DUR];
}

- (void)setButtonCenter:(NSDictionary *)buttonDic
{
    [buttonDic[@"view"] setCenter:[buttonDic[@"point"] CGPointValue]];
}

-(void)updateAndSaveHappyItem:(UIButton*)button
{
    NSMutableDictionary *happyItem = [happyItems objectAtIndex:[button tag]];
    NSNumber *newHappyValue = [NSNumber numberWithInt:[happyItem[HAPPY_ITEM_KEY_VALUE] intValue] + 1];
    happyItem[HAPPY_ITEM_KEY_VALUE] = newHappyValue;

    NSLog(@"Updated happy item: %@", happyItem);

    [happyItems writeToFile:happyItemsPlistPath atomically:YES];
}

@end
