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

    _buttonDragging = NO;
    
    UIImage *bgImage = [UIImage imageNamed:@"Rain-640x1136.jpg"];
    self.view.layer.contents = (id) bgImage.CGImage;

    // Initial position setup
    [self adjustHeight:_startButton];
    [self adjustHeight:_leftActionButton];
    [self adjustHeight:_rightActionButton];
    [self adjustHeight:_topActionButton];
    _leftTarget = _leftActionButton.center;
    _rightTarget = _rightActionButton.center;
    _topTarget = _topActionButton.center;
    _startTarget = _startButton.center;
    _leftActionButton.alpha = 0;
    _rightActionButton.alpha = 0;
    _topActionButton.alpha = 0;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterLongStyle];
    NSString *datestr = [df stringFromDate:[NSDate date]];
    [df setDateStyle:NSDateFormatterNoStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    NSString *timestr = [df stringFromDate:[NSDate date]];
    
    [self setShadow:_timeLabel];
    [self setShadow:_dateLabel];
    
    _timeLabel.text = timestr;
    _dateLabel.text = datestr;
        
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    // Behaviour – disable rotation
    _b = [[UIDynamicItemBehavior alloc] initWithItems:@[_leftActionButton, _rightActionButton, _topActionButton]];
    [_b setAllowsRotation:NO];
    [_animator addBehavior:_b];
    
    // Snapping
    _snap = [[UISnapBehavior alloc] initWithItem:_startButton snapToPoint:_startButton.center];
    [_snap setDamping:0.3];

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
    [_animator addBehavior:_snap];
    
    [UIView animateWithDuration:0.15 animations:^{
        _leftActionButton.alpha = 0;
        _rightActionButton.alpha = 0;
        _topActionButton.alpha = 0;
        _dateLabel.alpha = 0;
        _timeLabel.alpha = 0;
    }];
    [_animator removeBehavior:_snapLeft];
    [_animator removeBehavior:_snapRight];
    [_animator removeBehavior:_snapTop];
    _snapLeft =  [[UISnapBehavior alloc] initWithItem:_leftActionButton snapToPoint:_startTarget];
    _snapRight = [[UISnapBehavior alloc] initWithItem:_rightActionButton snapToPoint:_startTarget];
    _snapTop =   [[UISnapBehavior alloc] initWithItem:_topActionButton snapToPoint:_startTarget];
    [_animator addBehavior:_snapLeft];
    [_animator addBehavior:_snapRight];
    [_animator addBehavior:_snapTop];

    [_b addItem:_startButton];
}

- (void) disableDynamics
{
    [_animator removeBehavior:_snap];
    
    [UIView animateWithDuration:0.15 animations:^{
        _leftActionButton.alpha = 1.0;
        _rightActionButton.alpha = 1.0;
        _topActionButton.alpha = 1.0;
        _dateLabel.alpha = 1.0;
        _timeLabel.alpha = 1.0;
    }];
    [_animator removeBehavior:_snapLeft];
    [_animator removeBehavior:_snapRight];
    [_animator removeBehavior:_snapTop];
    _snapLeft =  [[UISnapBehavior alloc] initWithItem:_leftActionButton snapToPoint:_leftTarget];
    _snapRight = [[UISnapBehavior alloc] initWithItem:_rightActionButton snapToPoint:_rightTarget];
    _snapTop =   [[UISnapBehavior alloc] initWithItem:_topActionButton snapToPoint:_topTarget];
    //[_snapLeft setDamping:0.4];
    [_animator addBehavior:_snapLeft];
    [_animator addBehavior:_snapRight];
    [_animator addBehavior:_snapTop];
    
    [_b removeItem:_startButton];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    pt.x -= _startButton.frame.origin.x;
    pt.y -= _startButton.frame.origin.y;
    if ([_startButton pointInside:pt withEvent:nil]) {
        _buttonDragging = YES;
        [self disableDynamics];
        NSLog(@"TouchDown on startButton: %.2f %.2f / %.2f %.2f", pt.x, pt.y,
              _startButton.frame.origin.x,
              _startButton.frame.origin.y);
    }
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (_buttonDragging) {
        CGPoint pt = [[touches anyObject] locationInView:self.view];
        _startButton.center = pt;
    } 
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_buttonDragging) {
        CGPoint pt = [[touches anyObject] locationInView:self.view];
        //NSLog(@"Action button test: %.0f %.0f", pt.x, pt.y);
        if ([self actionTest:_leftActionButton point:pt]) [self viewActivate:@"Left"];
        if ([self actionTest:_rightActionButton point:pt]) [self viewActivate:@"Right"];
        if ([self actionTest:_topActionButton point:pt]) [self viewActivate:@"Top"];
        _buttonDragging = NO;
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
