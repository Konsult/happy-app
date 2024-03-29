//
//  KSTViewController.m
//  Happy-App
//
//  Created by Greg on 2/10/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTViewController.h"
#import "KSTRotaryScrollView.h"
#import "KSTHappyTypeButton.h"
#import "KSTAddButton.h"
#import "KSTBarGraphItem.h"

// Keys to Happy Item dictionary
#define HAPPY_ITEM_KEY_VALUE @"value"
#define HAPPY_ITEM_KEY_IMAGEREF @"imageRef"
#define HAPPY_ITEM_KEY_TITLE @"title"
#define HAPPY_ITEM_KEY_DATES @"dates"

// Main view properties
#define SCREEN_WIDTH 320
#define CONTAINER_WIDTH 640
#define CONTAINER_HEIGHT 568
#define BG_WIDTH 600

// Pan/swipe animation options
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

// Button properties
#define ADD_BUTTON_IMAGE @"ButtonAdd"
#define BUTTON_START_X -150
#define BUTTON_START_Y 200
#define ZERO_INDEXED_BUTTON_SLOTS 6
#define VIEWABLE_BUTTON_COUNT [UIScreen mainScreen].bounds.size.height < 481.0f ?5 : 7

// Add properties
#define TEXT_FIELD_WIDTH 296
#define TEXT_FIELD_PLACEHOLDER @"What makes you happy?"

// Rotation helper functions
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define X_POINT_ON_CIRCLE(centerX, radius, angle) centerX + radius * cos(angle)
#define Y_POINT_ON_CIRCLE(centerY, radius, angle) centerY + radius * sin(angle)

// Rotation properties
#define CIRCLE_RADIUS 185
#define CIRCLE_CENTER_X 35
#define CIRCLE_CENTER_Y 340
#define BUTTON_X_CENTER_OFFSET 37.5
#define BUTTON_DEGREE_INTERVAL 30
#define BUTTON_CIRCLE_OFFSET DEGREES_TO_RADIANS(BUTTON_DEGREE_INTERVAL)
#define CIRCLE_ANIMATION_START_DEGREE 140
#define CIRCLE_ANIMATION_END_DEGREE 270
#define ROTARY_SCROLL_CONTENTSIZE_OFFSET 54.0f
#define ROTARY_SCROLL_CONTENTINSET 13
#define kAnimationCompletionBlock @"animationCompletionBlock"
typedef void(^animationCompletionBlock)(void);

// Rotation animation options
#define CIRCLE_ANIMATION_DUR 0.8f
#define CIRCLE_ANIMATION_INTERVAL 0.2f
#define BEZIER_CURVE_P1_X 0.2f
#define BEZIER_CURVE_P1_Y 0.8f
#define BEZIER_CURVE_P2_X 0.5f
#define BEZIER_CURVE_P2_Y 0.9f

// Bar graph properties
#define BAR_WIDTH 50
#define BAR_INTERVAL 15
#define ICON_WIDTH 50
#define ICON_ANIMATION_INTERVAL 0.2f

// Scroll arrows properties
#define ARROWS_HEIGHT_WIDTH 45
#define ARROWS_Y 50
#define ARROWS_CENTER_Y ARROWS_Y + (ARROWS_HEIGHT_WIDTH / 2)
#define ARROWS_RIGHT_X 260
#define ARROWS_RIGHT_CENTER_X ARROWS_RIGHT_X + (ARROWS_HEIGHT_WIDTH / 2)
#define ARROWS_LEFT_X 15
#define ARROWS_LEFT_CENTER_X ARROWS_LEFT_X + (ARROWS_HEIGHT_WIDTH / 2)
#define ARROWS_TRAVEL_DISTANCE 245.0
#define ARROWS_PADDING 15

// Scroll arrows animation options
#define RUNWAY_DUR 1.75f
#define RUNWAY_DELAY 0.1f
#define RUNWAY_LOW_ALPHA 0.2f

// Rating alert
#define CONSECUTIVE_DAYS_TO_ALERT 5 // minimum is 2
#define ALERT_TITLE @"Does Think Happy Make You Happy?"
#define ALERT_MESSAGE @"If so, we'd really appreciate if you took a moment to rate us in the App Store. It makes us happy! =]"
#define ALERT_CANCEL @"No, Thanks"
#define ALERT_OK @"App Store"
#define APP_STORE_URL @"https://itunes.apple.com/us/app/think-happy/id879225651?mt=8" // Should be of format http://itunes.apple.com/app/appID
#define ALERT_ALWAYS_SHOW NO //YES = debug, NO = production

