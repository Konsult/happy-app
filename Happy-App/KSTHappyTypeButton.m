//
//  KSTHappyTypeButton.m
//  Happy-App
//
//  Created by Jing Jin on 2/20/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTHappyTypeButton.h"

#define HEIGHT 50
#define WIDTH 125
#define ALT_IMG_SUFFX @"Alt"
#define TITLE_LEFT_MARGIN 8

@implementation KSTHappyTypeButton

- (id)initWithFrame:(CGRect)frame
{
    assert(@"Do not call initWithFrame, use initWithTitle:andImageName: intead." == nil);
    return nil;
}

- (id)initWithTitle:(NSString *)title andImageName:(NSString *)imageName
{
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    if (!self)
        return nil;
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    NSString *altImageName = [imageName stringByAppendingString:ALT_IMG_SUFFX];
    [self setImage:[UIImage imageNamed:altImageName] forState:UIControlStateSelected];
    [self setImage:[UIImage imageNamed:altImageName] forState:UIControlStateHighlighted];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, TITLE_LEFT_MARGIN, 0, 0)];
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    return self;
}

@end
