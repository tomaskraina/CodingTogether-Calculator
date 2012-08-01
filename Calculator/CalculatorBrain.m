//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Tom Kraina on 31.07.2012.
//  Copyright (c) 2012 Tom Kraina. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain ()
@property (strong, nonatomic) NSMutableArray *programStack;
@end

@implementation CalculatorBrain
@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (id)program
{
    return [self.program copy];
}

- (NSString *)description
{
    return self.programStack.description;
}

- (void)pushOperand:(double)operand
{
    [self.program addObject:[NSNumber numberWithDouble:operand]];
}


- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    return @"Implement this in assignment #2";
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    // pop operand off the stack
    // if operation, need to recursively evaluate
    return result;
}

+ (double)runProgram:(id)program
{
    return [self popOperandOffStack:[program mutableCopy]];
}

/*    
    double result = 0;
    
    if ([operation isEqualToString:@"+"]) {
        result = [self popOperand] + [self popOperand];
    }
    else if ([operation isEqualToString:@"*"]) {
        result = [self popOperand] * [self popOperand];
    }
    else if ([operation isEqualToString:@"-"]) {
        double subtrahend = [self popOperand];
        result = [self popOperand] - subtrahend;
    }
    else if ([operation isEqualToString:@"/"]) {
        double divisor = [self popOperand];
        if (divisor) {
            result = [self popOperand] / divisor;
        }
    }
    else if ([operation isEqualToString:@"sin"]) {
        result = sin([self popOperand]);
    }
    else if ([operation isEqualToString:@"cos"]) {
        result = cos([self popOperand]);
    }
    else if ([operation isEqualToString:@"sqrt"]) {
        result = sqrt([self popOperand]);
    }
    else if ([operation isEqualToString:@"π"]) {
        result = M_PI;
    }
    else if ([operation isEqualToString:@"e"]) {
        result = M_E;
    }
    else if ([operation isEqualToString:@"log"]) {
        result = log([self popOperand]);
    }
    else if ([operation isEqualToString:@"+/-"]) {
        result = [self popOperand] * -1;
    }
    
    [self pushOperand:result];
    
    return result;
}
*/

- (void)clearOperands
{
    [self.programStack removeAllObjects];
}

@end