@interface KSTViewController (Private)

@end

@implementation KSTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initPanRecognizer];
//    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];

    [self addRotaryScrollView];
    [self getAndShowDate];
    [self addSwipeArrows];

    canSlideToRightView = YES;
    canSlideToLeftView = NO;
    
    [self setupUsageTracking];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark Setup methods
- (IBAction)initPanRecognizer
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideViewWithPan:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    panRecognizer.delegate = self;
    
    [self.view addGestureRecognizer:panRecognizer];
}

- (void)setupUsageTracking
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDir stringByAppendingPathComponent:@"UsageTracking.plist"];
    usageTrackingPlistPath = plistPath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:plistPath]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"UsageTracking" ofType:@"plist"];
        
        [fileManager copyItemAtPath:bundle toPath:plistPath error:&error];
    }
    
    usageDates = [NSMutableArray arrayWithContentsOfFile:plistPath];
}

#pragma gesture delegate methods
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([self.view.gestureRecognizers containsObject:gestureRecognizer] && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        return fabs(velocity.y) < 100;
    }
    
    return YES;
}

#pragma mark Helper methods
- (void)addRotaryScrollView
{
    rotaryScrollView = [[KSTRotaryScrollView alloc] init];
    [containerView addSubview:rotaryScrollView];
}


