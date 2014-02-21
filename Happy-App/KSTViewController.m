//
//  KSTViewController.m
//  Happy-App
//
//  Created by Greg on 2/10/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTViewController.h"

#import "KSTHappyTypeButton.h"
#import "KSTBarGraphItem.h"

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
    pathAnimation.beginTime = CACurrentMediaTime() + (([button tag] + 1) * 0.2f);

    [pathAnimation setDelegate:self];
    
    CGPathRelease(path);

    [button.layer addAnimation:pathAnimation forKey:nil];
    NSDictionary *buttonDic = [[NSDictionary alloc] initWithObjectsAndKeys:button,@"view",[NSValue valueWithCGPoint:endPoint],@"point",nil];
    [self performSelector:@selector(setButtonCenter:) withObject:buttonDic afterDelay: happyItems.count * 0.3f];
}

- (void)setButtonCenter:(id)button
{
    [button[@"view"] setCenter:[button[@"point"] CGPointValue]];
}

- (void)showHappyItemStats
{
    if (graphScrollView.subviews.count > 0) {
        return;
    }
    
    NSNumber *max = [NSNumber numberWithInt:[self findMaxValue:happyItems]];

    graphScrollView.contentSize = CGSizeMake((happyItems.count * 64 + 14), 470);
    
    for (int i = (int)happyItems.count - 1; i >= 0; i--) {
        NSDictionary *happyItem = [happyItems objectAtIndex:i];
        
        KSTBarGraphItem *happyItemBarView = [[KSTBarGraphItem alloc] initWithTitle:happyItem[@"title"] andImageName:happyItem[@"imageRef"] andValue:happyItem[@"value"]];
        
        [graphScrollView addSubview:happyItemBarView];

        CGPoint center = CGPointMake(14 + i * 64 + 25, happyItemBarView.center.y);
        
        [happyItemBarView performSelector:@selector(slideInBarToCenterPoint:) withObject:[NSValue valueWithCGPoint:center] afterDelay:(float)(abs(i - happyItems.count) * 0.2f)];
        
        [happyItemBarView performSelector:@selector(animateBarWithMax:) withObject:max afterDelay:(float)happyItems.count * 0.2f + 0.4f];
    }
}

- (int)findMaxValue:(NSArray *)items
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

@end
