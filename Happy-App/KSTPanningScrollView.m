//
//  KSTPanningScrollView.m
//  Happy-App
//
//  Created by Jing Jin on 2/27/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTPanningScrollView.h"

@interface KSTPanningScrollView (UIKit_Private)
- (void)_updatePanGesture;
@end

@interface UIScrollView (UIKit_Private)
- (void)_updatePanGesture;
@end

@implementation KSTPanningScrollView

@end

@implementation KSTPanningScrollView (UIKit_Private)

- (void)_updatePanGesture
{
    if (!self.delegate) {
        [super _updatePanGesture];
        return;
    }
    
    CGPoint translation = [self.panGestureRecognizer translationInView:self];
    
    if (translation.x > 0 && self.contentOffset.x == 0
        && [self.delegate canPanScrollView:self inDirection:KSTDirectionLeft]) {
        [self.delegate panScrollView:self];
    } else if (translation.x < 0 && self.contentOffset.x == self.contentSize.width
        && [self.delegate canPanScrollView:self inDirection:KSTDirectionRight]) {
        [self.delegate panScrollView:self];
    } else if (translation.y > 0 && self.contentOffset.y == 0
        && [self.delegate canPanScrollView:self inDirection:KSTDirectionUp]) {
        [self.delegate panScrollView:self];
    } else if (translation.y < 0 && self.contentOffset.y == self.contentSize.height
        && [self.delegate canPanScrollView:self inDirection:KSTDirectionDown]) {
        [self.delegate panScrollView:self];
    } else {
        [super _updatePanGesture];
    }
}


@end