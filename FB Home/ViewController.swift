//
//  ViewController.swift
//  FB Home
//
//  Created by Mox Soini on 6.5.2015.
//  Copyright (c) 2015 Mox Soini. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var rightActionButton: UIImageView!
  @IBOutlet weak var leftActionButton: UIImageView!
  @IBOutlet weak var topActionButton: UIImageView!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!

  // Home
  private var buttonDragging: Bool = false

  private lazy var snap: UISnapBehavior = {
    // Snapping
    let snap = UISnapBehavior(item: self.startButton, snapTo: self.startButton.center)
    snap.damping = 0.3
    return snap
  }()

  private lazy var snapLeftToStart: UISnapBehavior = {
    return UISnapBehavior(item:self.leftActionButton, snapTo:self.startTarget) }()

  private lazy var snapRightToStart: UISnapBehavior = {
    return UISnapBehavior(item:self.rightActionButton, snapTo:self.startTarget) }()

  private lazy var snapTopToStart: UISnapBehavior = {
    return UISnapBehavior(item:self.topActionButton, snapTo:self.startTarget) }()

  private lazy var snapLeftToOrigin: UISnapBehavior = {
    return UISnapBehavior(item:self.leftActionButton, snapTo:self.leftTarget) }()

  private lazy var snapRightToOrigin: UISnapBehavior = {
    return UISnapBehavior(item:self.rightActionButton, snapTo:self.rightTarget) }()

  private lazy var snapTopToOrigin: UISnapBehavior = {
    return UISnapBehavior(item:self.topActionButton, snapTo:self.topTarget) }()


  private lazy var b: UIDynamicItemBehavior = {
    let b = UIDynamicItemBehavior(items: [self.leftActionButton, self.rightActionButton, self.topActionButton])
    // Behaviour – disable rotation
    b.allowsRotation = false
    return b
  }()

  private lazy var animator: UIDynamicAnimator = {
    let animator = UIDynamicAnimator(referenceView: self.view)
    animator.addBehavior(self.b)
    return animator
  }()

  private lazy var startTarget: CGPoint = { return self.startButton.center }()
  private lazy var rightTarget: CGPoint = { return self.rightActionButton.center }()
  private lazy var leftTarget: CGPoint = { return self.leftActionButton.center }()
  private lazy var topTarget: CGPoint = { return self.topActionButton.center }()




  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view, typically from a nib.
    becomeFirstResponder()

    let bgImage = UIImage(named:"Rain-640x1136.jpg")!
    view.layer.contents = bgImage.cgImage

    // Initial position setup
    let heightAdj = view.bounds.size.height - 568
    startButton.center.y += heightAdj
    leftActionButton.center.y += heightAdj
    rightActionButton.center.y += heightAdj
    topActionButton.center.y += heightAdj
    leftActionButton.alpha = 0
    rightActionButton.alpha = 0
    topActionButton.alpha = 0

    let df = NSDateFormatter()
    df.dateStyle = .longStyle
    let datestr = df.string(from: NSDate())
    df.dateStyle = .noStyle
    df.timeStyle = .shortStyle
    df.locale = NSLocale(localeIdentifier:"fi_FI")
    let timestr = df.string(from: NSDate())

    setShadow(v: timeLabel)
    setShadow(v: dateLabel)

    timeLabel.text = timestr
    dateLabel.text = datestr

    enableDynamics(enable: true)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.shared().isStatusBarHidden = true
  }

  private func setShadow(v: UIView) {
    v.layer.shadowColor = UIColor.black().cgColor
    v.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    v.layer.shadowRadius = 2.0
    v.layer.shadowOpacity = 0.8
    v.layer.masksToBounds = false
  }

  private func enableDynamics(enable: Bool) {

    let enableGroup = [snap, snapLeftToStart, snapRightToStart, snapTopToStart]
    let disableGroup = [snapLeftToOrigin, snapRightToOrigin, snapTopToOrigin]
    var alpha: CGFloat = 0

    if enable {
      for item in disableGroup { animator.removeBehavior(item) }
      for item in enableGroup { animator.addBehavior(item) }
      b.addItem(startButton)
    } else {
      alpha = 1.0
      for item in enableGroup { animator.removeBehavior(item) }
      for item in disableGroup { animator.addBehavior(item) }
      b.removeItem(startButton)
    }

    UIView.animate(withDuration: 0.15) {
      self.leftActionButton.alpha = alpha
      self.rightActionButton.alpha = alpha
      self.topActionButton.alpha = alpha
      self.dateLabel.alpha = alpha
      self.timeLabel.alpha = alpha
    }
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    /* Called when a touch begins */

    for touch in touches {
      var pt = touch.location(in: view)
      pt.x -= startButton.frame.origin.x
      pt.y -= startButton.frame.origin.y
      if startButton.point(inside: pt, with:nil) {
        buttonDragging = true
        enableDynamics(enable: false)
        NSLog("TouchDown on startButton: %.0f %.0f / %.0f %.0f", pt.x, pt.y, startButton.frame.origin.x, startButton.frame.origin.y);
      }
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if buttonDragging {
      for touch in touches {
        let pt = touch.location(in: view)
        startButton.center = pt;
      }
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if (buttonDragging) {
      for touch in touches {
        let pt = touch.location(in: view)
        //NSLog(@"Action button test: %.0f %.0f", pt.x, pt.y);
        if actionTest(v: leftActionButton, p: pt) { viewActivate(message: "Left") }
        if actionTest(v: rightActionButton, p: pt) { viewActivate(message: "Right") }
        if actionTest(v: topActionButton, p: pt) { viewActivate(message: "Top") }
        buttonDragging = false
        enableDynamics(enable: true)
      }
    }
  }

  private func actionTest(v: UIView, p: CGPoint) -> Bool {
    var p = p
    p.x -= v.frame.origin.x;
    p.y -= v.frame.origin.y;
    return v.point(inside: p, with:nil)
  }

  private func viewActivate(message: String) {
    print("Action activated: ", message)
    performSegue(withIdentifier: "actionPageSeque", sender:message as AnyObject)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "actionPageSeque" {
      let c = segue.destinationViewController as! ActionPageController
      c.title = sender as? String
      UIApplication.shared().isStatusBarHidden = false
    }
  }

}