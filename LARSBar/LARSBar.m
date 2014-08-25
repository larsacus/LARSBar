//
//  LARSBar.m
//  LARSBarDemo
//
//  Created by Lars Anderson on 4/23/13.
//  Copyright (c) 2013 theonlylars. All rights reserved.
//

#import "LARSBar.h"
#import <QuartzCore/QuartzCore.h>

const CGSize TOLLightLayerSize = {10.f, 12.f};
const CGFloat TOLTargetLightPadding = -3.f;

@interface TOLEQLight : CALayer

@property (nonatomic, assign, getter = isActive) BOOL active;
@property (nonatomic, assign) CGFloat lightState;
@property (nonatomic, strong) UIColor *glowColor;
@property (nonatomic, strong) UIColor *inactiveColor;
@property (nonatomic, strong) UIColor *activeColor;

@end

@interface LARSBar ()
@property (nonatomic, strong) NSMutableArray *leftChannelLightLayers;
@property (nonatomic, strong) NSMutableArray *rightChannelLightLayers;
@end

@implementation LARSBar

- (instancetype)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    
    [self setup];
    
    return [super awakeAfterUsingCoder:aDecoder];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    UIImage *emptyImage = [[UIImage alloc] init];
    
    [self setMinimumTrackImage:emptyImage
                      forState:UIControlStateNormal];
    [self setMaximumTrackImage:emptyImage
                      forState:UIControlStateNormal];
    
    self.leftChannelLightLayers = [NSMutableArray array];
    self.rightChannelLightLayers = [NSMutableArray array];
    self.glowColors = @[[UIColor colorWithRed:0.00 green:0.90 blue:0.29 alpha:1.0],
                         [UIColor colorWithRed:1.00 green:0.82 blue:0.27 alpha:1.0],
                         [UIColor colorWithRed:1.00 green:0.38 blue:0.14 alpha:1.0],
                         [UIColor colorWithRed:1.00 green:0.00 blue:0.08 alpha:1.0]];
    
    self.leftChannelLevel = 0.5f;
    self.rightChannelLevel = 0.5f;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    NSInteger numberOfLights = floorf((CGRectGetWidth(self.bounds)-TOLTargetLightPadding)/(TOLLightLayerSize.width + TOLTargetLightPadding));
    CGFloat totalWidth = CGRectGetWidth(self.bounds);
    CGFloat lightWidth = TOLLightLayerSize.width;
    
    CGFloat actualPadding = roundf((totalWidth - numberOfLights*lightWidth)/(numberOfLights+1));
    
    [self updateLightArraysForNumberOfLights:numberOfLights
                                  lightWidth:lightWidth
                               actualPadding:actualPadding];
    
    [self setLightPercentage:self.leftChannelLevel
               forLightArray:self.leftChannelLightLayers];
    [self setLightPercentage:self.rightChannelLevel
               forLightArray:self.rightChannelLightLayers];
}

#pragma mark - Updating Lights
- (void)setLeftChannelLevel:(CGFloat)percentage{
    _leftChannelLevel = MIN(MAX(percentage, 0.f), 1.f);
    
    [self setLightPercentage:_leftChannelLevel
               forLightArray:self.leftChannelLightLayers];
}

- (void)setRightChannelLevel:(CGFloat)percentage{
    _rightChannelLevel = MIN(MAX(percentage, 0.f), 1.f);
    
    [self setLightPercentage:_rightChannelLevel
               forLightArray:self.rightChannelLightLayers];
}

- (void)setLightPercentage:(CGFloat)percentage forLightArray:(NSArray *)lightArray{
    CGFloat valuePercentage = self.value/self.maximumValue;
    CGFloat normalizedPercentage = percentage*valuePercentage;
    
    NSUInteger maxLight = floor(lightArray.count*normalizedPercentage);
    BOOL newLightState;
    
    for (NSUInteger lightNum = 0; lightNum < lightArray.count; lightNum++) {
        TOLEQLight *currentLight = lightArray[lightNum];
        
        if(lightNum < maxLight){
            newLightState = YES;
        }
        else{
            newLightState = NO;
        }
        
        if (currentLight.lightState != newLightState) {
            [currentLight setNeedsDisplay];
        }
        
        [currentLight setLightState:newLightState];
    }
}

#pragma mark - Light Layout

