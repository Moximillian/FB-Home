//
//  ActionPageController.m
//  FB Home
//
//  Created by Mox Soini on 25.8.2013.
//  Copyright (c) 2013 Mox Soini. All rights reserved.
//

#import "ActionPageController.h"
@import CoreMotion;
#include "HangerView.h"
#include "RopeView.h"

@interface ActionPageController ()

// Enable motion tracking
@property (nonatomic) CMMotionManager *motionManager;
@property (nonatomic) BOOL hasReferencePos;
@property (nonatomic) double referenceYaw;
@property (nonatomic) CMAttitude *referenceAttitude;
@property (nonatomic) CMAttitude *currentAttitude;

// animations
@property (retain, strong, nonatomic) UIDynamicAnimator *animator;

// Hanging badge
@property (weak, nonatomic) IBOutlet UIButton *pinButton;
@property (weak, nonatomic) IBOutlet UIImageView *hangerBadge;
@property (retain, strong, nonatomic) UIAttachmentBehavior *attach;
@property (retain, strong, nonatomic) UIPushBehavior *push;
@property (nonatomic) BOOL listenToAcceleration;
@property (nonatomic) BOOL pinDragging;
@property (nonatomic) CGPoint pinLocation;

//Orientation compass
@property (retain, strong, nonatomic) HangerView *hangerView;
@property (retain, strong, nonatomic) RopeView *ropeView;

@end

@implementation ActionPageController

int pageId;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //NSLog(@"ActionPage: %@", self.title);
    [self becomeFirstResponder];

    pageId = 0;
    if (       [self.title isEqualToString:@"Top"])   { pageId = 1;
    } else if ([self.title isEqualToString:@"Right"]) { pageId = 2;
    } else if ([self.title isEqualToString:@"Left"])  { pageId = 3;
    }

    [self initPage];
}

- (IBAction)actionSwipeDown:(id)sender
{
    [self closeActionPage];
}

- (void) closeActionPage
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) drawTimerAction
{
    [_ropeView setRope:_pinButton.center to:_hangerBadge.center];
    [_ropeView setNeedsDisplay];
}

