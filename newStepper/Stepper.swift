import UIKit
import Foundation
import DateTools

//@IBDesignable
class Stepper: UIControl {

  // MARK: enums

  enum State {
    case Unactivated
    case ActivatedSmall
    case ActivatedLarge
  }

  // MARK: Constants

  private struct Constants {
    static let unactivatedColor =  UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 0.3)
    static let goalGestureScale: CGFloat = 15
    static let swipeDelay: Double = 0.2
  }

  // MARK: Statics

  weak static var active: Stepper? {
    didSet {
      if let oldValue = oldValue where oldValue != active {
        oldValue.stepperState = .Unactivated
      }
    }
  }

  @IBInspectable var min: Int = 0
  @IBInspectable var max: Int = 20

  // MARK: IBOutlet

  @IBOutlet var view: UIView!

  @IBOutlet var views: [UIView]!
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var circleView: CircleView!
  @IBOutlet weak var arrowUp: Button!
  @IBOutlet weak var arrowDown: Button!
  @IBOutlet weak var upButtonVerticalConstraint: NSLayoutConstraint!
  @IBOutlet weak var downButtonVerticalConstraint: NSLayoutConstraint!

  var stepperState: State = .Unactivated {
    didSet {
      let height = label.font.heightOfString("0", constrainedToWidth: frame.width)
      print(height)
      upButtonVerticalConstraint.constant = 6 + height / 2
      downButtonVerticalConstraint.constant = 6 + height / 2

      switch stepperState {
      case .Unactivated:
        circleView.filledColor = Stepper.Constants.unactivatedColor
        circleView.transform = CGAffineTransformMakeScale(1, 1)
        arrowUp.alpha = 0
        arrowDown.alpha = 0
      case .ActivatedSmall:
        Stepper.active = self
        circleView.filledColor = Colors.green
        circleView.transform = CGAffineTransformMakeScale(1, 1)
        arrowUp.alpha = 0
        arrowDown.alpha = 0
      case .ActivatedLarge:
        Stepper.active = self
        circleView.filledColor = Colors.green
        circleView.transform = CGAffineTransformMakeScale(1.2, 1.2)
        arrowDown.enabled = true
        arrowUp.enabled = true
        views.forEach { $0.alpha = 1 }
      }
    }
  }

  var panStartTime: NSDate?

  lazy var tapRecognizer: UITapGestureRecognizer = {
    return UITapGestureRecognizer(target: self, action: "handleTap:")
  }()

  lazy var panRecognizer: UIPanGestureRecognizer = {
    return UIPanGestureRecognizer(target: self, action: "handlePan:")
  }()

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
    addGestureRecognizer(panRecognizer)
    addGestureRecognizer(tapRecognizer)

    label.alpha = 0
    arrowUp.enabled = false
    arrowDown.enabled = false
  }

  // MARK: IBActions

  @IBAction func didPressPlusBtn(sender: AnyObject) {
    inc(1)
  }

  @IBAction func didPressMinusBtn(sender: AnyObject) {
    inc(-1)
  }

  // MARK: Gesture Recognizer Handlers

  func handleTap(sender: UITapGestureRecognizer) {
    UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: [.AllowUserInteraction , .CurveEaseInOut ], animations: {

      switch self.stepperState {
      case .Unactivated: self.stepperState = .ActivatedLarge
      default: self.stepperState = .Unactivated
      }
      self.view.layoutIfNeeded()
      }, completion:nil)
  }

  func handlePan(sender: UIPanGestureRecognizer) {
    let ty = sender.translationInView(circleView).y

    switch sender.state  {
    case .Began :
      initPan(ty)
    case .Changed:
      initPan(ty)
      guard let panStartTime = panStartTime else { return }

      if NSDate().secondsFrom(panStartTime) > Stepper.Constants.swipeDelay {

        let delta = -Int(ty / Constants.goalGestureScale)
        if delta != 0 {
          inc(delta)
          sender.setTranslation(CGPointZero, inView: circleView)
        }
      } else {
        sender.setTranslation(CGPointZero, inView: circleView)
      }

    case .Ended:
      resetTranslation()
      panStartTime = nil
      default: break
    }
  }

  // MARK: private methods

  private func initPan(ty: CGFloat) {
    guard panStartTime == nil && ty != 0 else { return }
    panStartTime = NSDate()
    incAndTranslateView(ty > 0 ? -1: 1)
  }

  private func inc(n: Int) {
    score = score + n
    sendActionsForControlEvents(.ValueChanged)
  }

  private func incAndTranslateView(val: Int) {
    let offset: CGFloat = val == 1 ? -10.0 : 10.0

    inc(val)
    UIView.animateWithDuration(0.18, animations: { _ in
      self.view.frame.origin.y = offset
      self.label.alpha = 1
      self.label.textColor = Colors.blue
      if self.stepperState == .Unactivated { self.stepperState = .ActivatedSmall }
      self.view.layoutIfNeeded()
    })
  }

  private func resetTranslation() {
    UIView.animateWithDuration(0.18, animations: { _ in
      self.view.frame.origin.y = 0
      self.label.textColor = UIColor.whiteColor()
      if self.stepperState == .ActivatedSmall { self.stepperState = .Unactivated }
      self.view.layoutIfNeeded()
    })
  }
}
