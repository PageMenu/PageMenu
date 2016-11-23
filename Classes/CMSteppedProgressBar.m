//
//  CMSteppedProgressBar.m
//
//  Created by Mycose on 12/03/2015.
//  Copyright (c) 2015 Mycose. All rights reserved.
//

#import "CMSteppedProgressBar.h"

@interface CMSteppedProgressBar()
@property (nonatomic, assign) BOOL isAnimated;
@property (nonatomic, strong) NSArray* views;
@property (nonatomic, assign) NSInteger futureStep;
@property (nonatomic, strong) NSArray* filledViews;
@end

@implementation CMSteppedProgressBar

#pragma mark -  Life

- (void)commonInit {
    self.animDuration = 0.6f;
    self.dotsWidth = 20.f;
    self.linesHeight = 5.f;
    self.barColor = [UIColor grayColor];
    self.tintColor = [UIColor whiteColor];
    self.animOption = UIViewAnimationOptionCurveEaseIn;
    self.isAnimated = NO;
    self.futureStep = -1;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)setNumberOfSteps:(NSUInteger)nbSteps {
    _numberOfSteps = nbSteps;
    [self prepareViews];
    [self setCurrentStep:0];
}

- (void)animateViewFromIndex:(NSUInteger)index toIndex:(NSUInteger)endIndex andInterval:(CGFloat)interval {
    if (index > endIndex) {
        self.isAnimated = NO;
        if (self.futureStep != -1) {
            NSInteger step = self.futureStep;
            self.futureStep = -1;
            [self setCurrentStep:step];
        }
        return;
    }
    [UIView animateWithDuration:interval delay:0.f options:self.animOption animations:^{
        self.isAnimated = YES;
        UIView* filledDot = [self.filledViews objectAtIndex:index];
        UIView* notFilledDot = [self.views objectAtIndex:index];
        
        [filledDot setFrame:CGRectMake(filledDot.frame.origin.x, filledDot.frame.origin.y, notFilledDot.frame.size.width, filledDot.frame.size.height)];
    }completion:^(BOOL finished){
        [self animateViewFromIndex:index+1 toIndex:endIndex andInterval:interval];
    }];
}

- (void)animateViewInvertFromIndex:(NSUInteger)index toIndex:(NSUInteger)endIndex andInterval:(CGFloat)interval {
    if (index <= endIndex) {
        self.isAnimated = NO;
        if (self.futureStep != -1) {
            NSInteger step = self.futureStep;
            self.futureStep = -1;
            [self setCurrentStep:step];
        }
        return;
    }
    [UIView animateWithDuration:interval delay:0.f options:self.animOption animations:^{
        self.isAnimated = YES;
        UIView* filledDot = [self.filledViews objectAtIndex:index];
        [filledDot setFrame:CGRectMake(filledDot.frame.origin.x, filledDot.frame.origin.y, 0, filledDot.frame.size.height)];
    }completion:^(BOOL finished){
        [self animateViewInvertFromIndex:index-1 toIndex:endIndex andInterval:interval];
    }];
}

- (void)setCurrentStep:(NSUInteger)currentStep {
    if (self.isAnimated == NO) {
        if (currentStep < self.numberOfSteps) {
            if (currentStep != _currentStep) {
                if (_currentStep < currentStep)
                {
                    if (currentStep == 0) {
                        [[self.views objectAtIndex:0] setBackgroundColor:self.tintColor];
                    } else {
                        NSUInteger diff = currentStep - _currentStep;
                        [self animateViewFromIndex:_currentStep*2 toIndex:(_currentStep*2)+diff*2 andInterval:self.animDuration/(CGFloat)diff];
                    }
                }
                else {
                    if (_currentStep == -1) {
                        [[self.views objectAtIndex:0] setBackgroundColor:self.tintColor];
                    } else {
                        NSUInteger diff = _currentStep - currentStep;
                        [self animateViewInvertFromIndex:_currentStep*2 toIndex:(_currentStep*2)-diff*2 andInterval:self.animDuration/(CGFloat)diff];
                    }
                }
            }
            _currentStep = currentStep;
        }
        
    }
    else {
        self.futureStep = currentStep;
    }
}

- (void)nextStep {
    if (self.currentStep != self.numberOfSteps)
        [self setCurrentStep:self.currentStep+1];
}

- (void)prevStep {
    if (self.currentStep != -1)
        [self setCurrentStep:self.currentStep-1];
}

- (void)stepBtnClicked:(id)sender
{
    UITapGestureRecognizer *gesture = sender;
    [self.delegate steppedBar:self didSelectIndex:[gesture.view tag]];
}

- (void) prepareViews {
    NSMutableArray* aviews = [[NSMutableArray alloc] init];
    NSMutableArray* afilledViews = [[NSMutableArray alloc] init];
    
    CGFloat padding = (self.frame.size.width-(self.numberOfSteps*self.dotsWidth))/(self.numberOfSteps+1);
    for (int i = 0; i < self.numberOfSteps; i++) {
        UIView *round = [[UIView alloc] initWithFrame:CGRectMake((i*self.dotsWidth)+((i+1)*padding), self.frame.size.height/2-self.dotsWidth/2, self.dotsWidth, self.dotsWidth)];
        round.tag = i;
        round.layer.cornerRadius = self.dotsWidth/2;
        if (i == 0)
            round.backgroundColor = self.tintColor;
        else
            round.backgroundColor = self.barColor;
        
        UIView* filledround = [[UIView alloc] initWithFrame:CGRectMake((i*self.dotsWidth)+((i+1)*padding), self.frame.size.height/2-self.dotsWidth/2, 0, self.dotsWidth)];
        filledround.backgroundColor = self.tintColor;
        filledround.layer.cornerRadius = self.dotsWidth/2;
        filledround.layer.masksToBounds = NO;
        filledround.userInteractionEnabled = NO;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stepBtnClicked:)];
        [round addGestureRecognizer:recognizer];
        
        [afilledViews addObject:filledround];
        [aviews addObject:round];
        if (i < self.numberOfSteps-1) {
            UIView* line = [[UIView alloc] initWithFrame:CGRectMake((round.frame.origin.x+round.frame.size.width)-1, self.frame.size.height/2-self.linesHeight/2, padding+2, self.linesHeight)];
            line.backgroundColor = self.barColor;
            [self addSubview:line];
            [aviews addObject:line];
            
            UIView* filledline = [[UIView alloc] initWithFrame:CGRectMake((round.frame.origin.x+round.frame.size.width)-1, self.frame.size.height/2-self.linesHeight/2, 0, self.linesHeight)];
            filledline.backgroundColor = self.tintColor;
            [self addSubview:filledline];
            [afilledViews addObject:filledline];
        }
        [self addSubview:round];
        [self addSubview:filledround];
    }
    self.views = aviews;
    self.filledViews = afilledViews;
}


@end
