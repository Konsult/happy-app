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
    [self initPanRecognizer];

    [self getAndShowDate];
    [self loadHappyItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [backgroundImageView setFrame:CGRectMake(MAX(backgroundImageView.frame.origin.x + translation.x, (-BG_WIDTH + 320)), 0, BG_WIDTH, MAIN_HEIGHT)];
        [blurImageView setFrame:CGRectMake(MAX(blurImageView.frame.origin.x + translation.x * 1.5, (-BG_WIDTH + 320)), 0, BG_WIDTH, MAIN_HEIGHT)];
        [containerView setFrame:CGRectMake(MAX(containerView.frame.origin.x + (translation.x * 2), (-MAIN_WIDTH / 2)), 0, MAIN_WIDTH, MAIN_HEIGHT)];
    } else if (translation.x > 0) {
        [backgroundImageView setFrame:CGRectMake(MIN(backgroundImageView.frame.origin.x + translation.x * 1.75, 0), 0, BG_WIDTH, MAIN_HEIGHT)];
        [blurImageView setFrame:CGRectMake(MIN(blurImageView.frame.origin.x + translation.x * 1.75, 0), 0, BG_WIDTH, MAIN_HEIGHT)];
        [containerView setFrame:CGRectMake(MIN(containerView.frame.origin.x + translation.x * 2, 0), 0, MAIN_WIDTH, MAIN_HEIGHT)];
    }
    
    // reset translation to 0 for next move
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        // slide left ended
        if (velocity.x < 0) {
            if (containerView.frame.origin.x < -SLIDE_THRESHOLD || velocity.x < -VELOCITY_THRESHOLD) {
                [UIView animateWithDuration:0.5f animations:^{
                    [backgroundImageView setFrame:CGRectMake((-BG_WIDTH + 320), 0, BG_WIDTH, MAIN_HEIGHT)];
                    [blurImageView setFrame:CGRectMake((-BG_WIDTH + 320), 0, BG_WIDTH, MAIN_HEIGHT)];
                    [containerView setFrame:CGRectMake(-SCREEN_WIDTH, 0, MAIN_WIDTH, MAIN_HEIGHT)];
                } completion:^(BOOL finished) {
                    // animate to right "graph" view has finished
                }];
            } else {
                [UIView animateWithDuration:0.1f animations:^{
                    [backgroundImageView setFrame:CGRectMake(0, 0, BG_WIDTH, MAIN_HEIGHT)];
                    [blurImageView setFrame:CGRectMake(0, 0, BG_WIDTH, MAIN_HEIGHT)];
                    [containerView setFrame:CGRectMake(0, 0, MAIN_WIDTH, MAIN_HEIGHT)];
                }];
            }
            // slide right ended
        } else if (velocity.x > 0) {
            if (containerView.frame.origin.x > (-SCREEN_WIDTH + SLIDE_THRESHOLD) || velocity.x > 1000) {
                [UIView animateWithDuration:0.3f animations:^{
                    [backgroundImageView setFrame:CGRectMake(0, 0, BG_WIDTH, MAIN_HEIGHT)];
                    [blurImageView setFrame:CGRectMake(0, 0, BG_WIDTH, MAIN_HEIGHT)];
                    [containerView setFrame:CGRectMake(0, 0, MAIN_WIDTH, MAIN_HEIGHT)];
                } completion:^(BOOL finished) {
                    // animate to left "home" view has finished
                }];
            } else {
                [UIView animateWithDuration:0.1f animations:^{
                    [backgroundImageView setFrame:CGRectMake((-BG_WIDTH + 320), 0, MAIN_WIDTH, MAIN_HEIGHT)];
                    [blurImageView setFrame:CGRectMake((-BG_WIDTH + 320), 0, MAIN_WIDTH, MAIN_HEIGHT)];
                    [containerView setFrame:CGRectMake(-SCREEN_WIDTH, 0, MAIN_WIDTH, MAIN_HEIGHT)];
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

    [self showHappyItems];
}

-(void)showHappyItems
{
    for (int i = 0; i < happyItems.count; i++) {
        NSDictionary *happyItem = [happyItems objectAtIndex:i];
        UIButton *happyItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [happyItemButton setTag:i];
        [happyItemButton addTarget:self action:@selector(updateAndSaveHappyItem:) forControlEvents:UIControlEventTouchUpInside];
        [happyItemButton setTitle:happyItem[@"title"] forState:UIControlStateNormal];
        happyItemButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        happyItemButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        happyItemButton.frame = CGRectMake(15, (200 + (i * 55)) , 80, 50);
        [happyItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [homeView addSubview:happyItemButton];
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

@end
