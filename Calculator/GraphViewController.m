//
//  GraphViewController.m
//  Calculator
//
//  Created by Tom Kraina on 16.08.2012.
//  Copyright (c) 2012 Tom Kraina. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"

@interface GraphViewController()
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

- (void)setProgram:(id)program
{
    _program = program;
    [self.graphView setNeedsDisplay];
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:graphView action:@selector(pinch:)];
    [graphView addGestureRecognizer:pinchRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:graphView action:@selector(pan:)];
    [graphView addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *trippleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:graphView action:@selector(trippleTap:)];
    trippleTapRecognizer.numberOfTapsRequired = 3;
    [graphView addGestureRecognizer:trippleTapRecognizer];
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
    self.descriptionLabel.text = [NSString stringWithFormat:@"y = %@", [CalculatorBrain descriptionOfProgram:self.program]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.descriptionLabel = nil;
    self.graphView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

#pragma mark - GraphViewDataSource

- (NSNumber *)graphView:(GraphView *)graphView yAxisValueForXAxisValue:(NSNumber *)xValue
{    
    NSDictionary *variableValues = [NSDictionary dictionaryWithObject:xValue forKey:@"x"];
    NSNumber *yValue = [CalculatorBrain runProgram:self.program usingVariableValues:variableValues];
    return yValue;
}

@end
