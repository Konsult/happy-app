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

#define BUTTON_PRESS_SCALE 1.25f
#define BUTTON_PRESS_TRANSITION_DURATION 0.1f
#define BLOOM_ANIMATION_DURATION 0.2f
#define BLOOM_ANIMATION_SCALE 3

@interface KSTHappyTypeButton (Private)

- (void)buttonPressed:(KSTHappyTypeButton *)button;
- (void)buttonUnpressed:(KSTHappyTypeButton *)button;
- (void)toggleButton:(KSTHappyTypeButton *)button;

- (void)animateBloom:(id)caller;

@end

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
    
    [self addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(buttonUnpressed:) forControlEvents:(UIControlEventTouchUpOutside | UIControlEventTouchCancel)];
    [self addTarget:self action:@selector(toggleButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return self;
}

@end

@implementation KSTHappyTypeButton (Private)

- (void)buttonPressed:(KSTHappyTypeButton *)button
{
    iconView.highlighted = YES;
    [UIView animateWithDuration:BUTTON_PRESS_TRANSITION_DURATION animations:^{
        iconView.layer.affineTransform = CGAffineTransformMakeScale(BUTTON_PRESS_SCALE, BUTTON_PRESS_SCALE);
    }];
}


- (void)toggleButton:(KSTHappyTypeButton *)button
{
    self.selected = !self.selected;
    
    if (self.selected) {
        UIImageView *bloom = [[UIImageView alloc] initWithImage:iconView.image];
        [self addSubview:bloom];
        [UIView animateWithDuration:BLOOM_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            bloom.layer.affineTransform = CGAffineTransformMakeScale(BLOOM_ANIMATION_SCALE, BLOOM_ANIMATION_SCALE);
            bloom.layer.opacity = 0;
        } completion:^(BOOL finished){
            [bloom removeFromSuperview];
        }];
    }
    
    [self buttonUnpressed:button];
}

- (void)buttonUnpressed:(KSTHappyTypeButton *)button
{
    iconView.highlighted = self.selected;
    [UIView animateWithDuration:BUTTON_PRESS_TRANSITION_DURATION animations:^{
        iconView.layer.affineTransform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)animateBloom:(id)caller
{
    
}

@end

