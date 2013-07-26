//
//  STStickerListView.h
//  Stig
//
//  Created by Lucas Tenório on 26/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STStickerListView : UIView
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *stickerList;

@end
