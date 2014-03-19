//
//  KSTViewController.h
//  Happy-App
//
//  Created by Greg on 2/10/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSTAddButton.h"
#import "KSTRotaryScrollView.h"
#import "KSTPanningScrollView.h"

@interface KSTViewController : UIViewController <UIGestureRecognizerDelegate, KSTPanningScrollViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    __weak IBOutlet UILabel *dateLabel;
    NSMutableArray *happyItems;
    NSMutableArray *happyItemButtons;
    NSString *happyItemsPlistPath;
    NSString *usageTrackingPlistPath;
    NSMutableArray *usageDates;
    __weak IBOutlet UIImageView *backgroundImageView;
    __weak IBOutlet UIImageView *blurImageView;
    __weak IBOutlet UIView *containerView;
    KSTRotaryScrollView *rotaryScrollView;
    __weak IBOutlet UIView *homeView;
    __weak IBOutlet UIView *graphView;
    __weak IBOutlet UIScrollView *graphScrollView;
    UIControl *arrowsGroup;
    BOOL canSlideToRightView;
    BOOL canSlideToLeftView;
    KSTAddButton *addButton;
    UITapGestureRecognizer *tapRecognizer;
    UITextField *addHappyItemField;
}

@end
