//
//  KSTHappyTypeButton.m
//  Happy-App
//
//  Created by Jing Jin on 2/20/14.
//  Copyright (c) 2014 Konsult. All rights reserved.
//

#import "KSTHappyTypeButton.h"

#define ICON_DIAMETER 50
#define TEXT_WIDTH 70
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

@end

@implementation KSTHappyTypeButton
{
    UIButton *icon;
    UIImage *iconImage;
    UIImage *highlightedIconImage;
    UILabel *label;
}

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

    icon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ICON_DIAMETER, ICON_DIAMETER)];
    iconImage = [UIImage imageNamed:imageName];
    highlightedIconImage = [UIImage imageNamed:altImageName];
    [icon setImage:iconImage forState:UIControlStateNormal];
    [icon setImage:highlightedIconImage forState:UIControlStateHighlighted];
    [icon setImage:highlightedIconImage forState:UIControlStateSelected];
    icon.highlighted = NO;
    
    [icon addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    [icon addTarget:self action:@selector(buttonUnpressed:) forControlEvents:(UIControlEventTouchUpOutside | UIControlEventTouchCancel)];
    [icon addTarget:self action:@selector(toggleButton:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:icon];

    label = [[UILabel alloc] initWithFrame:CGRectMake(ICON_DIAMETER + TITLE_LEFT_MARGIN, 0, TEXT_WIDTH, ICON_DIAMETER)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.userInteractionEnabled = NO;

    [self addSubview:label];
    [self sendSubviewToBack:label];

    self.selected = NO;
    
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([icon pointInside:[self convertPoint:point toView:icon] withEvent:event]) {
        return YES;
    }
    
    return NO;
}

- (void)toggleButtonWithAnimation:(BOOL)animated
{
    if (animated) {
        [self toggleButton:self];
    } else {
        self.selected = !self.selected;
        icon.highlighted = self.selected;
    }
}

@end

@implementation KSTHappyTypeButton (Private)

- (void)buttonPressed:(KSTHappyTypeButton *)button
{
    icon.highlighted = !self.selected;
    [UIView animateWithDuration:BUTTON_PRESS_TRANSITION_DURATION animations:^{
        icon.layer.affineTransform = CGAffineTransformMakeScale(BUTTON_PRESS_SCALE, BUTTON_PRESS_SCALE);
    }];
}

- (void)toggleButton:(KSTHappyTypeButton *)button
{
    self.selected = !self.selected;
    
    if (self.selected) {
        UIImageView *bloom = [[UIImageView alloc] initWithImage:icon.imageView.image];
        [icon addSubview:bloom];
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
    [UIView animateWithDuration:BUTTON_PRESS_TRANSITION_DURATION animations:^{
        icon.layer.affineTransform = CGAffineTransformMakeScale(1, 1);
    }];
    icon.selected = self.selected;
}

@end

