//
//  CodeInputView.m
//
//
//  Created by zhangjia on 16/4/25.
//  Copyright © 2016年 zjia8765. All rights reserved.
//

#import "ZJCodeInputView.h"

@interface ZJCodeInputView()<UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, assign) float inputItemWidth;
@property (nonatomic, assign) float inputItemHeight;
@property (nonatomic, assign) float inputItemSpacing;
@property (nonatomic, assign) NSInteger inputNumber;
@property (nonatomic, strong, readwrite) NSString *codeString;
@end

@implementation ZJCodeInputView
- (id)initWithCodeNumber:(NSInteger)codeNum itemWide:(float)itemWidth itemHegiht:(float)itemheight itemSpacing:(float)itemSpacing {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.inputNumber = codeNum;
        self.inputItemWidth = itemWidth;
        self.inputItemHeight = itemheight;
        self.inputItemSpacing = itemSpacing;
        
        self.itemViews = [NSMutableArray array];
        for (int i = 0; i<codeNum; i++) {
            UITextField *inputTextField= [[UITextField alloc] init];
            inputTextField.delegate = self;
            inputTextField.tag = 0;
            inputTextField.backgroundColor = [UIColor lightGrayColor];
            inputTextField.keyboardType = UIKeyboardTypeNumberPad;
            inputTextField.textAlignment = NSTextAlignmentCenter;
            [inputTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            inputTextField.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:inputTextField];
            [self.itemViews addObject:inputTextField];
        }
        
        self.clearButton = [[UIButton alloc]init];
        self.clearButton.hidden = YES;
        [self.clearButton setImage:[UIImage imageNamed:@"textfield_delete_icon"] forState:UIControlStateNormal];
        [self.clearButton addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.clearButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.clearButton];
        [self setCodeInputViewConstraints];

    }
    return self;
}

- (void)setCodeInputViewConstraints {
    UIView *lastView;
    NSDictionary *metricDict = @{@"itemSpacing" : @(self.inputItemSpacing),@"itemHeight":@(self.inputItemHeight),@"itemWidth":@(self.inputItemWidth),@"clearBtnWidth":@(KClearButtonWidth)};
    
    for (UIView *itemView in self.itemViews) {
        if (lastView) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeRight multiplier:1 constant:self.inputItemSpacing]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
            
        }else {
            
            NSDictionary *viewsDic = @{@"itemView": itemView};
            [self addConstraint:[NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:self.inputItemSpacing]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:itemView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:self.inputItemSpacing]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[itemView(itemWidth)]" options:0 metrics:metricDict views:viewsDic]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[itemView(itemHeight)]" options:0 metrics:metricDict views:viewsDic]];
        }
        lastView=itemView;
    }
    
    NSDictionary *viewsDic = @{@"clearView": self.clearButton};
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.clearButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[clearView]-|" options:0 metrics:metricDict views:viewsDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[clearView(clearBtnWidth)]" options:0 metrics:metricDict views:viewsDic]];
}

- (CGSize)intrinsicContentSize {
    CGSize size = CGSizeMake((self.inputItemWidth+self.inputItemSpacing)*self.inputNumber + KClearButtonWidth, self.inputItemHeight + self.inputItemSpacing*2);
    return size;
}

- (void)clearButtonAction:(UIButton *)button {
    [self clearTextFieldText];
    [self setTextFiledFirstResponder];
}

- (void)clearTextFieldText {
    [self.itemViews enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.text = nil;
    }];
}

- (void)setTextFiledFirstResponder {
    NSMutableString *codeStr = [NSMutableString string];

    __block NSInteger focuseIndex = -1;
    [self.itemViews enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.userInteractionEnabled = NO;
        if (textField.text.length) {
            [codeStr appendString:textField.text];
        }else{
            if (focuseIndex < 0) {
                focuseIndex = idx;
                textField.userInteractionEnabled = YES;
                [textField becomeFirstResponder];
            }
        }
        
    }];
    
    if (codeStr.length == self.itemViews.count) {
        [(UITextField*)self.itemViews.lastObject setUserInteractionEnabled:YES];
        [(UITextField*)self.itemViews.lastObject becomeFirstResponder];
    }
    
    self.clearButton.hidden = codeStr.length == 0;
    self.codeString = codeStr;
    if (self.inputCodeDidChange) {
        self.inputCodeDidChange(self.codeString);
    }
}

- (void)shakeInptutViewDidCodeError {
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:2];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self center].x - 20.0f, [self center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([self center].x + 20.0f, [self center].y)]];
    [[self layer] addAnimation:animation forKey:@"position"];
}
#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        
        return YES;
    }
    return textField.text.length < 1;
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self setTextFiledFirstResponder];
}
@end
