//
//  ViewController.m
//  FB Home
//
//  Created by Mox Soini on 24.8.2013.
//  Copyright (c) 2013 Mox Soini. All rights reserved.
//

#import "ViewController.h"
#include "ActionPageController.h"

@interface ViewController () //<UIDynamicAnimatorDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIImageView *rightActionButton;
@property (weak, nonatomic) IBOutlet UIImageView *leftActionButton;
@property (weak, nonatomic) IBOutlet UIImageView *topActionButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

// Home
@property (nonatomic) BOOL buttonDragging;
@property (retain, strong, nonatomic) UIDynamicAnimator *animator;
@property (retain, strong, nonatomic) UISnapBehavior *snap;
@property (retain, strong, nonatomic) UISnapBehavior *snapLeft;
@property (retain, strong, nonatomic) UISnapBehavior *snapRight;
@property (retain, strong, nonatomic) UISnapBehavior *snapTop;
@property (retain, strong, nonatomic) UIDynamicItemBehavior *b;

@property (nonatomic) CGPoint startTarget;
@property (nonatomic) CGPoint rightTarget;
@property (nonatomic) CGPoint leftTarget;
@property (nonatomic) CGPoint topTarget;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self becomeFirstResponder];

    self.buttonDragging = NO;
    
    UIImage *bgImage = [UIImage imageNamed:@"Rain-640x1136.jpg"];
    self.view.layer.contents = (id) bgImage.CGImage;

    // Initial position setup
    [self adjustHeight:self.startButton];
    [self adjustHeight:self.leftActionButton];
    [self adjustHeight:self.rightActionButton];
    [self adjustHeight:self.topActionButton];
    self.leftTarget = self.leftActionButton.center;
    self.rightTarget = self.rightActionButton.center;
    self.topTarget = self.topActionButton.center;
    self.startTarget = self.startButton.center;
    self.leftActionButton.alpha = 0;
    self.rightActionButton.alpha = 0;
    self.topActionButton.alpha = 0;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterLongStyle];
    NSString *datestr = [df stringFromDate:[NSDate date]];
    [df setDateStyle:NSDateFormatterNoStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    NSString *timestr = [df stringFromDate:[NSDate date]];
    
    [self setShadow:self.timeLabel];
    [self setShadow:self.dateLabel];
    
    self.timeLabel.text = timestr;
    self.dateLabel.text = datestr;
        
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    // Behaviour – disable rotation
    self.b = [[UIDynamicItemBehavior alloc] initWithItems:@[self.leftActionButton, self.rightActionButton, self.topActionButton]];
    [self.b setAllowsRotation:NO];
    [self.animator addBehavior:self.b];
    
    // Snapping
    self.snap = [[UISnapBehavior alloc] initWithItem:self.startButton snapToPoint:self.startButton.center];
    [self.snap setDamping:0.3];

    [self enableDynamics];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void) setShadow:(UIView *)v
{
    v.layer.shadowColor = [UIColor blackColor].CGColor;
    v.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    v.layer.shadowRadius = 2.0;
    v.layer.shadowOpacity = 0.8;
    v.layer.masksToBounds = NO;
}

- (void) adjustHeight:(UIView *)v
{
    CGFloat heightAdj = self.view.bounds.size.height - 568;
    CGPoint pt = v.center;
    pt.y += heightAdj;
    v.center = pt;
}

- (void) enableDynamics
{
    [self.animator addBehavior:self.snap];
    
    [UIView animateWithDuration:0.15 animations:^{
        self.leftActionButton.alpha = 0;
        self.rightActionButton.alpha = 0;
        self.topActionButton.alpha = 0;
        self.dateLabel.alpha = 0;
        self.timeLabel.alpha = 0;
    }];
    [self.animator removeBehavior:self.snapLeft];
    [self.animator removeBehavior:self.snapRight];
    [self.animator removeBehavior:self.snapTop];
    self.snapLeft =  [[UISnapBehavior alloc] initWithItem:self.leftActionButton snapToPoint:self.startTarget];
    self.snapRight = [[UISnapBehavior alloc] initWithItem:self.rightActionButton snapToPoint:self.startTarget];
    self.snapTop =   [[UISnapBehavior alloc] initWithItem:self.topActionButton snapToPoint:self.startTarget];
    [self.animator addBehavior:self.snapLeft];
    [self.animator addBehavior:self.snapRight];
    [self.animator addBehavior:self.snapTop];

    [self.b addItem:self.startButton];
}

- (void) disableDynamics
{
    [self.animator removeBehavior:self.snap];
    
    [UIView animateWithDuration:0.15 animations:^{
        self.leftActionButton.alpha = 1.0;
        self.rightActionButton.alpha = 1.0;
        self.topActionButton.alpha = 1.0;
        self.dateLabel.alpha = 1.0;
        self.timeLabel.alpha = 1.0;
    }];
    [self.animator removeBehavior:self.snapLeft];
    [self.animator removeBehavior:self.snapRight];
    [self.animator removeBehavior:self.snapTop];
    self.snapLeft =  [[UISnapBehavior alloc] initWithItem:self.leftActionButton snapToPoint:self.leftTarget];
    self.snapRight = [[UISnapBehavior alloc] initWithItem:self.rightActionButton snapToPoint:self.rightTarget];
    self.snapTop =   [[UISnapBehavior alloc] initWithItem:self.topActionButton snapToPoint:self.topTarget];
    //[self.snapLeft setDamping:0.4];
    [self.animator addBehavior:self.snapLeft];
    [self.animator addBehavior:self.snapRight];
    [self.animator addBehavior:self.snapTop];
    
    [self.b removeItem:self.startButton];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    pt.x -= self.startButton.frame.origin.x;
    pt.y -= self.startButton.frame.origin.y;
    if ([self.startButton pointInside:pt withEvent:nil]) {
        self.buttonDragging = YES;
        [self disableDynamics];
        NSLog(@"TouchDown on startButton: %.2f %.2f / %.2f %.2f", pt.x, pt.y,
              self.startButton.frame.origin.x,
              self.startButton.frame.origin.y);
    }
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (self.buttonDragging) {
        CGPoint pt = [[touches anyObject] locationInView:self.view];
        self.startButton.center = pt;
    } 
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.buttonDragging) {
        CGPoint pt = [[touches anyObject] locationInView:self.view];
        //NSLog(@"Action button test: %.0f %.0f", pt.x, pt.y);
        if ([self actionTest:self.leftActionButton point:pt]) [self viewActivate:@"Left"];
        if ([self actionTest:self.rightActionButton point:pt]) [self viewActivate:@"Right"];
        if ([self actionTest:self.topActionButton point:pt]) [self viewActivate:@"Top"];
        self.buttonDragging = NO;
        [self enableDynamics];
    }
}

- (BOOL)actionTest:(UIView *)v point:(CGPoint)p
{
    p.x -= v.frame.origin.x;
    p.y -= v.frame.origin.y;
    return [v pointInside:p withEvent:nil];
}

- (void) viewActivate:(NSString *)message
{
    NSLog(@"Action activated: %@.", message);
    [self performSegueWithIdentifier:@"actionPageSeque" sender:message];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"actionPageSeque"])
    {
        ActionPageController *c = [segue destinationViewController];
        [c setTitle:(NSString *)sender];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
