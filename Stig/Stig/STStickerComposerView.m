//
//  STStickerComposerView.m
//  Stig
//
//  Created by Lucas Tenório on 13/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STStickerComposerView.h"
#import "STStickerPickerView.h"
@implementation STStickerComposerView {
    UIScrollView *_scrollView;
    STStickerPickerView *_stickerPickerViewBad;
    STStickerPickerView *_stickerPickerViewNeutral;
    STStickerPickerView *_stickerPickerViewGood;
}

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self config];
    }
    return self;
}
- (void) config {
    self.backgroundColor = [UIColor clearColor];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];

    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    

    [self addSubview:_scrollView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_scrollView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_scrollView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_scrollView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_scrollView)]];

    _stickerPickerViewBad = [[STStickerPickerView alloc] initWithStickerModifier:STStickerModifierBad];
    _stickerPickerViewNeutral = [[STStickerPickerView alloc] initWithStickerModifier:STSTickerModifierNeutral];
    _stickerPickerViewGood = [[STStickerPickerView alloc] initWithStickerModifier:STSTickerModifierGood];

    _stickerPickerViewBad.delegate = self;
    _stickerPickerViewNeutral.delegate = self;
    _stickerPickerViewGood.delegate = self;
    
    [_scrollView addSubview:_stickerPickerViewBad];
    [_scrollView addSubview:_stickerPickerViewNeutral];
    [_scrollView addSubview:_stickerPickerViewGood];

//    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_stickerPickerViewNeutral]|"
//                                                                        options:0
//                                                                        metrics:nil
//                                                                          views:NSDictionaryOfVariableBindings(_stickerPickerViewNeutral)]];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_stickerPickerViewBad][_stickerPickerViewNeutral][_stickerPickerViewGood]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(_stickerPickerViewBad,_stickerPickerViewNeutral,_stickerPickerViewGood)]];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_stickerPickerViewBad]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(_stickerPickerViewBad)]];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_stickerPickerViewNeutral]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(_stickerPickerViewNeutral)]];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_stickerPickerViewGood]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(_stickerPickerViewGood)]];

    CGSize contentSize = _stickerPickerViewNeutral.intrinsicContentSize;
    [_scrollView setAlwaysBounceHorizontal:YES];
    //[_scrollView setContentOffset:CGPointMake(contentSize.width, 0.0) animated:NO];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
}
- (CGSize) intrinsicContentSize {
    if (_stickerPickerViewNeutral) {
        return [_stickerPickerViewNeutral intrinsicContentSize];
    }
    return CGSizeZero;
}
#pragma mark - Sticker Picker Delegate Methods
- (void) stickerPicker:(STStickerPickerView *)stickerPicker stickerPicked:(STSticker *)sticker {
    CGSize mySize = _scrollView.frame.size;
    CGSize stickerSize = stickerPicker.frame.size;
    NSLog(@"My size: %@ PickerSize: %@ ContentSize: %@",NSStringFromCGSize(mySize), NSStringFromCGSize(stickerSize), NSStringFromCGSize(_scrollView.contentSize));
}
@end