- (void)addSwipeArrows
{
    UIImage *arrowImage = [UIImage imageNamed:@"SwipeArrow"];
    arrowsGroup = [[UIControl alloc] initWithFrame:CGRectMake(ARROWS_RIGHT_X, ARROWS_Y, ARROWS_HEIGHT_WIDTH, ARROWS_HEIGHT_WIDTH)];

    for (int i = 0; i < 3; i++) {
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:arrowImage];
        [arrowView setFrame:CGRectMake(0, 0, arrowImage.size.width, arrowImage.size.height)];
        [arrowView setCenter:CGPointMake(ARROWS_PADDING + (i * arrowImage.size.width), arrowsGroup.frame.size.height/2)];
    
        [UIView animateWithDuration:RUNWAY_DUR delay:(RUNWAY_DELAY * i) options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction) animations:^{
            arrowView.alpha = RUNWAY_LOW_ALPHA;
        }completion:^(BOOL finished) {
            arrowView.alpha = 1;
        }];
    
        [arrowsGroup addSubview:arrowView];
    }

    [arrowsGroup addTarget:self action:@selector(slideToView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:arrowsGroup];
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

- (void)slideViewWithPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if (translation.x < 0) {
        CGPoint arrowsCenter = arrowsGroup.center;
        arrowsCenter.x = MAX(arrowsCenter.x + (translation.x * LAYER1_LTR_MULT), ARROWS_LEFT_CENTER_X);
        [arrowsGroup setCenter:arrowsCenter];

        [backgroundImageView setFrame:CGRectMake(MAX(backgroundImageView.frame.origin.x + translation.x * LAYER3_LTR_MULT, (-BG_WIDTH + SCREEN_WIDTH)), 0, BG_WIDTH, CONTAINER_HEIGHT)];
        [blurImageView setFrame:CGRectMake(MAX(blurImageView.frame.origin.x + translation.x * LAYER2_LTR_MULT, (-BG_WIDTH + SCREEN_WIDTH)), 0, BG_WIDTH, CONTAINER_HEIGHT)];
        [containerView setFrame:CGRectMake(MAX(containerView.frame.origin.x + (translation.x * LAYER1_LTR_MULT), (-SCREEN_WIDTH)), 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
    } else if (translation.x > 0) {
        // FIXME: These translation multipliers do not give proper parallax effect.
        // Need to readjust BG sizes or find better way to move back to home view

        CGPoint arrowsCenter = arrowsGroup.center;
        arrowsCenter.x = MIN(arrowsCenter.x + (translation.x * LAYER1_RTL_MULT), ARROWS_RIGHT_CENTER_X);
        [arrowsGroup setCenter:arrowsCenter];

        [backgroundImageView setFrame:CGRectMake(MIN(backgroundImageView.frame.origin.x + translation.x * LAYER3_RTL_MULT, 0), 0, BG_WIDTH, CONTAINER_HEIGHT)];
        [blurImageView setFrame:CGRectMake(MIN(blurImageView.frame.origin.x + translation.x * LAYER2_RTL_MULT, 0), 0, BG_WIDTH, CONTAINER_HEIGHT)];
        [containerView setFrame:CGRectMake(MIN(containerView.frame.origin.x + translation.x * LAYER1_RTL_MULT, 0), 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
    }
    
    float newAngle = DEGREES_TO_RADIANS((ARROWS_TRAVEL_DISTANCE / [UIScreen mainScreen].bounds.size.width) * containerView.frame.origin.x / ARROWS_TRAVEL_DISTANCE * 180);
    CGAffineTransform arrowsTransform = CGAffineTransformMakeRotation(newAngle);
    [arrowsGroup setTransform:arrowsTransform];
    
    // reset translation to 0 for next move
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        // slide left to graph ended
        if (velocity.x < 0) {
            if (containerView.frame.origin.x < -SLIDE_THRESHOLD || velocity.x < -VELOCITY_THRESHOLD) {
                if (canSlideToRightView) {
                    [self slideToView];
                }
            } else {
                [UIView animateWithDuration:SWIPE_BOUNCEBACK_DUR animations:^{
                    [arrowsGroup setCenter:CGPointMake(ARROWS_RIGHT_CENTER_X, ARROWS_CENTER_Y)];
                    arrowsGroup.transform = CGAffineTransformIdentity;
                    [backgroundImageView setFrame:CGRectMake(0, 0, BG_WIDTH, CONTAINER_HEIGHT)];
                    [blurImageView setFrame:CGRectMake(0, 0, BG_WIDTH, CONTAINER_HEIGHT)];
                    [containerView setFrame:CGRectMake(0, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
                }];
            }
        // slide right to home ended
        } else if (velocity.x > 0) {
            if (containerView.frame.origin.x > (-SCREEN_WIDTH + SLIDE_THRESHOLD) || velocity.x > VELOCITY_THRESHOLD) {
                if (canSlideToLeftView) {
                    [self slideToView];
                }
            } else {
                [UIView animateWithDuration:SWIPE_BOUNCEBACK_DUR animations:^{
                    [arrowsGroup setCenter:CGPointMake(ARROWS_LEFT_CENTER_X, ARROWS_CENTER_Y)];
                    arrowsGroup.transform = CGAffineTransformMakeRotation(M_PI);
                    [backgroundImageView setFrame:CGRectMake((-BG_WIDTH + SCREEN_WIDTH), 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
                    [blurImageView setFrame:CGRectMake((-BG_WIDTH + SCREEN_WIDTH), 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
                    [containerView setFrame:CGRectMake(-SCREEN_WIDTH, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
                }];
            }
        }
    }
}

-(void)slideToView
{
    // Autoscroll graphview to front before sliding
    if (graphScrollView.contentOffset.x > 0) {
        [graphScrollView setContentOffset:CGPointZero animated:YES];
        return;
    }

    if (canSlideToRightView) {
        // sliding to graph
        [UIView animateWithDuration:SWIPE_ANIM_DUR animations:^{
            [arrowsGroup setCenter:CGPointMake(ARROWS_LEFT_CENTER_X, ARROWS_CENTER_Y)];

            arrowsGroup.transform = CGAffineTransformMakeRotation(M_PI);
            [backgroundImageView setFrame:CGRectMake((-BG_WIDTH + SCREEN_WIDTH), 0, BG_WIDTH, CONTAINER_HEIGHT)];
            [blurImageView setFrame:CGRectMake((-BG_WIDTH + SCREEN_WIDTH), 0, BG_WIDTH, CONTAINER_HEIGHT)];
            [containerView setFrame:CGRectMake(-SCREEN_WIDTH, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
        } completion:^(BOOL finished) {
            // animate to right "graph" view has finished
            canSlideToRightView = NO;
            canSlideToLeftView = YES;
            [self showHappyItemStats];
        }];
    } else if (canSlideToLeftView) {
        // sliding to home
        [UIView animateWithDuration:SWIPE_ANIM_DUR animations:^{
            [arrowsGroup setCenter:CGPointMake(ARROWS_RIGHT_CENTER_X, ARROWS_CENTER_Y)];

            arrowsGroup.transform = CGAffineTransformIdentity;
            [backgroundImageView setFrame:CGRectMake(0, 0, BG_WIDTH, CONTAINER_HEIGHT)];
            [blurImageView setFrame:CGRectMake(0, 0, BG_WIDTH, CONTAINER_HEIGHT)];
            [containerView setFrame:CGRectMake(0, 0, CONTAINER_WIDTH, CONTAINER_HEIGHT)];
        } completion:^(BOOL finished) {
            // animate to left "home" view has finished
            canSlideToLeftView = NO;
            canSlideToRightView = YES;
            [[graphScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }];
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
    
    [rotaryScrollView setScrollViewContentSizeBasedOnSubviewCount:(int)happyItems.count viewableCount:VIEWABLE_BUTTON_COUNT andSizeInterval:ROTARY_SCROLL_CONTENTSIZE_OFFSET];
    
    NSLog(@"Init with happy items: %@", happyItems);

    [self addButtons];
}

-(void)addButtons
{
    happyItemButtons = [[NSMutableArray alloc] init];
    
    int counter = 0;
    for (int i = (int)happyItems.count - 1; i >= 0; i--) {
        NSDictionary *happyItem;

        happyItem = [happyItems objectAtIndex:i];
        KSTHappyTypeButton *happyItemButton = [[KSTHappyTypeButton alloc] initWithTitle:happyItem[HAPPY_ITEM_KEY_TITLE] andImageName:happyItem[HAPPY_ITEM_KEY_IMAGEREF]];
        
        NSArray *happyItemDates = happyItem[HAPPY_ITEM_KEY_DATES];
        if (happyItemDates.count) {
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
            NSDate *today = [cal dateFromComponents:components];
            components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[happyItemDates lastObject]];
            NSDate *lastSelectedDate = [cal dateFromComponents:components];
            
            if ([today isEqualToDate:lastSelectedDate] && !happyItemButton.selected) {
                // Since we are always entering app from blank slate, this will always highlight button
                // If/when there is some state saving upon exit, we may need to adjust how this works to not unhighlight a button
                [happyItemButton toggleButtonWithAnimation:NO];
            }
        }

        [happyItemButton addObserver:self forKeyPath:@"selected" options:0 context:nil];
        
        [happyItemButton setTag:i];
        
        [happyItemButton setCenter:CGPointMake(BUTTON_START_X, BUTTON_START_Y)];
        
        [rotaryScrollView addSubview:happyItemButton];
        
        [happyItemButtons insertObject:happyItemButton atIndex:0];

        if (counter <= ZERO_INDEXED_BUTTON_SLOTS) {
            [self moveHappyButton:happyItemButton toSlot:counter animate:YES];
        } else {
            [self moveHappyButton:happyItemButton toSlot:counter animate:NO];
        }
        counter++;
    }
}

// FIXME: This method is no longer used by addButtons, but is used in the add new item implementation. Should be eventually removed when add functionality is done.
- (KSTHappyTypeButton*)createAndPlaceHappyItemButtonWithData:(NSDictionary *)buttonData andCenterPoint:(CGPoint)center andTag:(int)tag
{
    KSTHappyTypeButton *happyItemButton = [[KSTHappyTypeButton alloc] initWithTitle:buttonData[HAPPY_ITEM_KEY_TITLE] andImageName:buttonData[HAPPY_ITEM_KEY_IMAGEREF]];

    [happyItemButton addObserver:self forKeyPath:@"selected" options:0 context:nil];
    
    if (!CGPointEqualToPoint(center, CGPointZero)) {
        [happyItemButton setCenter:center];
    } else {
        CGRect buttonFrame = happyItemButton.frame;
        buttonFrame.origin = CGPointMake(BUTTON_START_X, BUTTON_START_Y);
        happyItemButton.frame = buttonFrame;
    }
    
    [happyItemButton setTag:tag];
    
    [rotaryScrollView addSubview:happyItemButton];
    
    return happyItemButton;
}

- (void)moveHappyButton:(UIView *)button toSlot:(int)slot animate:(BOOL)animate
{   
    float endAngleFromPositiveXAxis;
    float endAngleFromPositiveYAxis;
    
    switch (slot) {
        case -1:
            endAngleFromPositiveXAxis = DEGREES_TO_RADIANS(210);
            endAngleFromPositiveYAxis = DEGREES_TO_RADIANS(-30);
            break;
        case 0:
            endAngleFromPositiveXAxis = DEGREES_TO_RADIANS(271.86572247);
            endAngleFromPositiveYAxis = DEGREES_TO_RADIANS(1.86572247);
            break;
        case 1:
            endAngleFromPositiveXAxis = DEGREES_TO_RADIANS(308.3457734);
            endAngleFromPositiveYAxis = DEGREES_TO_RADIANS(38.3457734);
            break;
        case 2:
            endAngleFromPositiveXAxis = DEGREES_TO_RADIANS(339.4257544);
            endAngleFromPositiveYAxis = DEGREES_TO_RADIANS(69.4257544);
            break;
        case 3:
            endAngleFromPositiveXAxis = DEGREES_TO_RADIANS(5.3592566);
            endAngleFromPositiveYAxis = DEGREES_TO_RADIANS(95.3592566);
            break;
        case 4:
            endAngleFromPositiveXAxis = DEGREES_TO_RADIANS(33.379242);
            endAngleFromPositiveYAxis = DEGREES_TO_RADIANS(123.379242);
            break;
        case 5:
            endAngleFromPositiveXAxis = DEGREES_TO_RADIANS(66.79924);
            endAngleFromPositiveYAxis = DEGREES_TO_RADIANS(156.79924);
            break;
        case 6:
            endAngleFromPositiveXAxis = DEGREES_TO_RADIANS(105.61925);
            endAngleFromPositiveYAxis = DEGREES_TO_RADIANS(195.61925);
            break;
        default:
            endAngleFromPositiveXAxis = DEGREES_TO_RADIANS(CIRCLE_ANIMATION_START_DEGREE);
            endAngleFromPositiveYAxis = DEGREES_TO_RADIANS(240);
            break;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformRotate(transform, endAngleFromPositiveYAxis);
    transform = CGAffineTransformTranslate(transform, 0, -CIRCLE_RADIUS);
    transform = CGAffineTransformRotate(transform, -1 * endAngleFromPositiveYAxis);
    
    if (animate) {
        CGMutablePathRef path = CGPathCreateMutable();

        CGPathAddArc(path, NULL, CIRCLE_CENTER_X + BUTTON_X_CENTER_OFFSET, CIRCLE_CENTER_Y, CIRCLE_RADIUS, DEGREES_TO_RADIANS(CIRCLE_ANIMATION_START_DEGREE), endAngleFromPositiveXAxis, YES);
        
        CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        
        pathAnimation.removedOnCompletion = NO;
        pathAnimation.path = path;
        [pathAnimation setCalculationMode:kCAAnimationCubicPaced];
        [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:BEZIER_CURVE_P1_X :BEZIER_CURVE_P1_Y :BEZIER_CURVE_P2_X :BEZIER_CURVE_P2_Y]];
        [pathAnimation setFillMode:kCAFillModeForwards];
        pathAnimation.duration = CIRCLE_ANIMATION_DUR;
        pathAnimation.beginTime = CACurrentMediaTime() + ((slot + 1) * CIRCLE_ANIMATION_INTERVAL);
        
        animationCompletionBlock pathAnimationCompleteBlock = ^void(void) {
            [button setCenter:CGPointMake(CIRCLE_CENTER_X + BUTTON_X_CENTER_OFFSET, CIRCLE_CENTER_Y)];
            [button setTransform:transform];
            [button.layer removeAnimationForKey:@"rotate"];
            
            if (slot == ZERO_INDEXED_BUTTON_SLOTS) {
                // Setting contentInset prevents top button from moving too far
                [rotaryScrollView setScrollViewContentInset:UIEdgeInsetsMake(ROTARY_SCROLL_CONTENTINSET, 0, 0, 0)];
                // Setting contentOffset prevents top button from quickly moving
                // off screen on initial scroll when contentOffset get's set to 0
                [rotaryScrollView setScrollViewContentOffset:CGPointMake(0, -ROTARY_SCROLL_CONTENTINSET)];
            }
        };
        
        [pathAnimation setValue:pathAnimationCompleteBlock forKey:kAnimationCompletionBlock];

        [pathAnimation setDelegate:self];
        
        CGPathRelease(path);

        [button.layer addAnimation:pathAnimation forKey:@"rotate"];
    } else {
        [button setCenter:CGPointMake(CIRCLE_CENTER_X + BUTTON_X_CENTER_OFFSET, CIRCLE_CENTER_Y)];
        [button setTransform:transform];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim valueForKey:kAnimationCompletionBlock]) {
        animationCompletionBlock completionBlock = [anim valueForKey:kAnimationCompletionBlock];
        completionBlock();
    }
}

-(void)updateAndSaveHappyItem:(KSTHappyTypeButton *)button
{
    [self trackUse];
    
    NSMutableDictionary *happyItem = [happyItems objectAtIndex:[button tag]];

    NSMutableArray *dates = happyItem[HAPPY_ITEM_KEY_DATES];
    if (button.selected) {
        NSDate *now = [NSDate date];
        [dates addObject:now];
    } else {
        [dates removeLastObject];
    }
    happyItem[HAPPY_ITEM_KEY_DATES] = dates;

    NSLog(@"Updated happy item: %@", happyItem);

    [happyItems writeToFile:happyItemsPlistPath atomically:YES];
}

- (void)trackUse
{
    if (ALERT_ALWAYS_SHOW) {
        [self showRatingReminder];
        return;
    }

    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    [components setDay:-1];
    NSDate *yesterday = [cal dateFromComponents:components];
    [components setDay:0];

    if (usageDates.count) {
        components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[usageDates lastObject]];
        NSDate *lastSelectedDate = [cal dateFromComponents:components];
        if ([lastSelectedDate isEqualToDate:yesterday]) {
            [usageDates addObject:today];
            if (usageDates.count == CONSECUTIVE_DAYS_TO_ALERT) {
                [self showRatingReminder];
            }
        } else if ([lastSelectedDate isEqualToDate:today]) {
            return;
        } else {
            [usageDates removeAllObjects];
        }
    } else {
        [usageDates addObject:today];
    }
    
    [usageDates writeToFile:usageTrackingPlistPath atomically:YES];
    
    NSLog(@"updated usage: %@", usageDates);
}

- (void)showRatingReminder
{
    UIAlertView *reminder = [[UIAlertView alloc] initWithTitle:ALERT_TITLE
                                                       message:ALERT_MESSAGE
                                                      delegate:nil
                                             cancelButtonTitle:ALERT_CANCEL
                                             otherButtonTitles:ALERT_OK, nil];
    reminder.delegate = self;
    [reminder show];
}

#pragma mark UIAlertView delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:ALERT_TITLE]) {
        if (buttonIndex == 0) {
            NSLog(@"cancel button");
        } else if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_URL]];
        }
    }
}

- (void)addButtonPressed:(KSTAddButton *)button
{
    addHappyItemField = [[UITextField alloc] initWithFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y, TEXT_FIELD_WIDTH, button.frame.size.height)];
    addHappyItemField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [addHappyItemField setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7f]];
    [addHappyItemField setPlaceholder:TEXT_FIELD_PLACEHOLDER];
    [addHappyItemField setTextColor:[UIColor darkGrayColor]];
    [addHappyItemField setBorderStyle:UITextBorderStyleRoundedRect];

    // Initializing empty text string to fix invalid context 0x0 error per these 2 sources:
    // 1. http://stackoverflow.com/questions/19599266/invalid-context-0x0-under-ios-7-0-and-system-degradation
    // 2. http://stackoverflow.com/questions/12800758/invalid-context-error-0x0-when-editing-uitextfield-using-mult-byte-keybord-w
    addHappyItemField.text = @"";

    addHappyItemField.delegate = self;

    UIImageView *addIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ADD_BUTTON_IMAGE]];

    [addHappyItemField setLeftView:addIcon];
    [addHappyItemField setLeftViewMode:UITextFieldViewModeAlways];

    [button removeFromSuperview];
    [homeView addSubview:addHappyItemField];
    [addHappyItemField becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.view addGestureRecognizer:tapRecognizer];

    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary* userInfo = [notification userInfo];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];

    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (!keyboardFrame.size.height) {
        return;
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -keyboardFrame.size.height)];
    [UIView commitAnimations];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:tapRecognizer];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary* userInfo = [notification userInfo];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];

    if (CGPointEqualToPoint(self.view.frame.origin, CGPointZero)) {
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];

}

