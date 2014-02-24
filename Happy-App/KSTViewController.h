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
    UIView *mainContainerSubView;
    UIView *circleView;
}

@end
