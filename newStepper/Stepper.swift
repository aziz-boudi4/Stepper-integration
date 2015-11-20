import UIKit

//@IBDesignable
class Stepper: UIControl {

  @IBInspectable var min: Int = 0
  @IBInspectable var max: Int = 20

  // MARK: IBOutlet

  @IBOutlet var view: UIView!
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var labelYConstraint: NSLayoutConstraint!

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
  }

  // MARK: IBActions

  @IBAction func didPressPlusBtn(sender: AnyObject) {
    inc(1)
  }

  @IBAction func didPressMinusBtn(sender: AnyObject) {
    inc(-1)
  }

  // MARK: private methods

  private func inc(n: Int) {
    score = score + n
    sendActionsForControlEvents(.ValueChanged)
  }

  func handleSwipes(sender:UISwipeGestureRecognizer) {
    let increment: Int
    let offset: CGFloat

    // up or down
    if sender.direction == .Up {
      increment = 1
      offset = 10
    } else {
      increment = -1
      offset = -10
    }

    // animate stuff with constraints
    inc(increment)

    UIView.animateWithDuration(0.1,
      animations: { () -> Void in
      self.label.transform = CGAffineTransformMakeTranslation(0.0, -offset)
      }) { (_) -> Void in
        UIView.animateWithDuration(0.1, animations: { () -> Void in
          self.label.transform = CGAffineTransformIdentity
        })
    }
  }
}






