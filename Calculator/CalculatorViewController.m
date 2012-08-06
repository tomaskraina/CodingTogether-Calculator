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
@synthesize testVariableValues = _testVariableValues;
@synthesize variablesDisplay = _variablesDisplay;


- (CalculatorBrain *)brain
{
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (void)setTestVariableValues:(NSDictionary *)testVariableValues
{
    _testVariableValues = testVariableValues;
    
    // update variablesDisplay
    NSMutableString *text = [[NSMutableString alloc] init];
    for (NSString *variable in self.testVariableValues) {
        [text appendFormat:@"%@ = %g, ", variable, [[self.testVariableValues objectForKey:variable] doubleValue]];
    }
    
    self.variablesDisplay.text = [text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
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

- (void)doCalculation {
    self.historyDisplay.text = [NSString stringWithFormat:@"%@ =", [CalculatorBrain descriptionOfProgram:self.brain.program]];
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    [self removeEqualsSignFromHistoryDisplay];
    self.historyDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    [self.brain performOperation:operation];
    [self doCalculation];
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
    if (self.userIsInTheMiddleOfEnteringANumber) {
        int textLength = self.display.text.length;
        self.display.text = [self.display.text substringToIndex:--textLength];
        if (textLength == 0) {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    } else {
        [self.brain popLastItem];
        [self doCalculation];
    }
}
- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    [self.brain pushVariable:[sender currentTitle]];
    self.display.text = [sender currentTitle];
}

- (IBAction)testCasePressed:(UIButton *)sender {
    if ([[sender currentTitle] isEqualToString:@"T1"]) {
        self.testVariableValues = nil;
    }
    else if ([[sender currentTitle] isEqualToString:@"T2"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"x", [NSNumber numberWithDouble:-.567], @"y", [NSNumber numberWithInt:56], @"z", nil];
    }
    
    [self doCalculation];
}

@end
