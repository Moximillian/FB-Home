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
        let snap = UISnapBehavior(item: self.startButton, snapToPoint: self.startButton.center)
        snap.damping = 0.3
        return snap
        }()

    private lazy var snapLeftToStart: UISnapBehavior = {
        return UISnapBehavior(item:self.leftActionButton, snapToPoint:self.startTarget) }()

    private lazy var snapRightToStart: UISnapBehavior = {
        return UISnapBehavior(item:self.rightActionButton, snapToPoint:self.startTarget) }()

    private lazy var snapTopToStart: UISnapBehavior = {
        return UISnapBehavior(item:self.topActionButton, snapToPoint:self.startTarget) }()

    private lazy var snapLeftToOrigin: UISnapBehavior = {
        return UISnapBehavior(item:self.leftActionButton, snapToPoint:self.leftTarget) }()

    private lazy var snapRightToOrigin: UISnapBehavior = {
        return UISnapBehavior(item:self.rightActionButton, snapToPoint:self.rightTarget) }()

    private lazy var snapTopToOrigin: UISnapBehavior = {
        return UISnapBehavior(item:self.topActionButton, snapToPoint:self.topTarget) }()


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
        view.layer.contents = bgImage.CGImage

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
        df.dateStyle = .LongStyle
        let datestr = df.stringFromDate(NSDate())
        df.dateStyle = .NoStyle
        df.timeStyle = .ShortStyle
        df.locale = NSLocale(localeIdentifier:"fi_FI")
        let timestr = df.stringFromDate(NSDate())

        setShadow(timeLabel)
        setShadow(dateLabel)

        timeLabel.text = timestr
        dateLabel.text = datestr

        enableDynamics(true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = true
    }

    private func setShadow(v: UIView) {
        v.layer.shadowColor = UIColor.blackColor().CGColor
        v.layer.shadowOffset = CGSizeMake(1.0, 1.0)
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

        UIView.animateWithDuration(0.15) {
            self.leftActionButton.alpha = alpha
            self.rightActionButton.alpha = alpha
            self.topActionButton.alpha = alpha
            self.dateLabel.alpha = alpha
            self.timeLabel.alpha = alpha
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */

        for touch in touches {
            var pt = touch.locationInView(self.view)
            pt.x -= startButton.frame.origin.x
            pt.y -= startButton.frame.origin.y
            if startButton.pointInside(pt, withEvent:nil) {
                buttonDragging = true
                enableDynamics(false)
                NSLog("TouchDown on startButton: %.0f %.0f / %.0f %.0f", pt.x, pt.y, startButton.frame.origin.x, startButton.frame.origin.y);
            }
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if buttonDragging {
            for touch in touches {
                let pt = touch.locationInView(self.view)
                startButton.center = pt;
            }
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (buttonDragging) {
            for touch in touches {
                let pt = touch.locationInView(self.view)
                //NSLog(@"Action button test: %.0f %.0f", pt.x, pt.y);
                if actionTest(leftActionButton, pt) { viewActivate("Left") }
                if actionTest(rightActionButton, pt) { viewActivate("Right") }
                if actionTest(topActionButton, pt) { viewActivate("Top") }
                buttonDragging = false
                enableDynamics(true)
            }
        }
    }

    private func actionTest(v: UIView, var _ p: CGPoint) -> Bool {
        p.x -= v.frame.origin.x;
        p.y -= v.frame.origin.y;
        return v.pointInside(p, withEvent:nil)
    }

    private func viewActivate(message: String) {
        NSLog("Action activated: %@.", message)
        performSegueWithIdentifier("actionPageSeque", sender:message)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "actionPageSeque" {
            let c = segue.destinationViewController as! ActionPageController
            c.title = sender as? String
            UIApplication.sharedApplication().statusBarHidden = false
        }
    }

}