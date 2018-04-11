//
//  PIASwitch.h
//  PIA VPN
//
//  Created by Amir Malik on 11/17/14.
//  Copyright (c) 2014 Pilvy LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PIASwitch : UIControl <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIColor *offBackgroundColor;
@property (strong, nonatomic) UIColor *onBackgroundColor;
@property (strong, nonatomic) UIColor *indeterminateBackgroundColor;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) NSString *onText;
@property (strong, nonatomic) NSString *offText;

@property (nonatomic, getter=isOn) BOOL on;
@property (nonatomic, getter=isIndeterminate) BOOL indeterminate;

@end
