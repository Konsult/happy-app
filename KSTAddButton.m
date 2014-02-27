//
//  KSTAddButton.m
//  Happy-App
//
//  Created by Greg on 2/27/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTAddButton.h"

#define ICON_DIAMETER 50
#define TEXT_WIDTH 75
#define TITLE_LEFT_MARGIN 8
#define TITLE @"Add"
#define ALT_IMG_SUFFX @"Alt"
#define IMAGE_NAME @"ButtonAdd"

@interface KSTAddButton (Private)

- (void)buttonPressed:(KSTAddButton *)button;

@end

@implementation KSTAddButton

- (id)initWithFrame:(CGRect)frame
{
    assert(@"Do not call initWithFrame, use init intead." == nil);
    return nil;
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(-(ICON_DIAMETER + TEXT_WIDTH), 0, ICON_DIAMETER + TEXT_WIDTH, ICON_DIAMETER)];
    if (!self)
        return nil;

    NSString *altImageName = [IMAGE_NAME stringByAppendingString:ALT_IMG_SUFFX];
    iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMAGE_NAME] highlightedImage:[UIImage imageNamed:altImageName]];
    [self addSubview:iconView];

    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, ICON_DIAMETER + TITLE_LEFT_MARGIN, 0, 0)];
    [self setTitle:TITLE forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    return self;
}

@end
