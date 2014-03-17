//
//  KSTBarGraphItem.h
//  Happy-App
//
//  Created by Greg on 2/20/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSTBarGraphItem : UIView
{
    int value;
}

- (id)initWithTitle:(NSString *)title andImageName:(NSString *)imageName andValue:(int)value;

- (void)slideInBarToCenterPoint:(NSValue *)centerPointValue;

- (void)animateInBarRelativeToMax:(NSNumber *)max;

@end
