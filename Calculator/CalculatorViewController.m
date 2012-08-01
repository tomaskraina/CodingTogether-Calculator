//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Tom Kraina on 31.07.2012.
//  Copyright (c) 2012 Tom Kraina. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (strong, nonatomic) CalculatorBrain *brain;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize historyDisplay = _historyDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;


- (CalculatorBrain *)brain
{
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (void)removeEqualsSignFromHistoryDisplay
{
    self.historyDisplay.text = [self.historyDisplay.text stringByReplacingOccurrencesOfString:@"=" withString:@""];
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    }
    else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    
}

- (IBAction)pointPressed {
    BOOL displayContainsPoint = [self.display.text rangeOfString:@"."].location != NSNotFound;
    if (!displayContainsPoint) {
        self.display.text = [self.display.text stringByAppendingString:@"."];
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    [self removeEqualsSignFromHistoryDisplay];
    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingFormat:@"%@ ", self.display.text];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    [self removeEqualsSignFromHistoryDisplay];
    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingFormat:@"%@ = ", operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)changeSignPressed:(UIButton *)sender {
    if ([self.display.text isEqualToString:@"0"]) {
        // changing a sign of zero isn't valid - do nothing
        return;
    }
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        double valueWithChangedSign = [self.display.text doubleValue] * -1;
        self.display.text = [NSString stringWithFormat:@"%g", valueWithChangedSign];
    }
    else {
        [self operationPressed:sender];
    }
}

- (IBAction)clearPressed {
    self.historyDisplay.text = @"";
    self.display.text = @"0";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain clearOperands];
}

- (IBAction)backspacePressed {
    int textLength = self.display.text.length;
    self.display.text = [self.display.text substringToIndex:--textLength];
    if (textLength == 0) {
        self.display.text = @"0";
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
}

@end
