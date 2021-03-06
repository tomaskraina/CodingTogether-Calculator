//
//  GraphViewController.m
//  Calculator
//
//  Created by Tom Kraina on 16.08.2012.
//  Copyright (c) 2012 Tom Kraina. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"

@interface GraphViewController() <UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@end

@implementation GraphViewController
@synthesize descriptionLabel = _descriptionLabel;
@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
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

- (void)saveGraphViewProperties
{
    // save view's scale and origin to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:self.graphView.scale forKey:[NSString stringWithFormat:@"GraphView%i.scale", self.graphView.tag]];
    [defaults setDouble:self.graphView.origin.x forKey:[NSString stringWithFormat:@"GraphView%i.origin.x", self.graphView.tag]];
    [defaults setDouble:self.graphView.origin.y forKey:[NSString stringWithFormat:@"GraphView%i.origin.y", self.graphView.tag]];
}

- (void)loadGraphViewProperties
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.graphView.scale = [defaults doubleForKey:[NSString stringWithFormat:@"GraphView%i.scale", self.graphView.tag]];
    self.graphView.origin = CGPointMake([defaults doubleForKey:[NSString stringWithFormat:@"GraphView%i.origin.x", self.graphView.tag]], [defaults doubleForKey:[NSString stringWithFormat:@"GraphView%i.origin.y", self.graphView.tag]]);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.graphView.datasource = self;
    [self loadGraphViewProperties];
    
    self.splitViewController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveGraphViewProperties) name:UIApplicationDidEnterBackgroundNotification object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // show description of program
    self.descriptionLabel.text = [NSString stringWithFormat:@"y = %@", [CalculatorBrain descriptionOfProgram:self.program]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveGraphViewProperties];
}

- (void)viewDidUnload
{
    [self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.descriptionLabel = nil;
    self.graphView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
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

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems insertObject:barButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems removeObject:button];
    self.toolbar.items = toolbarItems;
}

#pragma mark - UISegmentedControl
- (IBAction)changeGraphMode:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.graphView.mode = GraphViewModeLine;
            break;
            
        case 1:
            self.graphView.mode = GraphViewModeDots;
            break;
    }
}

@end
