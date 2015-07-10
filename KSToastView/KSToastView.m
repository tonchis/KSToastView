//
//  KSToastView.m
//
// The MIT License (MIT)
//
// Copyright (c) 2015 c0ming ( https://github.com/c0ming )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "KSToastView.h"

#define KS_TOAST_VIEW_ANIMATION_DURATION  0.5f
#define KS_TOAST_VIEW_OFFSET_BOTTOM  61.0f
#define KS_TOAST_VIEW_OFFSET_LEFT_RIGHT  8.0f
#define KS_TOAST_VIEW_OFFSET_TOP  76.0f
#define KS_TOAST_VIEW_SHOW_DURATION  3.0f
#define KS_TOAST_VIEW_TAG 1024
#define KS_TOAST_VIEW_TEXT_FONT_SIZE  14.0f
#define KS_TOAST_VIEW_TEXT_PADDING  8.0f

static UIColor *_backgroundColor = nil;
static UIColor *_textColor = nil;
static UIFont *_textFont = nil;
static CGFloat _cornerRadius = 0.0f;
static CGFloat _duration = KS_TOAST_VIEW_SHOW_DURATION;
static CGFloat _maxWidth = 0.0f;
static CGFloat _maxHeight = 0.0f;
static CGFloat _offsetBottom = KS_TOAST_VIEW_OFFSET_BOTTOM;
static CGFloat _offsetTop = KS_TOAST_VIEW_OFFSET_TOP;
static CGFloat _textPadding = KS_TOAST_VIEW_TEXT_PADDING;
static NSTextAlignment _textAligment = NSTextAlignmentCenter;
static UIView *_currentToastView = nil;

@interface KSToastView ()

@end

@implementation KSToastView

#pragma mark - ToastView Config

+ (void)ks_setAppearanceBackgroundColor:(UIColor *)backgroundColor {
	_backgroundColor = [backgroundColor copy];
}

+ (void)ks_setAppearanceCornerRadius:(CGFloat)cornerRadius {
	_cornerRadius = cornerRadius;
}

+ (void)ks_setAppearanceMaxHeight:(CGFloat)maxHeight {
	_maxHeight = maxHeight;
}

+ (void)ks_setAppearanceMaxWidth:(CGFloat)maxWidth {
	_maxWidth = maxWidth;
}

+ (void)ks_setAppearanceOffsetBottom:(CGFloat)offsetBottom {
	_offsetBottom = offsetBottom;
}

+ (void)ks_setAppearanceTextAligment:(NSTextAlignment)textAlignment {
	_textAligment = textAlignment;
}

+ (void)ks_setAppearanceTextColor:(UIColor *)textColor {
	_textColor = [textColor copy];
}

+ (void)ks_setAppearanceTextFont:(UIFont *)textFont {
	_textFont = [textFont copy];
}

+ (void)ks_setAppearanceTextPadding:(CGFloat)textPadding {
	_textPadding = textPadding;
}

+ (void)ks_setToastViewShowDuration:(NSTimeInterval)duration {
	_duration = duration;
}

#pragma mark - ToastView Show

+ (void)ks_showToast:(id)toast {
	[KSToastView ks_showToast:toast duration:_duration];
}

+ (void)ks_showToast:(id)toast duration:(NSTimeInterval)duration {
	[KSToastView ks_showToast:toast duration:duration completion:nil];
}

+ (void)ks_showToast:(id)toast completion:(KSToastBlock)completion {
	[KSToastView ks_showToast:toast duration:_duration completion:completion];
}