- (void) initPage
{
    //Calibrate device orientation
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1.0 / 10.0;
    _hasReferencePos = FALSE;
    _listenToAcceleration = FALSE;
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    NSString *sshot;
    _pinButton.alpha = 0;
    _hangerBadge.alpha = 0;

    switch (pageId) {
        case 1: {
            sshot = @"hanger-bg.png";
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
            _pinButton.alpha = 1.0;
            _hangerBadge.alpha = 1.0;
            
            _ropeView = [[RopeView alloc] initWithFrame:CGRectMake(0,0,
                                                                        self.view.bounds.size.width,
                                                                        self.view.bounds.size.height)];
            [self.view addSubview:_ropeView];
            [_ropeView initRopeLength:_pinButton.center to:_hangerBadge.center];
            
            //hanger
            UICollisionBehavior *coll = [[UICollisionBehavior alloc] initWithItems:@[_hangerBadge]];
            [coll setTranslatesReferenceBoundsIntoBoundary:YES];
            
            _pinLocation = _pinButton.center;
            
            _attach = [[UIAttachmentBehavior alloc] initWithItem:_hangerBadge attachedToAnchor:_pinLocation];
            [_attach setFrequency:1.0];
            [_attach setDamping:0.5];
            UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[_hangerBadge]];
            UIDynamicItemBehavior *bHeavy = [[UIDynamicItemBehavior alloc] initWithItems:@[_hangerBadge]];
            //[bHeavy setDensity:4.0];
            [bHeavy setResistance:1.0];
            [_animator addBehavior:bHeavy];
            
            [_animator addBehavior:coll];
            [_animator addBehavior:_attach];
            [_animator addBehavior:gravity];
            
            _push = [[UIPushBehavior alloc] initWithItems:@[_hangerBadge] mode:UIPushBehaviorModeInstantaneous];
            [_animator addBehavior:_push];
            _listenToAcceleration = TRUE;
            
            [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(drawTimerAction) userInfo:nil repeats:TRUE];
            
            break; }
        case 2: {
            sshot = @"compass-bg.png";
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
            CGFloat radius = 100.0;
            _hangerView = [[HangerView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - radius,
                                                                           self.view.bounds.size.height/2 -radius,
                                                                           radius*2, radius*2)];
            [self.view addSubview:_hangerView];
            
            break; }
        case 3: {
            sshot = @"hanger-bg.png";
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
            
            CAShapeLayer *cross = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(20.0, 0.0)];
            [path addLineToPoint:CGPointMake(20.0, 40.0)];
            [path moveToPoint:CGPointMake(0.0, 20.0)];
            [path addLineToPoint:CGPointMake(40.0, 20.0)];
            cross.path = path.CGPath;
            cross.strokeColor = [UIColor redColor].CGColor;
            cross.lineWidth = 1.0;
            cross.frame = CGRectMake(CGRectGetMidX(self.view.bounds) - 20.0, 20.0, 40.0, 40.0);
            [self.view.layer addSublayer:cross];
            
            //pinbutton
            _pinButton.alpha = 1.0;
            [self.view addSubview:_pinButton];
            
            UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            xAxis.minimumRelativeValue = @(-20.0);
            xAxis.maximumRelativeValue = @(20.0);
            
            UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            CGFloat minimumvalue = 90.0 - CGRectGetMidY(self.view.bounds);
            yAxis.minimumRelativeValue = @(minimumvalue);
            yAxis.maximumRelativeValue = @(minimumvalue + 40.0);

            //NSLog(@"mid: %.2f", CGRectGetMidY(self.view.bounds));
            
            UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
            group.motionEffects = @[xAxis, yAxis];
            [_pinButton addMotionEffect:group];
            
            //hangerbadge
            _hangerBadge.alpha = 1.0;
            [self.view addSubview:_hangerBadge];

            UICollisionBehavior *coll = [[UICollisionBehavior alloc] initWithItems:@[_hangerBadge]];
            [coll setTranslatesReferenceBoundsIntoBoundary:YES];
            [_animator addBehavior:coll];
            
            UIDynamicItemBehavior *behav = [[UIDynamicItemBehavior alloc] initWithItems:@[_hangerBadge]];
            behav.elasticity = 0.5;
            [_animator addBehavior:behav];
            
            _push = [[UIPushBehavior alloc] initWithItems:@[_hangerBadge] mode:UIPushBehaviorModeContinuous];
            [_animator addBehavior:_push];
            _push.pushDirection = CGVectorMake(0, 0);
            _push.active = YES;
            
            break; }
    }
    UIImage *bgImage = [UIImage imageNamed:sshot];
    self.view.layer.contents = (id) bgImage.CGImage;
    
    //start motion detection
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical
                                                            toQueue:[NSOperationQueue currentQueue]
                                                        withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                            [self motionHandler:motion];
                                                        }];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (pageId) {
        case 1: {
            CGPoint pt = [[touches anyObject] locationInView:self.view];
            pt.x -= _pinButton.frame.origin.x;
            pt.y -= _pinButton.frame.origin.y;
            if ([_pinButton pointInside:pt withEvent:nil]) {
                _pinDragging = YES;
            }
        }
        break;
    }

}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    switch (pageId) {
        case 1: {
            if (_pinDragging) {
                CGPoint pt = [[touches anyObject] locationInView:self.view];
                _pinButton.center = pt;
                [_attach setAnchorPoint:pt];
            }
        }
        break;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (pageId) {
        case 1: {
            if (_pinDragging) {
                _pinDragging = NO;
            }
        }
        break;
    }
}

- (void) resetListenAcceleration
{
    _listenToAcceleration = TRUE;
    //NSLog(@"Reset");
}

- (void) motionHandler:(CMDeviceMotion *)motion
{
    switch (pageId) {
        case 1: {
            CMAcceleration acc = motion.userAcceleration;
            if (_listenToAcceleration && (fabs(acc.x) > 0.4)) {
                _listenToAcceleration = FALSE;
                [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(resetListenAcceleration) userInfo:nil repeats:FALSE];
                
                //NSLog(@"Motion: ACC: %.2f %.2f %.2f", acc.x, acc.y, acc.z);
                [_push setActive:NO];
                [_push setPushDirection:CGVectorMake(-acc.x, 0.0)];
                [_push setActive:YES];
                NSLog(@"Motion: PUSH: %.2f", acc.x);
            }
        }
            break;
        case 2: {
            if (_hasReferencePos) {
                /*NSLog(@"Motion: PITCH: %.0f, ROLL: %.0f, YAW: %.0f", motion.attitude.pitch*180/M_PI, motion.attitude.roll*180/M_PI, motion.attitude.yaw*180/M_PI);
                 */
                double downAngle = M_PI/2 - (motion.attitude.yaw); // - _referenceYaw);
                [_hangerView setAngle:downAngle];
                [_hangerView setNeedsDisplay];
                
            } else {
                _hasReferencePos = TRUE;
                _referenceAttitude = motion.attitude;
                NSLog(@"Reference yaw: %lf, pitch %lf, roll %lf", motion.attitude.yaw, motion.attitude.pitch, motion.attitude.roll);
            }
        }
            break;
        case 3: {
            CMAttitude *a = motion.attitude;
            [_push setPushDirection:CGVectorMake(a.roll*2, a.pitch*2)];
            //NSLog(@"Motion: PUSH: %.2f %.2f %.2f", a.yaw, a.pitch, a.roll);
        }
    }
}

//CMMotion
- (void)stopDeviceMotion {
    [_motionManager stopDeviceMotionUpdates];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
