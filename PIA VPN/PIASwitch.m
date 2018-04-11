//
//  PIASwitch.m
//  PIA VPN
//
//  Created by Amir Malik on 11/17/14.
//  Copyright (c) 2014 Pilvy LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PIASwitch.h"

@interface PIASwitchBaseLayer : CALayer

@property (strong, nonatomic) UIColor *fillColor;
@property (assign, nonatomic) NSTextAlignment textAlignment;
@property (strong, nonatomic) NSString *text;

@end

@implementation PIASwitchBaseLayer

- (void)drawInContext:(CGContextRef)ctx
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1.0, 0, self.bounds.size.width - 2.0, self.bounds.size.height) cornerRadius:self.bounds.size.height / 2.0];
    
    CGContextAddPath(ctx, bezierPath.CGPath);
    CGContextClip(ctx);
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    
    if([self.text length] > 0) {
        UIGraphicsPushContext(ctx);
        
        UIFont *font = [UIFont systemFontOfSize:ceilf(self.bounds.size.height * 0.4)];
        NSDictionary *textAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]};
        
        CGSize textSize = [self.text sizeWithAttributes:textAttributes];
        CGPoint textOrigin;
        
        if(self.textAlignment == NSTextAlignmentRight) {
            textOrigin = CGPointMake((self.bounds.size.width - textSize.width) / 2.0 + self.bounds.size.width * 0.2, floorf((self.bounds.size.height - textSize.height) / 2.0) + 1.0);
        } else {
            textOrigin = CGPointMake(self.bounds.size.width * 0.15, floorf((self.bounds.size.height - textSize.height) / 2.0) + 1.0);
        }
        
        [self.text drawAtPoint:textOrigin withAttributes:textAttributes];
        
        UIGraphicsPopContext();
    }
}

@end

#pragma mark -

@interface PIASwitchKnobLayer : CALayer

@end

@implementation PIASwitchKnobLayer

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height));
}

@end

#pragma mark -

@interface PIASwitch ()

@property (strong, nonatomic) PIASwitchBaseLayer *baseLayer;
@property (strong, nonatomic) PIASwitchKnobLayer *knobLayer;
@property (assign, nonatomic) BOOL wasOn;
@property (assign, nonatomic) BOOL wasIndeterminate;

@end

@implementation PIASwitch

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    self.baseLayer = [[PIASwitchBaseLayer alloc] init];
    self.baseLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.baseLayer];
    [self.baseLayer setNeedsDisplay];
    
    self.knobLayer = [[PIASwitchKnobLayer alloc] init];
    self.knobLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.knobLayer];
    [self.knobLayer setNeedsDisplay];
    
    [self setNeedsLayout];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressGestureRecognizer.minimumPressDuration = 2.0; // seconds
    longPressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:longPressGestureRecognizer];
}

- (void)layoutSubviews
{
    self.baseLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    [self updateFrames];
}

- (void)updateFrames
{
    CGFloat knobMargin = floorf(self.frame.size.height * 0.15);
    CGFloat knobDiameter = floorf(self.frame.size.height - 2 * knobMargin);
    BOOL isEnglish = [[NSLocale preferredLanguages].firstObject hasPrefix:@"en"];
    
    if (self.isIndeterminate) {
        self.baseLayer.fillColor = self.indeterminateBackgroundColor;
        self.baseLayer.text = @"";
        self.knobLayer.frame = CGRectMake(self.frame.size.width / 2 - knobDiameter / 2, knobMargin, knobDiameter, knobDiameter);
    }
    else if (self.isOn) {
        self.baseLayer.fillColor = self.onBackgroundColor;
        self.baseLayer.text = isEnglish ? @"ON" : @"I";
        self.baseLayer.textAlignment = NSTextAlignmentLeft;
        self.knobLayer.frame = CGRectMake(self.frame.size.width - knobDiameter - knobMargin, knobMargin, knobDiameter, knobDiameter);
    }
    else {
        self.baseLayer.fillColor = self.offBackgroundColor;
        self.baseLayer.text = isEnglish ? @"OFF" : @"O";
        self.baseLayer.textAlignment = NSTextAlignmentRight;
        self.knobLayer.frame = CGRectMake(knobMargin, knobMargin, knobDiameter, knobDiameter);
    }
    
    [self.baseLayer setNeedsDisplay];
    [self.knobLayer setNeedsDisplay];
}

- (void)setOn:(BOOL)on
{
    _on = on;
    [self updateFrames];
}

- (void)setIndeterminate:(BOOL)indeterminate
{
    _indeterminate = indeterminate;
    [self updateFrames];
}

- (void)tapped:(UITapGestureRecognizer *)gesture
{
    if(self.isIndeterminate) {
        [self setIndeterminate:NO];
        [self setOn:NO];
    } else {
        [self setOn:!self.isOn];
        [self setIndeterminate:YES];
    }
    
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)dragged:(UIPanGestureRecognizer *)gesture
{
    CGFloat knobMargin = floorf(self.frame.size.height * 0.15);
    CGFloat knobDiameter = floorf(self.frame.size.height - 2 * knobMargin);
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.wasOn = self.isOn;
        self.wasIndeterminate = self.isIndeterminate;
        self.baseLayer.text = @"";
        [self.baseLayer setNeedsDisplay];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat minX = knobMargin;
        CGFloat maxX = self.frame.size.width - knobDiameter - knobMargin;
        
        CGPoint translation = [gesture translationInView:self];
        
        CGRect frame = self.knobLayer.frame;
        frame.origin.x += translation.x;
        
        if (frame.origin.x < minX) {
            frame.origin.x = minX;
        }
        if (frame.origin.x > maxX) {
            frame.origin.x = maxX;
        }
        
        self.knobLayer.frame = frame;
        
        [gesture setTranslation:CGPointZero inView:self];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        BOOL pastMidpoint = self.knobLayer.frame.origin.x > self.frame.size.width / 2;
        
        [self updateFrames];
        
        if ((self.wasOn && pastMidpoint) || (!self.wasOn && !pastMidpoint)) {
            return;
        }
        
        [self setOn:pastMidpoint];
        [self setIndeterminate:YES];
        
        [self setNeedsDisplay];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)longPressed:(UILongPressGestureRecognizer *)gesture
{
    if(self.isIndeterminate) {
        [self setOn:NO];
        [self setIndeterminate:NO];
        [self setNeedsDisplay];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark Gesture Recognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
