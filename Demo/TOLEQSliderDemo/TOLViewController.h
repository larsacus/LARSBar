//
//  TOLViewController.h
//  TOLEQSliderDemo
//
//  Created by Lars Anderson on 4/23/13.
//  Copyright (c) 2013 theonlylars. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TOLEQSlider;

@interface TOLViewController : UIViewController
@property (weak, nonatomic) IBOutlet TOLEQSlider *eqSlider;
@property (weak, nonatomic) IBOutlet UIImageView *sliderFrame;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *frameHeightConstraint;

@end
