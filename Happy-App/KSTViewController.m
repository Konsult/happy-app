//
//  KSTViewController.m
//  Happy-App
//
//  Created by Greg on 2/10/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTViewController.h"

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
    circleView = [[UIView alloc] initWithFrame:CGRectMake(-150, 150, 380, 380)];
    circleView.alpha = 0.5;
    circleView.layer.cornerRadius = 190;
    circleView.backgroundColor = [UIColor darkGrayColor];
//    [mainContainerSubView addSubview:circleView];

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
    UIView *containerSubview = [self.view viewWithTag:99];
    mainContainerSubView = containerSubview;

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
            happyItem = [[NSDictionary alloc] initWithObjectsAndKeys:@"Add",@"title", nil];
        } else {
            happyItem = [happyItems objectAtIndex:i];
        }
        
        UIButton *happyItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [happyItemButton setTag:i];
        [happyItemButton addTarget:self action:@selector(updateAndSaveHappyItem:) forControlEvents:UIControlEventTouchUpInside];
        if (i == happyItems.count) {
            [happyItemButton setImage:[UIImage imageNamed:@"icon-circle-add-50x50.png"] forState:UIControlStateNormal];
        } else {
            [happyItemButton setImage:[UIImage imageNamed:@"icon-circle-50x50.png"] forState:UIControlStateNormal];
        }
        [happyItemButton.imageView setTintColor:[UIColor whiteColor]];
        [happyItemButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [happyItemButton setTitle:happyItem[@"title"] forState:UIControlStateNormal];
        [happyItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [happyItemButton setTintColor:[UIColor whiteColor]];
        happyItemButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        happyItemButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        happyItemButton.frame = CGRectMake(-150, (200 + (i * 55)) , 130, 50);

        UIView *happyItemsContainerView = [self.view viewWithTag:5];

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

- (void)slideViewWithPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];

    // move view by translation amount
    [mainContainerSubView setFrame:CGRectMake((mainContainerSubView.frame.origin.x + translation.x), 0, 640, 568)];

    // reset translation to 0 for next move
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];


    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.view];

        // slide left ended
        if (velocity.x < 0) {
            if (mainContainerSubView.frame.origin.x < -150 || velocity.x < -1000) {
                [self showHappyItemStats];
                [UIView animateWithDuration:0.3f animations:^{
                    [mainContainerSubView setFrame:CGRectMake(-320, 0, 640, 568)];
                }];
            } else {
                [UIView animateWithDuration:0.1f animations:^{
                    [mainContainerSubView setFrame:CGRectMake(0, 0, 640, 568)];
                }];
            }
        // slide right ended
        } else if (velocity.x > 0) {
            if (mainContainerSubView.frame.origin.x > -170 || velocity.x > 1000) {
                [UIView animateWithDuration:0.3f animations:^{
                    [mainContainerSubView setFrame:CGRectMake(0, 0, 640, 568)];
                    [graphScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }];
            } else {
                [UIView animateWithDuration:0.1f animations:^{
                    [mainContainerSubView setFrame:CGRectMake(-320, 0, 640, 568)];
                }];
            }
        }
    }
}

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define CIRCLE_RADIUS 190

- (void)rotateButton:(UIButton *)button
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, circleView.center.x + 30, circleView.center.y, CIRCLE_RADIUS, DEGREES_TO_RADIANS(140), DEGREES_TO_RADIANS(280 + ([button tag] * 30)), YES);

    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];

    pathAnimation.removedOnCompletion = NO;
    pathAnimation.path = path;
    [pathAnimation setCalculationMode:kCAAnimationCubicPaced];
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.2 :0.8 :0.5 :0.9]];
    [pathAnimation setFillMode:kCAFillModeForwards];
    pathAnimation.duration = 0.8;
    pathAnimation.beginTime = CACurrentMediaTime() + ([button tag] * 0.1);

    CGPathRelease(path);

    [button.layer addAnimation:pathAnimation forKey:nil];
}

- (void)showHappyItemStats
{
    int max = [self findMaxHappyValue:happyItems];

    graphScrollView.contentSize = CGSizeMake((happyItems.count * 64), 470);
  
    for (int i = 0; i < happyItems.count; i++) {
        NSDictionary *happyItem = [happyItems objectAtIndex:i];
        UIView *happyItemBarView = [[UIView alloc] initWithFrame:CGRectMake((i * 64), 0, 75, 450)];
        
        UILabel *happyItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 410, 50, 40)];
        [happyItemLabel setText:happyItem[@"title"]];
        [happyItemLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0]];
        [happyItemLabel setLineBreakMode:NSLineBreakByWordWrapping];
        happyItemLabel.numberOfLines = 0;
        happyItemLabel.textAlignment = NSTextAlignmentCenter;
        [happyItemLabel setTextColor:[UIColor whiteColor]];
        [happyItemLabel setTintColor:[UIColor clearColor]];
        
        [happyItemBarView addSubview:happyItemLabel];
        
        UIView *rectangle = [[UIView alloc] initWithFrame:CGRectMake(14, 385, 50, 0)];
        [rectangle setBackgroundColor:[UIColor whiteColor]];
        rectangle.alpha = 0.8;

        [happyItemBarView addSubview:rectangle];
        
        UIImage *circleIcon = [UIImage imageNamed:@"icon-circle-50x50.png"];
        UIImageView *circleIconView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 360, 50, 50)];
        [circleIconView setImage:circleIcon];
        [circleIconView setTintColor:[UIColor whiteColor]];
        
        [happyItemBarView addSubview:circleIconView];
        
        [graphScrollView addSubview:happyItemBarView];
        
        [self animateHappyBarGraph:rectangle :[happyItem[@"value"] intValue] :max];
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
    float height = 385 * ((float)value / (float)max);
    frame.size.height = height;
    frame.origin.y = 385 - height;
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [valueLabel setText:[NSString stringWithFormat:@"%d", value]];
    [valueLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24.0]];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [valueLabel setTextColor:[UIColor blackColor]];
    valueLabel.alpha = 0.8;

    NSLog(@"value: %d, max: %d, height: %f", value, max, height);
    
    [UIView animateWithDuration:0.8 delay:0.25 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [rectangle setFrame:frame];
        [rectangle addSubview:valueLabel];
    } completion:NULL];
}

@end
