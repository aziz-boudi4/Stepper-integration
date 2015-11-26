import UIKit

//@IBDesignable
class Stepper: UIControl  {

  weak static var active: Stepper?

  @IBInspectable var min: Int = 0
  @IBInspectable var max: Int = 20

  // MARK: IBOutlet

  @IBOutlet var view: UIView!
  @IBOutlet weak var circleView: CircleView!
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var arrowUp: Button!
  @IBOutlet weak var arrowDown: Button!
  @IBOutlet weak var upButtonVerticalConstraint: NSLayoutConstraint!
  @IBOutlet weak var downButtonVerticalConstraint: NSLayoutConstraint!


  var buttonState = true  // enlarge(false) && shrink(true)
  var firstTap = true
  var increment: Int = 1
  var offset: CGFloat = 10
  var panMultiGoals: UIPanGestureRecognizer!

  // MARK: properties

  let nibName = "Stepper"

  @IBInspectable
  var fontSize: CGFloat = 17.0 {
    didSet {
      label.font = UIFont(name: label.font.fontName, size: fontSize)
    }
  }

  var score: Score {
    get {
      return Score(Int(label.text.or("")))
    }
    set {
      if newValue >= Score(min) && newValue <= Score(max) {
        label.text = newValue.description
      }
    }
  }

  // MARK: initializers

//  override func didMoveToSuperview() {
//    super.didMoveToSuperview()
//    var superViews = [UIView]()
//      func getSuperView(view: UIView) -> UIView {
//        guard let superview = view.superview else { return view }
//        return getSuperView(superview)
//      }
//    let view = getSuperView(self)
//    let tappedOutside = UITapGestureRecognizer(target: self, action: "handleOutsideTap:")
//    view.addGestureRecognizer(tappedOutside)
//  }


  override init(frame: CGRect) {
    super.init(frame: frame)
    loadNibView(nibName)
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadNibView(nibName)
    commonInit()
  }

  private func commonInit() {
    let swipeUp = UISwipeGestureRecognizer(target: self, action: "handleSwipes:")
    let swipeDown = UISwipeGestureRecognizer(target: self, action: "handleSwipes:")

    swipeUp.direction = .Up
    swipeDown.direction = .Down

    addGestureRecognizer(swipeUp)
    addGestureRecognizer(swipeDown)

    let tapped = UITapGestureRecognizer(target: self, action: "handleTap:")
    addGestureRecognizer(tapped)

    panMultiGoals = UIPanGestureRecognizer(target: self, action: "handlePan:")
    addGestureRecognizer(panMultiGoals)
    panMultiGoals.delegate = self

    arrowDown.alpha = 1
    arrowUp.alpha = 1
    label.alpha = 0
    panMultiGoals.enabled = false
    firstTap = true
    buttonState = true
    arrowUp.enabled = false
    arrowDown.enabled = false
    view.layoutIfNeeded()
  }

  // MARK: IBActions

  @IBAction func didPressPlusBtn(sender: AnyObject) {
    inc(1)
  }

  @IBAction func didPressMinusBtn(sender: AnyObject) {
    inc(-1)
  }


//  @IBAction func setupOutsideTapGesture(sender: UITapGestureRecognizer) {
//    UIView.animateWithDuration(0.1, delay: 0, options: [  .AllowUserInteraction , .CurveEaseInOut ] , animations: {
//      if self.firstTap && self.buttonState == true {
//        self.arrowUp.alpha = 1
//        self.arrowDown.alpha = 1
//      } else {
//        self.shrink()
//      }
//
//      }, completion:nil)
//  }

//  func handleOutsideTap(sender: UITapGestureRecognizer) {
//    UIView.animateWithDuration(0.1, delay: 0, options: [  .AllowUserInteraction , .CurveEaseInOut ] , animations: {
//      if self.firstTap && self.buttonState == true {
//        self.arrowUp.alpha = 1
//        self.arrowDown.alpha = 1
//      } else {
//        self.shrink()
//      }
//
//      }, completion:nil)
//  }


  // speed of the pan gesture
  private struct Constants {
    static let GoalGestureScale :CGFloat = 15
  }

  func handlePan(sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .Ended: fallthrough
    case .Changed:
      self.circleView.filledColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1)
      let translation = sender.translationInView(circleView)
      let goalChange = -Int(translation.y / Constants.GoalGestureScale)

