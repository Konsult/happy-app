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
    [self loadHappyItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        UIButton *happyItemButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [happyItemButton setTag:i];
        [happyItemButton addTarget:self action:@selector(updateAndSaveHappyItem:) forControlEvents:UIControlEventTouchUpInside];
        [happyItemButton setTitle:happyItem[@"title"] forState:UIControlStateNormal];
        happyItemButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        happyItemButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        happyItemButton.frame = CGRectMake(20, (200 + (i * 55)) , 80, 50);
        [self.view addSubview:happyItemButton];
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
