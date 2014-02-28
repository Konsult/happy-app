//
//  KSTPanningScrollView.h
//  Happy-App
//
//  Created by Jing Jin on 2/27/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KSTDirection.h"

@class KSTPanningScrollView;

@protocol KSTPanningScrollViewDelegate <UIScrollViewDelegate>

- (BOOL)canPanScrollView:(KSTPanningScrollView *)view inDirection:(KSTDirection)direction;
- (void)panScrollView:(KSTPanningScrollView *)view;

@end

@interface KSTPanningScrollView : UIScrollView
{
    BOOL delegateIsReceivingGestures;
}

@property(nonatomic,assign) id<KSTPanningScrollViewDelegate> delegate;

@end
