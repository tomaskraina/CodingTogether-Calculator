//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Tom Kraina on 31.07.2012.
//  Copyright (c) 2012 Tom Kraina. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CalculatorBrainErrorCodeNoError = 0,
    CalculatorBrainErrorCodeDivisionByZero,
    CalculatorBrainErrorCodeSquareRootOfANegativeNumber
} CalculatorBrainErrorCode;

@interface CalculatorBrain : NSObject
@property (readonly) id program;

- (void)pushOperand:(double)operand;
- (void)clearOperands;
- (void)pushVariable:(NSString *)variable;
- (void)popLastItem;
+ (NSSet *)supportedOperations;
// all the methods runProgram:, runProgram:usingVariableValues: and performOperation: return either NSNumber with result or NSString with an error description
- (id)performOperation:(NSString *)operation;
+ (id)runProgram:(id)program;
+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSString *)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
