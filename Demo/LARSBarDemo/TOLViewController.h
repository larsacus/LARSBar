//
//  TOLViewController.h
//  LARSBarDemo
//
//  Created by Lars Anderson on 4/23/13.
//  Copyright (c) 2013 theonlylars. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LARSBar;

@interface TOLViewController : UIViewController
@property (weak, nonatomic) IBOutlet LARSBar *eqSlider;
@property (weak, nonatomic) IBOutlet UIImageView *sliderFrame;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *frameHeightConstraint;

@end
