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
    return [self.programStack copy];
}

+ (NSSet *)twoOperandOperations
{
    static dispatch_once_t once;
    static NSSet *_supportedOperations;
    dispatch_once(&once, ^{
        _supportedOperations = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", nil];
    });
    return _supportedOperations;
}

+ (NSSet *)oneOperandOperations
{
    static dispatch_once_t once;
    static NSSet *_supportedOperations;
    dispatch_once(&once, ^{
        _supportedOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"log", @"sqrt", @"+/-", nil];
    });
    return _supportedOperations;
}

+ (NSSet *)noOperandOperations
{
    static dispatch_once_t once;
    static NSSet *_supportedOperations;
    dispatch_once(&once, ^{
        _supportedOperations = [[NSSet alloc] initWithObjects:@"π", @"e", nil];
    });
    return _supportedOperations;
}

+ (NSSet *)supportedOperations
{
    NSSet *supportedOperations = [[self class] noOperandOperations];
    supportedOperations = [supportedOperations setByAddingObjectsFromSet:[[self class] oneOperandOperations]];
    supportedOperations = [supportedOperations setByAddingObjectsFromSet:[[self class] twoOperandOperations]];
    
    return supportedOperations;
}

+ (NSSet *)associativeOperations
{
    // Associative operations we support are addition and multiplication
    // http://en.wikipedia.org/wiki/Associative_property
    
    static dispatch_once_t once;
    static NSSet *_associativeOperations;
    dispatch_once(&once, ^{
        _associativeOperations = [[NSSet alloc] initWithObjects:@"+", @"*", nil];
    });
    return _associativeOperations;
}

- (NSString *)description
{
    return self.programStack.description;
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

- (void)popLastItem
{
    if (self.programStack.count > 0) {
        [self.programStack removeLastObject];
    }
}

- (id)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack withParentOperation:(NSString *)parentOperation
{
    NSString *description;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    }
    
    // the top of stack can be: NSNumber or NSString: variable, symbol, function or operation
    if ([[self oneOperandOperations] containsObject:topOfStack]) {
        description = [NSString stringWithFormat:@"%@(%@)", topOfStack, [self descriptionOfTopOfStack:stack withParentOperation:topOfStack]];
    }
    else if ([[self twoOperandOperations] containsObject:topOfStack]) {
        id operand = [self descriptionOfTopOfStack:stack withParentOperation:topOfStack];
        description = [NSString stringWithFormat:@"%@ %@ %@", [self descriptionOfTopOfStack:stack withParentOperation:topOfStack], topOfStack, operand];
        // try to suppress reduntant parenthesis
        // add parenthesis around an expression only if it isn't neither the last expression nor associative expression with the parent's one
        // it doesn't support implicit order of operations
        if (stack.count > 0 && !([parentOperation isEqualToString:topOfStack] && [[self associativeOperations] containsObject:topOfStack])) {
            description = [NSString stringWithFormat:@"(%@)", description];
        }
    }
    else {
        description = [topOfStack description];
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    // descriptionOfTopOfStack:withParentOperation: works recursively but ignores elements on stack those no operation is applied
    // therefore, we must find those elements and separate them with commas
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    while (stack.count) {
        [elements addObject:[self descriptionOfTopOfStack:stack withParentOperation:nil]];
    }
    
    // the array of elements must be reversed to represent the order they were entered
    return [[[elements reverseObjectEnumerator] allObjects] componentsJoinedByString:@", "];
}

+ (NSNumber *)popOperandOffStack:(NSMutableArray *)stack error:(NSError **)error
{
    double result = 0;

    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    }
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [[self popOperandOffStack:stack error:error] doubleValue] + [[self popOperandOffStack:stack error:error] doubleValue];
        }
        else if ([operation isEqualToString:@"*"]) {
            result = [[self popOperandOffStack:stack error:error] doubleValue] * [[self popOperandOffStack:stack error:error] doubleValue];
        }
        else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [[self popOperandOffStack:stack error:error] doubleValue];
            result = [[self popOperandOffStack:stack error:error] doubleValue] - subtrahend;
        }
        else if ([operation isEqualToString:@"/"]) {
            double divisor = [[self popOperandOffStack:stack error:error] doubleValue];
            if (divisor) {
                result = [[self popOperandOffStack:stack error:error] doubleValue] / divisor;
            }
            else {
                NSDictionary *description = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Division by zero", @"Division by zero"), NSLocalizedDescriptionKey, nil];
                *error = [NSError errorWithDomain:@"CalculatorBrain" code:CalculatorBrainErrorCodeDivisionByZero userInfo:description];
            }
        }
        else if ([operation isEqualToString:@"sin"]) {
            result = sin([[self popOperandOffStack:stack error:error] doubleValue]);
        }
        else if ([operation isEqualToString:@"cos"]) {
            result = cos([[self popOperandOffStack:stack error:error] doubleValue]);
        }
        else if ([operation isEqualToString:@"sqrt"]) {
            double operand = [[self popOperandOffStack:stack error:error] doubleValue];
            if (operand >= 0) {
                result = sqrt(operand);
            }
            else {
                NSDictionary *description = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Square root of negative number", @"Square root of a negative number"), NSLocalizedDescriptionKey, nil];
                *error = [NSError errorWithDomain:@"CalculatorBrain" code:CalculatorBrainErrorCodeSquareRootOfANegativeNumber userInfo:description];
            }
        }
        else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        }
        else if ([operation isEqualToString:@"e"]) {
            result = M_E;
        }
        else if ([operation isEqualToString:@"log"]) {
            result = log([[self popOperandOffStack:stack error:error] doubleValue]);
        }
        else if ([operation isEqualToString:@"+/-"]) {
            result = [[self popOperandOffStack:stack error:error] doubleValue] * -1;
        }
    }
    
    return [NSNumber numberWithDouble:result];
}

+ (BOOL)isOperandVariable:(id)operand
{
    return [operand isKindOfClass:[NSString class]] && ![[CalculatorBrain supportedOperations] containsObject:operand];
}

+ (id)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    // Swap all variables for zeros
    for (id element in stack) {
        if ([self isOperandVariable:element]) {
            [stack replaceObjectAtIndex:[stack indexOfObject:element] withObject:[NSNumber numberWithInt:0]];
        }
    }
    
    // Using NSError because it's cleaner way how to deal with errors
    NSError *error;
    id result = [self popOperandOffStack:stack error:&error];
    // Hypothetically, it can happen that the result is 0.0 thus error.code must be tested as well
    if ([result doubleValue] == 0.0 && error.code != CalculatorBrainErrorCodeNoError) {
        result = error.localizedDescription;
    }
    
    return result;
}

+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    // try to swap all variables for given values
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        for (int i = 0; i < [stack count]; i++) {
            id operand = [stack objectAtIndex:i];
            // replace only if there's a valid value for that particular variable
            if ([[self class] isOperandVariable:operand] && [[variableValues objectForKey:operand] isKindOfClass:[NSNumber class]]) {
                NSNumber *value = [variableValues objectForKey:operand];
                [stack replaceObjectAtIndex:i withObject:value];
            }
        }
    }
    
    return [CalculatorBrain runProgram:stack];
}

- (void)clearOperands
{
    [self.programStack removeAllObjects];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet *usedVariables = [[NSMutableSet alloc] init];
    
    if ([program isKindOfClass:[NSArray class]]) {
        for (id object in program) {
            // filter the variables
            if ([CalculatorBrain isOperandVariable:object]) {
                [usedVariables addObject:object];
            }
        }
    }
    
    return [usedVariables count] ? [usedVariables copy] : nil;
}

@end