      if goalChange != 0  {
        score = score + goalChange
        sender.setTranslation(CGPointZero, inView: circleView)
      }
    default: break
    }
  }




  // MARK: private methods

  private func inc(n: Int) {
    score = score + n
    sendActionsForControlEvents(.ValueChanged)
  }

  func enlarge() {
    Stepper.active?.shrink()
    Stepper.active = self


    circleView.filledColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1.0)
    circleView.transform = CGAffineTransformMakeScale(1.2, 1.2)
    arrowUp.transform = CGAffineTransformMakeScale(1.2, 1.2)
    arrowDown.transform = CGAffineTransformMakeScale(1.2, 1.2)
    arrowUp.alpha = 1
    arrowDown.alpha = 1
    buttonState = false
    panMultiGoals.enabled = true
    arrowDown.enabled = true
    arrowUp.enabled = true
  }

  func shrink() {
    circleView.filledColor = UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 0.3)
    circleView.transform = CGAffineTransformMakeScale(1, 1)
    arrowUp.alpha = 0
    arrowDown.alpha = 0
    panMultiGoals.enabled = false
    buttonState = true
  }

  // Toggle animation ( active and inactive mode )
  func handleTap(sender: UITapGestureRecognizer) { // added
    self.view.layoutIfNeeded()
    circleView.filledColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1)
    UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: [.AllowUserInteraction , .CurveEaseInOut ], animations: {

      if self.firstTap {
            self.circleView.transform = CGAffineTransformMakeScale(1.2, 1.2)
            self.upButtonVerticalConstraint.constant = 100
            self.downButtonVerticalConstraint.constant = 100
            self.label.alpha = 1
            self.arrowUp.alpha = 1
            self.arrowDown.alpha = 1
            self.firstTap = false
            self.buttonState = false
            self.panMultiGoals.enabled = true

      } else {
            self.buttonState ? self.enlarge() : self.shrink()
      }

            self.view.layoutIfNeeded()

      }, completion:nil)

        UIView.animateWithDuration(0.6, delay: 0, options: [  .AllowUserInteraction , .CurveEaseInOut ] , animations: {
            if !self.buttonState {
                self.arrowDown.alpha = 1
                self.arrowUp.alpha = 1
                self.label.alpha = 1
                self.arrowUp.transform = CGAffineTransformMakeScale(1.3, 1.3)
                self.arrowDown.transform = CGAffineTransformMakeScale(1.3, 1.3)
          }
      }, completion:nil)
    
  }


  func handleSwipes(sender:UISwipeGestureRecognizer) {
    if let active = Stepper.active where active !== self {
      active.shrink()
      Stepper.active = nil
    }

    self.view.layoutIfNeeded()

    // up or down
    if sender.direction == .Up {
      increment = 1
      offset = 10

    } else if sender.direction == .Down {
      increment = -1
      offset = -10

    }

    // animate stuff with constraints
    inc(increment)

    UIView.animateWithDuration(0.18, animations: { _ in
      self.view.layoutIfNeeded()
      if self.firstTap {
        self.arrowUp.alpha = 0
        self.arrowDown.alpha = 0
        self.view.frame.origin.y = -self.offset
        self.label.alpha = 1
        self.label.textColor = UIColor(red: 52/255.0, green: 52/255.0, blue: 88/255.0, alpha: 1)
        self.circleView.filledColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1)
        self.firstTap = false


      } else {
        self.view.frame.origin.y = -self.offset
        self.label.alpha = 1
        self.label.textColor = UIColor(red: 52/255.0, green: 52/255.0, blue: 88/255.0, alpha: 1)
        self.circleView.filledColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1)
      }
      }) { _ in

        UIView.animateWithDuration(0.18, animations: { _ in
          self.view.frame.origin.y = 0
          self.circleView.filledColor = UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 0.3)
          self.label.textColor = UIColor.whiteColor()


        })
    }
  }


}

extension Stepper: UIGestureRecognizerDelegate {

  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    let translation = panMultiGoals.translationInView(circleView)
    if -Int(translation.y) >= 2  || -Int(translation.y) <= -2 {
      panMultiGoals.enabled = false
      panMultiGoals.enabled = true
      panMultiGoals.setTranslation(CGPointZero, inView: circleView)
      return true
    } else  {
      panMultiGoals.enabled = true
      return false
    }
  }
}