- (void)dismissKeyboard
{
    [addHappyItemField resignFirstResponder];
    [addHappyItemField removeFromSuperview];
    [rotaryScrollView addSubview:addButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    NSString *text = textField.text;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([text length] > 0) {
        [self addNewHappyItem:textField.text];
    }

    [textField removeFromSuperview];
    [rotaryScrollView addSubview:addButton];

    return YES;
}

- (void)addNewHappyItem:(NSString *)happyItemText
{
    NSMutableDictionary *newHappyItem = [[NSMutableDictionary alloc] init];
    [newHappyItem setValue:happyItemText forKey:HAPPY_ITEM_KEY_TITLE];
    [newHappyItem setValue:[NSNumber numberWithInt:0] forKey:HAPPY_ITEM_KEY_VALUE];
    [newHappyItem setValue:@"ButtonWeather" forKey:HAPPY_ITEM_KEY_IMAGEREF];

    KSTHappyTypeButton *newHappyItemButton = [self createAndPlaceHappyItemButtonWithData:newHappyItem andCenterPoint:CGPointZero andTag:(int)happyItems.count];
    
    [happyItemButtons addObject:newHappyItemButton];

    [happyItems addObject:newHappyItem];
    [happyItems writeToFile:happyItemsPlistPath atomically:YES];

    int counter = ZERO_INDEXED_BUTTON_SLOTS;
    for (int i = (int)happyItemButtons.count - 1; i >= 0; i--) {
        [self moveHappyButton:happyItemButtons[i] toSlot:counter animate:NO];
        counter--;
    }
}

- (void)showHappyItemStats
{
    if (graphScrollView.subviews.count > 0) {
        return;
    }

    NSNumber *max = [NSNumber numberWithInt:[self findMaxValue:happyItems]];

    graphScrollView.contentSize = CGSizeMake((happyItems.count * (BAR_WIDTH + BAR_INTERVAL) + BAR_INTERVAL), graphScrollView.contentSize.height);
    graphScrollView.scrollEnabled = NO;

    for (int i = 0; i < happyItems.count; i++) {
        NSDictionary *happyItem = [happyItems objectAtIndex:i];

        NSArray *happyItemDates = happyItem[HAPPY_ITEM_KEY_DATES];
        KSTBarGraphItem *happyItemBarView = [[KSTBarGraphItem alloc] initWithTitle:happyItem[HAPPY_ITEM_KEY_TITLE] andImageName:happyItem[HAPPY_ITEM_KEY_IMAGEREF] andValue:(int)happyItemDates.count];

        [graphScrollView addSubview:happyItemBarView];

        int animationIdx = abs(i - (int)happyItems.count + 1);
        
        CGPoint center = CGPointMake(BAR_INTERVAL + animationIdx * (BAR_WIDTH + BAR_INTERVAL) + (ICON_WIDTH / 2), happyItemBarView.center.y);

        [happyItemBarView performSelector:@selector(slideInBarToCenterPoint:) withObject:[NSValue valueWithCGPoint:center] afterDelay:(animationIdx * ICON_ANIMATION_INTERVAL)];

        // Add 1 to delay multiple here to allow small bit of additional time for icon in bounce to finish before animating bars
        // Changed delay to use '5', the number of icons that fit on bar graph screen on inital animation
        [happyItemBarView performSelector:@selector(animateInBarRelativeToMax:) withObject:max afterDelay:5 * ICON_ANIMATION_INTERVAL];

    }
    
    float animationTimeMs = happyItems.count * ICON_ANIMATION_INTERVAL * 1000;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, animationTimeMs * NSEC_PER_MSEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        graphScrollView.scrollEnabled = YES;
    });
}

- (int)findMaxValue:(NSArray *)items
{
    int max = 0;

    for (int i = 0; i < items.count; i++) {
        NSDictionary *item = [items objectAtIndex:i];
        NSArray *happyItemDates = item[HAPPY_ITEM_KEY_DATES];

        if (happyItemDates.count > max) {
            max = (int)happyItemDates.count;
        }
    }

    return max;
}

#pragma mark KSTPanningScrollViewDelegate Methods
- (BOOL)canPanScrollView:(KSTPanningScrollView *)view inDirection:(KSTDirection)direction
{
    if (direction == KSTDirectionLeft && canSlideToLeftView)
        return true;
    return false;
}

- (void)panScrollView:(KSTPanningScrollView *)view
{
    [self slideViewWithPan:view.panGestureRecognizer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self slideToView];
}

@end
