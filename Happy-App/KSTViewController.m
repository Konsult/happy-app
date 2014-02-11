//
//  KSTViewController.m
//  Happy-App
//
//  Created by Greg on 2/10/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTViewController.h"

@interface KSTViewController ()

@property (weak, nonatomic) IBOutlet UILabel *date;
@property NSMutableArray *happyItems;

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

- (void)getAndShowDate
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:systemTimeZone];
    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
    NSString *dateString = [dateFormatter stringFromDate:today];
    [_date setText:dateString];
}

-(void)loadHappyItems
{
    NSString *happyItemsPlistPath = [[NSBundle mainBundle] pathForResource:@"HappyItems" ofType:@"plist"];
    NSArray *happyItemsArray = [NSArray arrayWithContentsOfFile:happyItemsPlistPath];
    [self.happyItems addObjectsFromArray:happyItemsArray];
    NSLog(@"Happy items: %@", happyItemsArray);
}

@end
