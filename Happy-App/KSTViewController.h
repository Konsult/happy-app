//
//  KSTViewController.h
//  Happy-App
//
//  Created by Greg on 2/10/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSTViewController : UIViewController

{
    __weak IBOutlet UILabel *dateLabel;
    NSMutableArray *happyItems;
    NSString *happyItemsPlistPath;
    UIView *circleView;
    __weak IBOutlet UIView *bgImageView;
    __weak IBOutlet UIImageView *bgBlurView;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *happyItemsContainerView;
    __weak IBOutlet UIScrollView *graphScrollView;
    __weak IBOutlet UIView *graphView;
    CGPoint endAnimationPoint;
}

@end
