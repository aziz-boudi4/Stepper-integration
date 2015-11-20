//
//  ViewController.swift
//  newStepper
//
//  Created by aziz omar boudi  on 6/10/15.
//  Copyright (c) 2015 jogabo. All rights reserved.
//
// coreAnimation layer
//

import UIKit
import QuartzCore



class ViewController: UIViewController, UIGestureRecognizerDelegate {

  // IBActions arrows
  @IBAction func buttonUp(sender: AnyObject) {
    inc(1)
  }

  @IBAction func buttonDown(sender: AnyObject) {
    if score == 0 {
      score = 0
    } else {
      inc(-1)
    }
  }


  @IBOutlet var panGesture: UIPanGestureRecognizer!
  @IBOutlet weak var circleView: UIView!
  @IBOutlet weak var arrowUp: UIButton!
  @IBOutlet weak var arrowDown: UIButton! 
  @IBOutlet weak var buttonUpConstraint: NSLayoutConstraint!
  @IBOutlet weak var buttonDownConstraint: NSLayoutConstraint!
  @IBOutlet weak var labelYConstraint: NSLayoutConstraint!
  @IBOutlet weak var label: UILabel!

  @IBInspectable var min: Int = 0
  @IBInspectable var max: Int = 20

  var buttonState = true  // enlarge(false) && shrink(true)
  var firstTap = true

  var increment: Int = 1
  var offset: CGFloat = 10


  // MARK : IBOutlet



  var score: Int {
    get {
      if let value = Int(label.text!) { return value }
      return 0
    }
    set {
      if newValue >= Int(min) && newValue <= Int(max){
        label.text = newValue.description
      }
    }
  }

  private func inc(n: Int) {
    score = score + n
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    label.font = UIFont(name:"Futura-Medium", size: 44.0)
    arrowDown.alpha = 1 // A
    arrowUp.alpha = 1 // A
    label.alpha = 0   // A
    panGesture.enabled = false
    setupSwipeGestures()
    setupTapGesture()
    firstTap = true  // A

    circleView.layer.cornerRadius = CGRectGetHeight(circleView.bounds) / 2.0  // NoN
    circleView.layer.borderColor = UIColor.lightGrayColor().CGColor   // NoN
  }

  private func setupSwipeGestures() {
    let swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
    let swipeDown = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))

    swipeUp.direction = .Up
    swipeDown.direction = .Down

    circleView.addGestureRecognizer(swipeUp)
    circleView.addGestureRecognizer(swipeDown)

  }

  private func setupTapGesture(){ // added
    let tapped = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
    circleView.addGestureRecognizer(tapped)
  }

  // Tap outside of the view
  @IBAction func setupOutsideTapGesture(sender: UITapGestureRecognizer) {
    UIView.animateWithDuration(0.1, delay: 0, options: [  .AllowUserInteraction , .CurveEaseInOut ] , animations: {
      if self.firstTap && self.buttonState == true {
        self.arrowUp.alpha = 1
        self.arrowDown.alpha = 1
      } else {
        self.shrink()
      }

      }, completion:nil)
  }

  // speed of the pan gesture
  private struct Constants {
    static let GoalGestureScale :CGFloat = 10
  }


  @IBAction func setupPanGesture(sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .Ended: fallthrough
    case .Changed:
      self.circleView.layer.backgroundColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1).CGColor
      let translation = sender.translationInView(circleView)
      let goalChange = -Int(translation.y / Constants.GoalGestureScale)
      if goalChange != 0  {
        score += goalChange
        sender.setTranslation(CGPointZero, inView: circleView)
      }
    default: break
    }
  }


  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    let translation = panGesture.translationInView(circleView)
    if -Int(translation.y) >= 2  || -Int(translation.y) <= -2 {
      panGesture.enabled = false
      panGesture.enabled = true
      panGesture.setTranslation(CGPointZero, inView: circleView)
      return true
    } else  {
      panGesture.enabled = true
      return false
    }


  }


  func enlarge() { // added
    circleView.transform = CGAffineTransformMakeScale(1.2, 1.2)
    buttonDownConstraint.constant = 4
    buttonUpConstraint.constant = 4
    arrowUp.alpha = 0
    arrowDown.alpha = 0
    buttonState = false
    panGesture.enabled = true
  }

  func shrink() {  // added
    circleView.layer.backgroundColor = UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 0.3).CGColor
    circleView.transform = CGAffineTransformMakeScale(1, 1)
    arrowUp.alpha = 0
    arrowDown.alpha = 0
    panGesture.enabled = false
    buttonState = true
  }


  // Toggle animation ( active and inactive mode )
  func handleTap(sender: UITapGestureRecognizer) { // added
    circleView.layer.backgroundColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1).CGColor
    UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: [.AllowUserInteraction , .CurveEaseInOut ], animations: {
      self.buttonState ? self.enlarge() : self.shrink()
      if self.firstTap == true {
        self.arrowUp.center.y -= 28.0
        self.arrowDown.center.y += 28.0
        self.firstTap = false
      }
      self.view.layoutIfNeeded()

      }, completion:nil)

    UIView.animateWithDuration(0.6, delay: 0, options: [  .AllowUserInteraction , .CurveEaseInOut ] , animations: {
      if !self.buttonState {
        self.arrowDown.alpha = 1
        self.arrowUp.alpha = 1
        self.label.alpha = 1
      }
      }, completion:nil)

  }

  func handleSwipes(sender:UISwipeGestureRecognizer) {

    // up or down
    if sender.direction == .Down && score == 0 {
      increment = 0
      offset = -10
    } else if sender.direction == .Up {
      increment = 1
      offset = 10
    } else if  sender.direction == .Down {
      increment = -1
      offset = -10
    }

    // animate adding single goals with constraints
    inc(increment)

    UIView.animateWithDuration(0.18, animations: { _ in
      if self.firstTap {
        self.arrowUp.alpha = 0
        self.arrowDown.alpha = 0
        self.labelYConstraint.constant = self.offset
        self.view.layoutIfNeeded()
        self.label.alpha = 1
        self.label.textColor = UIColor(red: 52/255.0, green: 52/255.0, blue: 88/255.0, alpha: 1)
        self.circleView.layer.backgroundColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1).CGColor
        self.firstTap = false
      } else {
        self.labelYConstraint.constant = self.offset
        self.view.layoutIfNeeded()
        self.label.alpha = 1
        self.label.textColor = UIColor(red: 52/255.0, green: 52/255.0, blue: 88/255.0, alpha: 1)
        self.circleView.layer.backgroundColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1).CGColor
      }
      }) { _ in

        UIView.animateWithDuration(0.18, animations: { _ in
          self.labelYConstraint.constant = 0
          self.view.layoutIfNeeded()
          self.circleView.layer.shadowColor = UIColor.clearColor().CGColor
          self.circleView.layer.backgroundColor = UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 0.3).CGColor
          self.label.textColor = UIColor.whiteColor()
          
        })
    }
  }
}