+ (void)ks_showToast:(id)toast duration:(NSTimeInterval)duration completion:(KSToastBlock)completion {
	NSString *toastText = [NSString stringWithFormat:@"%@", toast];
	if (toastText.length < 1) {
		return;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		UIView *toastView = [UIView new];
		toastView.translatesAutoresizingMaskIntoConstraints = NO;
		toastView.userInteractionEnabled = NO;
		toastView.backgroundColor = [self _backgroundColor];
		toastView.tag = KS_TOAST_VIEW_TAG;
		toastView.layer.cornerRadius = _cornerRadius;
		toastView.clipsToBounds = YES;
		toastView.alpha = 0.0f;

		UILabel *toastLabel = [UILabel new];
		toastLabel.translatesAutoresizingMaskIntoConstraints = NO;
		toastLabel.font = [self _textFont];
		toastLabel.text = toastText;
		toastLabel.textColor = [self _textColor];
		toastLabel.textAlignment = _textAligment;
		toastLabel.numberOfLines = 0;

		UIView *keyWindowView = [self _keyWindowView];
		if (!keyWindowView) {
		    return;
		}
		[[keyWindowView viewWithTag:KS_TOAST_VIEW_TAG] removeFromSuperview];
		[keyWindowView endEditing:YES];

		CGSize toastLabelSize = [toastLabel sizeThatFits:CGSizeMake([self _maxWidth] - _textPadding * 2.0f, [self _maxHeight] - _textPadding * 2.0f)];
		CGFloat toastViewWidth = toastLabelSize.width + _textPadding * 2.0f;
		CGFloat toastViewHeight = toastLabelSize.height + _textPadding * 2.0f;

		if (toastViewWidth > _maxWidth) {
		    toastViewWidth = _maxWidth;
		}

		if (toastViewHeight > _maxWidth) {
		    toastViewHeight = _maxHeight;
		}

		NSDictionary *views = NSDictionaryOfVariableBindings(toastLabel, toastView);

		[toastView addSubview:toastLabel];
		[keyWindowView addSubview:toastView];

		[toastView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%@)-[toastLabel]-(%@)-|", @(_textPadding), @(_textPadding)]
		                                                                  options:0
		                                                                  metrics:nil
		                                                                    views:views]];
		[toastView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%@)-[toastLabel]-(%@)-|", @(_textPadding), @(_textPadding)]
		                                                                  options:0
		                                                                  metrics:nil
		                                                                    views:views]];

		[keyWindowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[toastView(%@)]", @(toastViewWidth)]
		                                                                      options:0
		                                                                      metrics:nil
		                                                                        views:views]];
		[keyWindowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(>=%@)-[toastView(<=%@)]-(%@)-|", @(_offsetTop), @(toastViewHeight), @(_offsetBottom)]
		                                                                      options:0
		                                                                      metrics:nil
		                                                                        views:views]];
		[keyWindowView addConstraint:[NSLayoutConstraint constraintWithItem:toastView
		                                                          attribute:NSLayoutAttributeCenterX
		                                                          relatedBy:NSLayoutRelationEqual
		                                                             toItem:keyWindowView
		                                                          attribute:NSLayoutAttributeCenterX
		                                                         multiplier:1.0f
		                                                           constant:0.0f]];
		[keyWindowView layoutIfNeeded];

		[UIView animateWithDuration:KS_TOAST_VIEW_ANIMATION_DURATION animations: ^{
		    toastView.alpha = 1.0f;
		}];

              _currentToastView = toastView;

              if (duration) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self ks_dismissToast:completion];
                });
              }
	});
}

+ (void)ks_dismissToast:(KSToastBlock)completion {
    [UIView animateWithDuration:KS_TOAST_VIEW_ANIMATION_DURATION animations: ^{
        _currentToastView.alpha = 0.0f;
    } completion: ^(BOOL finished) {
        [_currentToastView removeFromSuperview];

        KSToastBlock block = [completion copy];
        if (block) {
            block();
        }
    }];
}

#pragma mark - Private Methods

+ (UIFont *)_textFont {
	if (_textFont == nil) {
		_textFont = [UIFont systemFontOfSize:KS_TOAST_VIEW_TEXT_FONT_SIZE];
	}
	return _textFont;
}

+ (UIColor *)_textColor {
	if (_textColor == nil) {
		_textColor = [UIColor whiteColor];
	}
	return _textColor;
}

+ (UIColor *)_backgroundColor {
	if (_backgroundColor == nil) {
		_backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
	}
	return _backgroundColor;
}

+ (CGFloat)_maxHeight {
	if (_maxHeight <= 0) {
		_maxHeight = [self _portraitScreenHeight] - (_offsetBottom + KS_TOAST_VIEW_OFFSET_TOP);
	}

	return _maxHeight;
}

+ (CGFloat)_maxWidth {
	if (_maxWidth <= 0) {
		_maxWidth = [self _portraitScreenWidth] - (KS_TOAST_VIEW_OFFSET_LEFT_RIGHT + KS_TOAST_VIEW_OFFSET_LEFT_RIGHT);
	}
	return _maxWidth;
}

+ (CGFloat)_portraitScreenWidth {
	return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? CGRectGetWidth([UIScreen mainScreen].bounds) : CGRectGetHeight([UIScreen mainScreen].bounds);
}

+ (CGFloat)_portraitScreenHeight {
	return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? CGRectGetHeight([UIScreen mainScreen].bounds) : CGRectGetWidth([UIScreen mainScreen].bounds);
}

+ (UIView *)_keyWindowView {
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (!window)
		window = [[UIApplication sharedApplication].windows firstObject];
	return [[window subviews] firstObject];
}

@end
