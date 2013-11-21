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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    [self.ropeView setRope:self.pinButton.center to:self.hangerBadge.center];
    [self.ropeView setNeedsDisplay];
}

- (void) initPage
{
    //Calibrate device orientation
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 10.0;
    self.hasReferencePos = FALSE;
    self.listenToAcceleration = FALSE;
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    NSString *sshot;
    self.pinButton.alpha = 0;
    self.hangerBadge.alpha = 0;

    switch (pageId) {
        case 1: {
            sshot = @"hanger-bg.png";
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
            self.pinButton.alpha = 1.0;
            self.hangerBadge.alpha = 1.0;
            
            self.ropeView = [[RopeView alloc] initWithFrame:CGRectMake(0,0,
                                                                        self.view.bounds.size.width,
                                                                        self.view.bounds.size.height)];
            [self.view addSubview:self.ropeView];
            [self.ropeView initRopeLength:self.pinButton.center to:self.hangerBadge.center];
            
            //hanger
            UICollisionBehavior *coll = [[UICollisionBehavior alloc] initWithItems:@[self.hangerBadge]];
            [coll setTranslatesReferenceBoundsIntoBoundary:YES];
            
            self.pinLocation = self.pinButton.center;
            
            self.attach = [[UIAttachmentBehavior alloc] initWithItem:self.hangerBadge attachedToAnchor:self.pinLocation];
            [self.attach setFrequency:1.0];
            [self.attach setDamping:0.5];
            UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.hangerBadge]];
            UIDynamicItemBehavior *bHeavy = [[UIDynamicItemBehavior alloc] initWithItems:@[self.hangerBadge]];
            //[bHeavy setDensity:4.0];
            [bHeavy setResistance:1.0];
            [self.animator addBehavior:bHeavy];
            
            [self.animator addBehavior:coll];
            [self.animator addBehavior:self.attach];
            [self.animator addBehavior:gravity];
            
            self.push = [[UIPushBehavior alloc] initWithItems:@[self.hangerBadge] mode:UIPushBehaviorModeInstantaneous];
            [self.animator addBehavior:self.push];
            self.listenToAcceleration = TRUE;
            
            [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(drawTimerAction) userInfo:nil repeats:TRUE];
            
            break; }
        case 2: {
            sshot = @"compass-bg.png";
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
            CGFloat radius = 100.0;
            self.hangerView = [[HangerView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - radius,
                                                                           self.view.bounds.size.height/2 -radius,
                                                                           radius*2, radius*2)];
            [self.view addSubview:self.hangerView];
            
            break; }
        case 3: {
            sshot = @"ios-mail.png";
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];

            break; }
    }
    UIImage *bgImage = [UIImage imageNamed:sshot];
    self.view.layer.contents = (id) bgImage.CGImage;
    
    //start motion detection
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical
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
            pt.x -= self.pinButton.frame.origin.x;
            pt.y -= self.pinButton.frame.origin.y;
            if ([self.pinButton pointInside:pt withEvent:nil]) {
                self.pinDragging = YES;
            }
        }
        break;
    }

}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    switch (pageId) {
        case 1: {
            if (self.pinDragging) {
                CGPoint pt = [[touches anyObject] locationInView:self.view];
                self.pinButton.center = pt;
                [self.attach setAnchorPoint:pt];
            }
        }
        break;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (pageId) {
        case 1: {
            if (self.pinDragging) {
                self.pinDragging = NO;
            }
        }
        break;
    }
}

- (void) resetListenAcceleration
{
    self.listenToAcceleration = TRUE;
    //NSLog(@"Reset");
}

- (void) motionHandler:(CMDeviceMotion *)motion
{
    switch (pageId) {
        case 1: {
            CMAcceleration acc = motion.userAcceleration;
            if (self.listenToAcceleration && (fabs(acc.x) > 0.4)) {
                self.listenToAcceleration = FALSE;
                [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(resetListenAcceleration) userInfo:nil repeats:FALSE];
                
                //NSLog(@"Motion: ACC: %.2f %.2f %.2f", acc.x, acc.y, acc.z);
                [self.push setActive:NO];
                [self.push setMagnitude:20.0];
                [self.push setPushDirection:CGVectorMake(-acc.x, 0.0)];
                [self.push setActive:YES];
                NSLog(@"Motion: PUSH: %.2f", acc.x);
            }
        }
            break;
        case 2: {
            if (self.hasReferencePos) {
                /*NSLog(@"Motion: PITCH: %.0f, ROLL: %.0f, YAW: %.0f", motion.attitude.pitch*180/M_PI, motion.attitude.roll*180/M_PI, motion.attitude.yaw*180/M_PI);
                 */
                //self.currentAttitude = motion.attitude;
                //[self.currentAttitude multiplyByInverseOfAttitude:self.referenceAttitude];
                
                //[self.gravity setGravityDirection:CGVectorMake(sin(downAngle), cos(downAngle))];
                
                double downAngle = M_PI/2 - (motion.attitude.yaw); // - self.referenceYaw);
                [self.hangerView setAngle:downAngle];
                [self.hangerView setNeedsDisplay];
                
            } else {
                self.hasReferencePos = TRUE;
                self.referenceAttitude = motion.attitude;
                NSLog(@"Reference yaw: %lf, pitch %lf, roll %lf", motion.attitude.yaw, motion.attitude.pitch, motion.attitude.roll);
            }
        }
            break;
    }
}

//CMMotion
- (void)stopDeviceMotion {
    [self.motionManager stopDeviceMotionUpdates];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
