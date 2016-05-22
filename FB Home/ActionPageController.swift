//
//  ActionPageController.swift
//  FB Home
//
//  Created by Soini, Mox on 22.5.2016.
//  Copyright © 2016 Mox Soini. All rights reserved.
//

import UIKit
import CoreMotion

class ActionPageController: UIViewController {


  // Enable motion tracking
  let motionManager = CMMotionManager()
  var hasReferencePos: Bool = false
  var referenceYaw: Double = 0
  var referenceAttitude = CMAttitude()
  var currentAttitude = CMAttitude()

  // animations
  lazy var animator: UIDynamicAnimator = {
    return UIDynamicAnimator(referenceView: self.view)
  }()

  lazy var push: UIPushBehavior = {
    switch self.pageId {
    case .left:  return UIPushBehavior(items: [self.hangerBadge], mode: .continuous)
    default: return UIPushBehavior(items: [self.hangerBadge], mode: .instantaneous)
    }
  }()

  // Hanging badge
  @IBOutlet var pinButton: UIButton! {
    didSet {
      pinButton.alpha = 0
    }
  }
  
  @IBOutlet var hangerBadge: UIImageView! {
    didSet {
      hangerBadge.alpha = 0
    }
  }

  lazy var attach: UIAttachmentBehavior = {
    let a = UIAttachmentBehavior(item: self.hangerBadge, attachedToAnchor: self.pinLocation)
    a.frequency = 1.0
    a.damping = 0.5
    return a
  }()

  var listenToAcceleration: Bool = false
  var pinDragging: Bool = false
  var pinLocation: CGPoint = .zero

  //Orientation compass
  lazy var hangerView: HangerView = {
    let radius: CGFloat = 100.0
    return HangerView(frame: CGRect(x: self.view.bounds.width/2 - radius,
                                    y: self.view.bounds.height/2 - radius,
                                    width: radius*2, height: radius*2))
  }()

  lazy var ropeView: RopeView = {
    let r = RopeView(frame: CGRect(origin: .zero, size: self.view.frame.size))
    r.initRopeLength(sPt: self.pinButton.center, to:self.hangerBadge.center)
    return r
  }()

  enum pageIdEnum {
    case top, right, left
  }

  var pageId: pageIdEnum = .top

  override func viewDidLoad() {
    becomeFirstResponder()

    if let t = title {
      switch t {
      case "Top":   pageId = .top    // 1
      case "Right": pageId = .right  // 2
      case "Left":  pageId = .left   // 3
      default:      pageId = .top
      }
    }

    initPage()
  }
  @IBAction func down(sender: AnyObject) {
     print("swipe down")
  }

  @IBAction func swipeDown(sender: UISwipeGestureRecognizer) {
    print("swipe down")
    dismiss(animated: true) //, completion: nil)
  }

  func initPage () {
    //Calibrate device orientation
    motionManager.deviceMotionUpdateInterval = 1.0 / 10.0

    var sshot: String
    UIApplication.shared().statusBarStyle = .default

    switch pageId {
    case .top:
      sshot = "hanger-bg.png"
      pinButton.alpha = 1.0
      hangerBadge.alpha = 1.0

      view.addSubview(ropeView)

      //hanger
      let coll = UICollisionBehavior(items:[hangerBadge])
      coll.translatesReferenceBoundsIntoBoundary = true

      pinLocation = pinButton.center


      let gravity = UIGravityBehavior(items:[hangerBadge])
      let bHeavy = UIDynamicItemBehavior(items:[hangerBadge])
      //[bHeavy setDensity:4.0];
      bHeavy.resistance = 1.0

      animator.addBehavior(bHeavy)
      animator.addBehavior(coll)
      animator.addBehavior(attach)
      animator.addBehavior(gravity)
      animator.addBehavior(push)
      listenToAcceleration = true

      NSTimer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(ActionPageController.drawTimerAction), userInfo: nil, repeats: true)

    case .right:
      sshot = "compass-bg.png"
      UIApplication.shared().statusBarStyle = .lightContent
      self.view.addSubview(hangerView)

    case .left:
      sshot = "hanger-bg.png"

      let cross = CAShapeLayer()
      let path = UIBezierPath()
      path.move(to: CGPoint(x: 20.0, y: 0.0))
      path.addLine(to: CGPoint(x: 20.0, y: 40.0))
      path.move(to: CGPoint(x: 0.0, y: 20.0))
      path.addLine(to: CGPoint(x: 40.0, y: 20.0))
      cross.path = path.cgPath
      cross.strokeColor = UIColor.red().cgColor
      cross.lineWidth = 1.0
      cross.frame = CGRect(x: self.view.bounds.midX - 20.0, y: 20.0, width: 40.0, height: 40.0)
      view.layer.addSublayer(cross)

      //pinbutton
      pinButton.alpha = 1.0
      view.addSubview(pinButton)

      let xAxis = UIInterpolatingMotionEffect(keyPath:"center.x", type:.tiltAlongHorizontalAxis)
      xAxis.minimumRelativeValue = -20.0
      xAxis.maximumRelativeValue = 20.0

      let yAxis = UIInterpolatingMotionEffect(keyPath:"center.y", type:.tiltAlongVerticalAxis)
      let minimumvalue: CGFloat = 90.0 - view.bounds.midY
      yAxis.minimumRelativeValue = minimumvalue as AnyObject
      yAxis.maximumRelativeValue = (minimumvalue + 40.0) as AnyObject

      //NSLog(@"mid: %.2f", CGRectGetMidY(self.view.bounds));

      let group = UIMotionEffectGroup()
      group.motionEffects = [xAxis, yAxis]
      pinButton.addMotionEffect(group)

      //hangerbadge
      hangerBadge.alpha = 1.0
      view.addSubview(hangerBadge)

      let coll = UICollisionBehavior(items: [hangerBadge])
      coll.translatesReferenceBoundsIntoBoundary = true
      animator.addBehavior(coll)

      let behav = UIDynamicItemBehavior(items: [hangerBadge])
      behav.elasticity = 0.5
      animator.addBehavior(behav)

      animator.addBehavior(push)
      push.pushDirection = CGVector.zero
      push.active = true
    }

