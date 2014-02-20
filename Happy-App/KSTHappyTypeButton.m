//
//  KSTHappyTypeButton.m
//  Happy-App
//
//  Created by Jing Jin on 2/20/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTHappyTypeButton.h"

#define ICON_DIAMETER 50
#define TEXT_WIDTH 75
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
    self = [super initWithFrame:CGRectMake(0, 0, ICON_DIAMETER + TEXT_WIDTH, ICON_DIAMETER)];
    if (!self)
        return nil;
    
    NSString *altImageName = [imageName stringByAppendingString:ALT_IMG_SUFFX];
    iconView = [[UIImageView alloc]
                initWithImage:[UIImage imageNamed:imageName]
                highlightedImage:[UIImage imageNamed:altImageName]];
    [self addSubview:iconView];
    
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, ICON_DIAMETER + TITLE_LEFT_MARGIN, 0, 0)];
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    return self;
}

@end