- (void)layoutLightNumber:(NSUInteger)lightNum
                   center:(CGPoint)center
             storageArray:(NSMutableArray *)storageArray
              totalLights:(NSInteger)totalLights{
    TOLEQLight *currentLight = nil;
    if (lightNum < storageArray.count) {
        currentLight = storageArray[lightNum];
    }
    else{
        currentLight = [[TOLEQLight alloc] init];
        currentLight.lightState = NO;
        
        if (self.activeColor != nil) {
            currentLight.activeColor = self.activeColor;
        }
        
        if (self.inactiveColor != nil) {
            currentLight.inactiveColor = self.inactiveColor;
        }
        
        currentLight.bounds = (CGRect){CGPointZero, TOLLightLayerSize};
        
        [storageArray addObject:currentLight];
    }
    
    if (self.activeColor != nil &&
        ([currentLight.activeColor isEqual:self.activeColor] == NO)) {
        currentLight.activeColor = self.activeColor;
        [currentLight setNeedsDisplay];
    }
    
    if (self.inactiveColor != nil &&
        ([currentLight.inactiveColor isEqual:self.inactiveColor] == NO)) {
        currentLight.inactiveColor = self.inactiveColor;
        [currentLight setNeedsDisplay];
    }
    
    CGFloat lightPercentage = [self lightPercentageForSliderValue];
    UIColor *colorForLight = [self colorForLightNum:lightNum
                                        totalLights:totalLights];
    BOOL lightState = [self lightStateForLightNumber:lightNum
                                         totalLights:totalLights
                                          percentage:lightPercentage];
    
    currentLight.position = center;
    if ([colorForLight isEqual:currentLight.glowColor] == NO) {
        currentLight.glowColor = colorForLight;
        [currentLight setNeedsDisplay];
    }
    
    if (lightState != currentLight.active) {
        currentLight.active = lightState;
        [currentLight setNeedsDisplay];
    }
    
    if ([currentLight.superlayer isEqual:self.layer] == NO) {
        [self.layer insertSublayer:currentLight atIndex:0];
    }
}

- (CGFloat)lightPercentageForSliderValue{
    CGFloat calculatedValue = (self.value-self.minimumValue)/(self.maximumValue-self.minimumValue);
    return MIN(MAX(calculatedValue, 0.f), 1.f);
}

- (BOOL)lightStateForLightNumber:(NSInteger)lightNumber
                     totalLights:(NSInteger)totalLights
                      percentage:(CGFloat)sliderPercentage{
    CGFloat lightPercentage = lightNumber/(CGFloat)totalLights;
    
    return (lightPercentage < sliderPercentage);
}

- (UIColor *)colorForLightNum:(NSInteger)lightNum totalLights:(NSInteger)totalLights{
    CGFloat lightPercentage = lightNum/(CGFloat)totalLights;
    CGFloat totalColors = self.glowColors.count;
    
    for (NSInteger colorNum = 1; colorNum <= totalColors; colorNum++) {
        CGFloat upperPercentage = (colorNum)/totalColors;
        CGFloat lowerPercentage = (colorNum-1)/totalColors;
        
        if ((lightPercentage < upperPercentage) &&
            (lightPercentage >= lowerPercentage)) {
            return self.glowColors[colorNum-1];
        }
    }
    
    return nil;
}

- (void)updateLightArraysForNumberOfLights:(NSUInteger)numberOfLights
                                lightWidth:(CGFloat)lightWidth
                             actualPadding:(CGFloat)actualPadding {
    if (self.leftChannelLightLayers.count > numberOfLights) {
        [self cleanUpLightLayers:self.leftChannelLightLayers
               forNumberOfLights:numberOfLights];
    }
    
    if (self.rightChannelLightLayers.count > numberOfLights) {
        [self cleanUpLightLayers:self.rightChannelLightLayers
               forNumberOfLights:numberOfLights];
    }
    
    for (NSUInteger lightNum = 0; lightNum < numberOfLights; lightNum++) {
        CGFloat x = actualPadding*(lightNum+1) + lightWidth*lightNum + (lightWidth/2);
        CGFloat centerLineHeight = CGRectGetHeight(self.bounds)/2;
        CGFloat yOffset = 2.f + TOLLightLayerSize.height/2;
        CGPoint topCenter = CGPointMake(x, centerLineHeight - yOffset);
        CGPoint bottomCenter = CGPointMake(x, centerLineHeight + yOffset);
        
        [self layoutLightNumber:lightNum
                         center:topCenter
                   storageArray:self.leftChannelLightLayers
                    totalLights:numberOfLights];
        
        [self layoutLightNumber:lightNum
                         center:bottomCenter
                   storageArray:self.rightChannelLightLayers
                    totalLights:numberOfLights];
    }
}

- (void)cleanUpLightLayers:(NSMutableArray *)lights forNumberOfLights:(NSInteger)numberOfLights{
    NSRange removeRange = NSMakeRange(numberOfLights, lights.count-numberOfLights);
    NSArray *cleanUpLayers = [lights subarrayWithRange:removeRange];
    [self cleanUpLightLayers:cleanUpLayers];
    [lights removeObjectsInRange:removeRange];
}

