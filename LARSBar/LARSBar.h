//
//  LARSBar.h
//  LARSBarDemo
//
//  Created by Lars Anderson on 4/23/13.
//  Copyright (c) 2013 theonlylars. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LARSBar : UISlider

/** The value for the left channel eq in the range of 0 to 1.
 
 @warning This value is clipped at 1.
 */
@property (nonatomic, assign) CGFloat leftChannelLevel;

/** The value for the right channel eq in the range of 0 to 1.
 
 @warning This value is clipped at 1.
 */
@property (nonatomic, assign) CGFloat rightChannelLevel;

/** The inactive color for the eq. This is the color that the eq
    light takes on past the right side of the slider thumb knob.
 */
@property (nonatomic, strong) UIColor *inactiveColor;

/** The active color for the eq when it is available to be lit up.
    This is the color that the eq light takes on before the slider
    thumb knob.
 */
@property (nonatomic, strong) UIColor *activeColor;

/** The EQ light glow colors. The number of light sections the
    light takes on depends on how many colors you pass in here.
 */
@property (nonatomic, copy) NSArray *glowColors;

@end