    let bgImage = UIImage(named: sshot)!
    view.layer.contents = bgImage.cgImage;

    //start motion detection
    motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical,
                                           to: NSOperationQueue.current()!,
                                           withHandler: { (motion, error) in
                                            self.motionHandler(motion: motion!)
    })
  }

  func drawTimerAction() {
    guard let pin = pinButton, hanger = hangerBadge else { return }
    ropeView.setRope(sPt: pin.center, to:hanger.center)
    ropeView.setNeedsDisplay()
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if pageId == .top {
      for touch in touches {
        var pt = touch.location(in: view)
        pt.x -= pinButton.frame.origin.x
        pt.y -= pinButton.frame.origin.y
        if pinButton.point(inside: pt, with:nil) {
          pinDragging = true
        }
      }
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if pageId == .top {
      if pinDragging {
        for touch in touches {
          let pt = touch.location(in: view)
          pinButton.center = pt
          attach.anchorPoint = pt
        }
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if pageId == .top {
      if pinDragging {
        pinDragging = false
      }
    }
  }

  func resetListenAcceleration() {
    listenToAcceleration = true
    //NSLog(@"Reset");
  }

  func motionHandler(motion: CMDeviceMotion) {
    switch pageId {
    case .top:
      let acc = motion.userAcceleration
      if listenToAcceleration && (fabs(acc.x) > 0.4) {
        listenToAcceleration = false
        NSTimer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(ActionPageController.resetListenAcceleration), userInfo: nil, repeats: false)

        //NSLog(@"Motion: ACC: %.2f %.2f %.2f", acc.x, acc.y, acc.z);
        push.active = false
        push.pushDirection = CGVector(dx: -acc.x, dy: 0.0)
        push.active = true
        print("Motion: PUSH: %.2f", acc.x)
      }
    case .right:
      if hasReferencePos {
        /*NSLog(@"Motion: PITCH: %.0f, ROLL: %.0f, YAW: %.0f", motion.attitude.pitch*180/M_PI, motion.attitude.roll*180/M_PI, motion.attitude.yaw*180/M_PI);
         */
        let downAngle = CGFloat(M_PI/2 - motion.attitude.yaw) // - _referenceYaw);
        hangerView.setAngle(angle: downAngle)
        hangerView.setNeedsDisplay()

      } else {
        hasReferencePos = true
        referenceAttitude = motion.attitude
        print("Reference yaw: %lf, pitch %lf, roll %lf", motion.attitude.yaw, motion.attitude.pitch, motion.attitude.roll);
      }
    case .left:
      let a = motion.attitude
      push.pushDirection = CGVector(dx: a.roll*2, dy: a.pitch*2)
      //NSLog(@"Motion: PUSH: %.2f %.2f %.2f", a.yaw, a.pitch, a.roll);
    }
  }

  //CMMotion
  func stopDeviceMotion() {
    motionManager.stopDeviceMotionUpdates()
  }

}