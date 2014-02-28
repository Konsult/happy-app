//
//  KSTViewController.h
//  Happy-App
//
//  Created by Greg on 2/10/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSTAddButton.h"

@interface KSTViewController : UIViewController <UITextFieldDelegate>
{
    __weak IBOutlet UILabel *dateLabel;
    NSMutableArray *happyItems;
    NSMutableArray *happyItemButtons;
    NSString *happyItemsPlistPath;
    __weak IBOutlet UIImageView *backgroundImageView;
    __weak IBOutlet UIImageView *blurImageView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *homeView;
    __weak IBOutlet UIView *graphView;
    __weak IBOutlet UIScrollView *graphScrollView;
    UIControl *arrowsGroup;
    BOOL canSlideToRightView;
    BOOL canSlideToLeftView;
    KSTAddButton *addButton;
}

@end
