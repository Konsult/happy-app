//
//  KSTRotaryScrollView.h
//  Happy-App
//
//  Created by Greg on 3/3/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSTRotaryScrollView : UIView <UIScrollViewDelegate>
{
    CGPoint linearContentOffset;
    UIScrollView *_scrollView;
}

- (void)setScrollViewContentSizeBasedOnSubviewCount:(int)count viewableCount:(int)viewableCount andSizeInterval:(float)interval;

- (void)setScrollViewContentOffset:(CGPoint)contentOffset;

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset;

@end
