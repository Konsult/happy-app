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

    [mainContainerSubView addSubview:circleView];

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
    for (int i = 0; i < happyItems.count; i++) {
        NSDictionary *happyItem = [happyItems objectAtIndex:i];
        UIButton *happyItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [happyItemButton setTag:i];
        [happyItemButton addTarget:self action:@selector(updateAndSaveHappyItem:) forControlEvents:UIControlEventTouchUpInside];
        [happyItemButton setImage:[UIImage imageNamed:@"icon-circle-50x50.png"] forState:UIControlStateNormal];
        [happyItemButton.imageView setTintColor:[UIColor whiteColor]];
        [happyItemButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [happyItemButton setTitle:happyItem[@"title"] forState:UIControlStateNormal];
        [happyItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [happyItemButton setTintColor:[UIColor whiteColor]];
        happyItemButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        happyItemButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        happyItemButton.frame = CGRectMake(20, (200 + (i * 55)) , 130, 50);

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

- (void)rotateButton:(UIButton *)button
{
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, circleView.center.x + 30, circleView.center.y, 190, DEGREES_TO_RADIANS(120 + ([button tag] * 30)), DEGREES_TO_RADIANS(290 + ([button tag] * 30)), YES);
    CGPathAddArc(path, NULL, circleView.center.x + 30, circleView.center.y, 190, DEGREES_TO_RADIANS(290 + ([button tag] * 30)), DEGREES_TO_RADIANS(305 + ([button tag] * 30)), NO);
    CGPathAddArc(path, NULL, circleView.center.x + 30, circleView.center.y, 190, DEGREES_TO_RADIANS(305 + ([button tag] * 30)), DEGREES_TO_RADIANS(300 + ([button tag] * 30)), YES);
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.path = path;
    [pathAnimation setCalculationMode:kCAAnimationCubicPaced];
    [pathAnimation setFillMode:kCAFillModeForwards];
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    pathAnimation.duration = 0.8f;

    CGPathRelease(path);

    [button.layer addAnimation:pathAnimation forKey:nil];
}

@end
