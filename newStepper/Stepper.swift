import UIKit

//@IBDesignable
class Stepper: UIControl, UIGestureRecognizerDelegate  {

  @IBInspectable var min: Int = 0
  @IBInspectable var max: Int = 20

  // MARK: IBOutlet

  @IBOutlet var panXib: UIPanGestureRecognizer!
  @IBOutlet weak var circleView: CircleView!
  @IBOutlet var view: UIView!
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var labelYConstraint: NSLayoutConstraint!
  @IBOutlet weak var arrowUp: Button!
  @IBOutlet weak var arrowDown: Button!



  var buttonState = true  // enlarge(false) && shrink(true)
  var firstTap = true

  var increment: Int = 1
  var offset: CGFloat = 10


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
    let swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
    let swipeDown = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))

    swipeUp.direction = .Up
    swipeDown.direction = .Down

    addGestureRecognizer(swipeUp)
    addGestureRecognizer(swipeDown)

    let tapped = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
    addGestureRecognizer(tapped)

    arrowDown.alpha = 1
    arrowUp.alpha = 1
    label.alpha = 0
    panXib.enabled = false
//    setupSwipeGestures()
//    setupTapGesture()
    firstTap = true

  }

  // MARK: IBActions

  @IBAction func didPressPlusBtn(sender: AnyObject) {
    inc(1)
  }

  @IBAction func didPressMinusBtn(sender: AnyObject) {
    inc(-1)
  }


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

  /////
  // add the IBAction for the pan 

  // speed of the pan gesture
  private struct Constants {
    static let GoalGestureScale :CGFloat = 10
  }

  @IBAction func addPanGesture(sender: UIPanGestureRecognizer) {
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


  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    let translation = panXib.translationInView(circleView)
    if -Int(translation.y) >= 2  || -Int(translation.y) <= -2 {
      panXib.enabled = false
      panXib.enabled = true
      panXib.setTranslation(CGPointZero, inView: circleView)
      return true
    } else  {
      panXib.enabled = true
      return false
    }

    
  }







  /////


  // MARK: private methods

  private func inc(n: Int) {
    score = score + n
    sendActionsForControlEvents(.ValueChanged)
  }

  func enlarge() {
    circleView.transform = CGAffineTransformMakeScale(1.2, 1.2)

    arrowUp.alpha = 0
    arrowDown.alpha = 0
    buttonState = false
    panXib.enabled = true
  }

  func shrink() {
    circleView.filledColor = UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 0.3)
    circleView.transform = CGAffineTransformMakeScale(1, 1)
    arrowUp.alpha = 0
    arrowDown.alpha = 0
    panXib.enabled = false
    buttonState = true
  }

  // Toggle animation ( active and inactive mode )
  func handleTap(sender: UITapGestureRecognizer) { // added
    circleView.filledColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1)
    UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: [.AllowUserInteraction , .CurveEaseInOut ], animations: {
      self.buttonState ? self.enlarge() : self.shrink()
      if self.firstTap == true {
//        self.arrowUp.center.y -= 15.0
//        self.arrowDown.center.y += 15.0
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
      if self.firstTap {
        self.arrowUp.alpha = 0
        self.arrowDown.alpha = 0
        self.label.alpha = 1
        self.label.textColor = UIColor(red: 52/255.0, green: 52/255.0, blue: 88/255.0, alpha: 1)
        self.circleView.filledColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1)
        self.firstTap = false
        self.view.frame.origin.y = -self.offset
        self.view.layoutIfNeeded()

      } else {
        self.view.frame.origin.y = -self.offset
        self.view.layoutIfNeeded()
        self.label.alpha = 1
        self.label.textColor = UIColor(red: 52/255.0, green: 52/255.0, blue: 88/255.0, alpha: 1)
        self.circleView.filledColor = UIColor(red: 167/255.0, green: 246/255.0, blue: 67/255.0, alpha: 1)

      }
      }) { _ in

        UIView.animateWithDuration(0.18, animations: { _ in
          self.view.frame.origin.y = 0
          self.view.layoutIfNeeded()
          self.circleView.filledColor = UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 0.3)
          self.label.textColor = UIColor.whiteColor()


        })
    }
  }
}






