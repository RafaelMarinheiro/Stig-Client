//
//  STDropperView.h
//  Stig
//
//  Created by Rafael Farias Marinheiro on 27/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    STDropperViewStateHidden,
    STDropperViewStateAnimating,
    STDropperViewStateBasicInformation,
    STDropperViewStateDragging,
    STDropperViewStateFullInformation
} STDropperViewState;

@interface STDropperView : UIView

@property (nonatomic, weak) IBOutlet UILabel * placeNameLabel;
@property (nonatomic, weak) IBOutlet UIButton * musicButton;
@property (nonatomic, weak) IBOutlet UIButton * drinkButton;
@property (nonatomic, weak) IBOutlet UIButton * moneyButton;
@property (nonatomic, weak) IBOutlet UIButton * queueButton;
@property (nonatomic, weak) IBOutlet UIButton * peopleButton;
@property (nonatomic, weak) IBOutlet UIButton * accessButton;
@property (nonatomic, weak) IBOutlet UIImage * backgroundImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint;
@property (nonatomic, readonly) STDropperViewState state;

-(void) hide: (void (^)(BOOL completed)) completion;
-(void) showBasicInformation: (void (^)(BOOL completed)) completion;

@end
