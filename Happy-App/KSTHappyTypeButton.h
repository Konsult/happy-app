//
//  KSTHappyTypeButton.h
//  Happy-App
//
//  Created by Jing Jin on 2/20/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSTHappyTypeButton : UIView

@property BOOL selected;

- (id)initWithTitle:(NSString *)title andImageName:(NSString *)imageName;

- (void)toggleButtonWithAnimation:(BOOL)animated;

@end