- (void)cleanUpLightLayers:(NSArray *)lights{
    for (CALayer *lightLayer in lights) {
        [lightLayer removeFromSuperlayer];
    }
}

@end

@implementation TOLEQLight

@dynamic lightState;

- (instancetype)init{
    self = [super init];
    if (self) {
        self.activeColor = [UIColor colorWithRed: 0.376 green: 0.4 blue: 0.416 alpha: 1];
        self.inactiveColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
        self.glowColor = [UIColor yellowColor];
        self.lightState = 1.f;
        self.active = YES;
        self.contentsScale = [[UIScreen mainScreen] scale];
//        self.drawsAsynchronously = YES; // Unsure how this might affect app performance, disabling
    }
    return self;
}

- (instancetype)initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    if (self) {
        if ([layer isKindOfClass:[TOLEQLight class]]) {
            TOLEQLight *lightLayer = (TOLEQLight *)layer;
            
            self.activeColor = lightLayer.activeColor;
            self.inactiveColor = lightLayer.inactiveColor;
            self.glowColor = lightLayer.glowColor;
            self.lightState = lightLayer.lightState;
            self.active = lightLayer.isActive;
            self.contentsScale = lightLayer.contentsScale;
        }
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:NSStringFromSelector(@selector(lightState))]) {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event {
    
    if ([event isEqualToString:NSStringFromSelector(@selector(lightState))]) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:event];
        NSValue *fromValue = [self.presentationLayer valueForKey:event];
        
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        anim.duration = 0.10;
        anim.fromValue = fromValue;
        
        return anim;
    }
    
    return [super actionForKey:event];
}

- (void)drawInContext:(CGContextRef)ctx{
    
    UIGraphicsPushContext(ctx);
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat lightRectRatio = floorf(width/2.f)/width;
    
    CGFloat sideDimension = MIN(lightRectRatio*width, lightRectRatio*height);
    
    CGRect lightRect = CGRectMake((width - lightRectRatio*width)/2.f,
                                  (height - lightRectRatio*height)/2.f,
                                  sideDimension,
                                  sideDimension);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    CGContextRef context = ctx;
    
    //// Color Declarations
    UIColor* activeOffFill = nil;
    if (self.lightState >= 1.f) {
        activeOffFill = self.glowColor;
    }
    else if(self.isActive){
        activeOffFill = self.activeColor;
    }
    else{
        activeOffFill = self.inactiveColor;
    }
    
    UIColor* strokeColor = [UIColor colorWithRed: 0.094 green: 0.102 blue: 0.102 alpha: 1];
    UIColor* underStrokeColor = [UIColor colorWithRed: 0.224 green: 0.227 blue: 0.231 alpha: 1];
    UIColor* lightGlowColor = [self.glowColor colorWithAlphaComponent:0.9f];
    UIColor* clearColor = [UIColor clearColor];
    
    //// Shadow Declarations
    UIColor* underStroke = underStrokeColor;
    CGSize underStrokeOffset = CGSizeMake(0.f, 1.f/scale);
    CGFloat underStrokeBlurRadius = 0;
    
    //// Frame Drawing
    UIBezierPath* lightFramePath = [UIBezierPath bezierPathWithOvalInRect:lightRect];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, underStrokeOffset, underStrokeBlurRadius, underStroke.CGColor);
    [activeOffFill setFill];
    [lightFramePath fill];
    CGContextRestoreGState(context);
    
    [strokeColor setStroke];
    lightFramePath.lineWidth = 1.f/scale;
    [lightFramePath stroke];
    
    //// Glow Drawing
    
    CGFloat endRadius = self.lightState * MAX(floorf(width/2.f), floorf(height/2.f));

    if (self.lightState > 0.f) {
        //// Gradient Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSArray* lightGlowGradientColors = [NSArray arrayWithObjects:
                                            (id)lightGlowColor.CGColor,
                                            (id)clearColor.CGColor, nil];
        CGFloat lightGlowGradientLocations[] = {0.f, 1.f};
        CGGradientRef lightGlowGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)lightGlowGradientColors, lightGlowGradientLocations);
        CGContextDrawRadialGradient(context, lightGlowGradient,
                                    CGPointMake(width/2.f, height/2.f - (1 - 1/scale)), 0.f,
                                    CGPointMake(width/2.f, height/2.f - (1 - 1/scale)), endRadius,
                                    kCGGradientDrawsBeforeStartLocation);
        
        //// Cleanup
        CGGradientRelease(lightGlowGradient);
        CGColorSpaceRelease(colorSpace);
    }
}

@end
