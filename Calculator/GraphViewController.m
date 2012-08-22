//
//  GraphViewController.m
//  Calculator
//
//  Created by Tom Kraina on 16.08.2012.
//  Copyright (c) 2012 Tom Kraina. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"

@interface GraphViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController
@synthesize descriptionLabel = _descriptionLabel;
@synthesize graphView = _graphView;
@synthesize program = _program;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.graphView.datasource = self;
    self.graphView.scale = 10;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // show description of program
    self.descriptionLabel.text = [CalculatorBrain descriptionOfProgram:self.program];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.descriptionLabel = nil;
    self.graphView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - GraphViewDataSource

- (NSNumber *)graphView:(GraphView *)graphView yAxisValueForXAxisValue:(NSNumber *)xValue
{    
    NSDictionary *variableValues = [NSDictionary dictionaryWithObject:xValue forKey:@"x"];
    NSNumber *yValue = [CalculatorBrain runProgram:self.program usingVariableValues:variableValues];
    return yValue;
}

@end
