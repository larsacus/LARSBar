//
//  TOLViewController.m
//  LARSBarDemo
//
//  Created by Lars Anderson on 4/23/13.
//  Copyright (c) 2013 theonlylars. All rights reserved.
//

#import "TOLViewController.h"
#import "LARSBar.h"
#import "Novocaine.h"

@interface TOLViewController ()

@property (nonatomic, retain) Novocaine *audioManager;

@end

@implementation TOLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImage *backgroundImage = [UIImage imageNamed:@"eq-slider-border"];
    
    self.frameHeightConstraint.constant = backgroundImage.size.height;
    
    backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(0.f, 12.f, 0.f, 12.f)];
    self.sliderFrame.image = backgroundImage;
    
    UIImage *sliderKnob = [UIImage imageNamed:@"slider-knob"];
    [self.eqSlider setThumbImage:sliderKnob forState:UIControlStateNormal];
    
    self.audioManager = [Novocaine audioManager];
    [self.audioManager setSamplingRate:1/60.f];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.14 green:0.15 blue:0.16 alpha:1.0];
    
    // MEASURE SOME DECIBELS!
    // ==================================================
    __block CGFloat dbVal = 0.0f;
    typeof(self) __weak weakSelf = self;
    [self.audioManager setInputBlock:^(CGFloat *data, UInt32 numFrames, UInt32 numChannels) {
        vDSP_vsq(data, 1, data, 1, numFrames*numChannels);
        CGFloat meanVal = 0.0f;
        vDSP_meanv(data, 1, &meanVal, numFrames*numChannels);
        CGFloat one = 1.0;
        vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);
        dbVal = dbVal + 0.2f*(meanVal - dbVal);
        if (isnan(dbVal)) {
            dbVal = 0.f;
        }
        
        CGFloat max = 0.f;
        CGFloat min = -60.f;
        CGFloat percentage = 1.f-dbVal/(min-max);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.eqSlider.leftChannelLevel = percentage;
            weakSelf.eqSlider.rightChannelLevel = percentage;
        });
        
//        NSLog(@"Decibel level: %f (%f)\n", dbVal, percentage);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
