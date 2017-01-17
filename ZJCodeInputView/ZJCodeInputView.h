//
//  CodeInputView.h
// 
//
//  Created by zhangjia on 16/4/25.
//  Copyright © 2016年 zjia8765. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KClearButtonWidth 60
@interface ZJCodeInputView : UIView
@property (nonatomic, strong, readonly) NSString *codeString;
@property (nonatomic,copy) void(^inputCodeDidChange)(NSString *code);

- (id)initWithCodeNumber:(NSInteger)codeNum itemWide:(float)itemWidth itemHegiht:(float)itemheight itemSpacing:(float)itemSpacing;


- (void)clearTextFieldText;

- (void)setTextFiledFirstResponder;

- (void)shakeInptutViewDidCodeError;
@end
