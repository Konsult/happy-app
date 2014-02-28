//
//  KSTPanningScrollView.m
//  Happy-App
//
//  Created by Jing Jin on 2/27/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTPanningScrollView.h"


@interface KSTPanningScrollView (Private)
- (void)endPanningGestureForDelegate;
@end

@interface KSTPanningScrollView (UIKit_Private)
- (void)_updatePanGesture;
@end

@interface UIScrollView (UIKit_Private)
- (void)_updatePanGesture;
@end

@implementation KSTPanningScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    [self.panGestureRecognizer addTarget:self action:@selector(endPanningGestureForDelegate)];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (!self)
        return nil;
    
    [self.panGestureRecognizer addTarget:self action:@selector(endPanningGestureForDelegate)];
    return self;
}


#pragma mark Private Methods

- (void)endPanningGestureForDelegate
{
    if (self.delegate && delegateIsReceivingGestures && self.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.delegate panScrollView:self];
        delegateIsReceivingGestures = NO;
    }
}

#pragma mark UIKit Private Methods

- (void)_updatePanGesture
{
    if (!self.delegate) {
        delegateIsReceivingGestures = NO;
        [super _updatePanGesture];
        return;
    }
    
    if (delegateIsReceivingGestures) {
        [self.delegate panScrollView:self];
        return;
    }
    
    CGPoint translation = [self.panGestureRecognizer translationInView:self];
    
    if (translation.x > 0 && self.contentOffset.x == 0
        && [self.delegate canPanScrollView:self inDirection:KSTDirectionLeft]) {
        [self.delegate panScrollView:self];
        delegateIsReceivingGestures = YES;
    } else if (translation.x < 0 && self.contentOffset.x == self.contentSize.width
        && [self.delegate canPanScrollView:self inDirection:KSTDirectionRight]) {
        [self.delegate panScrollView:self];
        delegateIsReceivingGestures = YES;
    } else if (translation.y > 0 && self.contentOffset.y == 0
        && [self.delegate canPanScrollView:self inDirection:KSTDirectionUp]) {
        [self.delegate panScrollView:self];
        delegateIsReceivingGestures = YES;
    } else if (translation.y < 0 && self.contentOffset.y == self.contentSize.height
        && [self.delegate canPanScrollView:self inDirection:KSTDirectionDown]) {
        [self.delegate panScrollView:self];
        delegateIsReceivingGestures = YES;
    } else {
        [super _updatePanGesture];
        delegateIsReceivingGestures = NO;
    }
}


@end