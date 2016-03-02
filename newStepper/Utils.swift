import Foundation
import UIKit




typealias Callback = () -> Void

enum Score {
  case Value(Int)
  case Unknown

  init() {
    self = .Unknown
  }

  init(_ value: Int?) {
    if let v = value {
      self = .Value(v)
    } else {
      self = .Unknown
    }
  }

  func toInt() -> Int? {
    switch self {
    case .Unknown: return .None
    case .Value(let v): return v
    }
  }
}

// MARK: Score + CustomStringConvertible

extension Score: CustomStringConvertible {
  var description: String {
    switch self {
    case .Unknown: return "-"
    case .Value(let v): return String(v)
    }
  }
}

// MARK: Score + Equatable

extension Score: Equatable {}

func ==(lhs: Score, rhs: Score) -> Bool {
  switch (lhs, rhs) {
  case (.Value(let lhs), .Value(let rhs)): return lhs == rhs
  case (.Unknown, .Unknown): return true
  default: return false
  }
}

func !=(lhs: Score, rhs: Score) -> Bool {
  return !(lhs == rhs)
}

// MARK: Score + Comparable

extension Score: Comparable {}

func <(lhs: Score, rhs: Score) -> Bool {
  switch (lhs, rhs) {
  case (.Value(let lhs), .Value(let rhs)): return lhs < rhs
  case (.Unknown, .Value): return true
  default: return false
  }
}

func >(lhs: Score, rhs: Score) -> Bool {
  switch (lhs, rhs) {
  case (.Value(let lhs), .Value(let rhs)): return lhs > rhs
  case (.Value, .Unknown): return true
  default: return false
  }
}

func <=(lhs: Score, rhs: Score) -> Bool {
  return lhs < rhs || lhs == rhs
}

func >=(lhs: Score, rhs: Score) -> Bool {
  return lhs > rhs || lhs == rhs
}

// MARK: Score + addition

func +(lhs: Score, rhs: Score) -> Score {
  switch (lhs, rhs) {
  case (.Value(let lhs), .Value(let rhs)): return .Value(lhs + rhs)
  case (.Unknown, .Value): return rhs
  case (.Value, .Unknown): return lhs
  case (.Unknown, .Unknown): return .Unknown
  }
}

func -(lhs: Score, rhs: Score) -> Score {
  switch (lhs, rhs) {
  case (.Value(let lhs), .Value(let rhs)): return .Value(lhs - rhs)
  case (.Unknown, .Value): return rhs
  case (.Value, .Unknown): return lhs
  case (.Unknown, .Unknown): return .Unknown
  }
}

// MARK: Derived operators

func +(lhs: Score, rhs: Int?) -> Score {
  return lhs + Score(rhs)
}

func +(lhs: Int?, rhs: Score) -> Score {
  return Score(lhs) + rhs
}


extension Optional {
  func or(defaultValue: Wrapped) -> Wrapped {
    switch(self) {
    case .None:
      return defaultValue
    case .Some(let value):
      return value
    }
  }

  var exists: Bool {
    return self == nil
      ? false
      : true
  }

  var debugState: String {
    return self == nil
      ? "❌"
      : "✅"
  }
}


extension UIView {
  func loadNibView(nibName: String) {

    // load view
    let bundle: NSBundle = NSBundle(forClass: self.dynamicType)
    let nib = UINib(nibName: nibName, bundle: bundle)
    let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView

    // setup view
    view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    view.frame = bounds
    addSubview(view)
  }
}

// MARK: CircleComponent protocol

protocol CircleComponent {
  var circleSize: CGFloat { get }
  var borderColor: UIColor { get }
  var filledColor: UIColor { get }
  var borderWidth: CGFloat { get }
  var circleOffset: CGFloat { get }

  var hasRoundLayer: Bool { get }
  var hasRoundBorderLayer: Bool { get }

  var roundBorderLayer: CALayer? { get set }
  var roundLayer: CALayer? { get set }
}

// MARK: RoundedRectComponent protocol

protocol RoundedRectComponent {
  var roundedRectSize: CGSize { get }
  var borderColor: UIColor { get }
  var borderWidth: CGFloat { get }
  var filledColor: UIColor { get }
  var cornerRadius: CGFloat { get }

  var hasRoundedRectLayer: Bool { get }
  var hasRoundedRectBorderLayer: Bool { get }

  var roundedRectLayer: CAShapeLayer? { get set }
  var roundedRectBorderLayer: CAShapeLayer? { get set }
}

// MARK: CircleComponent helpers

private func circleComponentLayoutSubviews<T:UIView where T:CircleComponent>(var view: T) {

  let center = CGPoint(
    x: view.bounds.midX,
    y: view.bounds.midY
  )

  // either use circleSize or view size to size our circle
  let rect: CGRect
  if view.circleSize > 0 {
    rect = CGRect(x: 0, y: 0, width: view.circleSize, height: view.circleSize)
  } else {
    let side = min(view.bounds.height, view.bounds.width)
    rect = CGRect(x: 0, y: 0, width: side, height: side)
  }

  // append ring layer if required
  if view.hasRoundBorderLayer && view.roundBorderLayer == nil {
    view.roundBorderLayer = CALayer()
    view.layer.insertSublayer(view.roundBorderLayer!, atIndex: 0)
  }

  // setup ring layer dimensions
  if let roundBorderLayer = view.roundBorderLayer {
    let innerRect = CGRectInset(rect, view.circleOffset - 1, view.circleOffset - 1)
    roundBorderLayer.masksToBounds = true
    roundBorderLayer.cornerRadius = innerRect.width / 2
    roundBorderLayer.borderWidth = view.borderWidth
    roundBorderLayer.borderColor = view.borderColor.CGColor
    roundBorderLayer.bounds = innerRect
    roundBorderLayer.position = center
    roundBorderLayer.backgroundColor = UIColor.clearColor().CGColor
  }

  // append mask layer if required
  if view.hasRoundLayer && view.roundLayer == nil {
    view.roundLayer = CAShapeLayer()
    if view is UIImageView || view is UILabel {
      view.backgroundColor = view.filledColor
      view.layer.masksToBounds = true
      view.layer.cornerRadius = rect.width / 2
    } else {
      view.layer.insertSublayer(view.roundLayer!, atIndex: 0)
    }
  }

  // setup mask layer dimension
  if let roundLayer = view.roundLayer {

    roundLayer.masksToBounds = true
    roundLayer.cornerRadius = rect.width / 2
    roundLayer.backgroundColor = view.filledColor.CGColor
    roundLayer.borderColor = view.filledColor.CGColor
    roundLayer.bounds = rect
    if view is UIImageView || view is UILabel {
      view.backgroundColor = view.filledColor
      view.layer.backgroundColor = view.backgroundColor!.CGColor
    }
    roundLayer.position = center
  }
}

private func circleComponentIntrinsicContentSize<T:UIView where T:CircleComponent>(view: T) -> CGSize? {
  if view.circleSize > 0 {
    return CGSize(width: view.circleSize, height: view.circleSize)
  }

  return nil
}

// MARK: RoundedRectComponent helper

private func roundedRectComponentLayoutSubviews<T:UIView where T:RoundedRectComponent>(var view: T) {

  // view center
  let center = CGPoint(
    x: view.bounds.midX,
    y: view.bounds.midY
  )

  // either use the frame size or the one specified to size the rounded rect
  let rect = view.roundedRectSize == CGSizeZero
    ? view.bounds
    : CGRect(origin: CGPointZero, size: view.roundedRectSize)

  // stop here if no width or height
  if rect.width == 0 || rect.height == 0 { return }

  // append ring layer if required
  if view.hasRoundedRectBorderLayer && view.roundedRectBorderLayer == nil {
    view.roundedRectBorderLayer = CAShapeLayer()
    view.layer.insertSublayer(view.roundedRectBorderLayer!, atIndex: 0)
  }

  // setup ring layer dimensions
  if let roundedRectBorderLayer = view.roundedRectBorderLayer {
    let innerRect = CGRectInset(rect, view.borderWidth / 2.0, view.borderWidth / 2.0)
    let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: view.cornerRadius)

    roundedRectBorderLayer.bounds = rect
    roundedRectBorderLayer.path = innerPath.CGPath
    roundedRectBorderLayer.fillColor = nil
    roundedRectBorderLayer.lineWidth = view.borderWidth
    roundedRectBorderLayer.strokeColor = view.borderColor.CGColor
    roundedRectBorderLayer.position = center
  }

  // append mask layer if required
  if view.hasRoundedRectLayer && view.roundedRectLayer == nil {
    view.roundedRectLayer = CAShapeLayer()
    if view is UIImageView || view is UILabel {
      view.layer.mask = view.roundedRectLayer
    } else {
      view.layer.insertSublayer(view.roundedRectLayer!, atIndex: 0)
    }
  }

  // setup mask layer dimension
  if let roundedRectLayer = view.roundedRectLayer {
    let innerRect = CGRectInset(rect, view.borderWidth / 2.0, view.borderWidth / 2.0)
    let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: view.cornerRadius)

    roundedRectLayer.bounds = rect
    roundedRectLayer.path = innerPath.CGPath

    if view is UIImageView || view is UILabel {
      view.layer.mask = view.roundedRectLayer
      view.backgroundColor = view.filledColor
    } else {
      roundedRectLayer.fillColor = view.filledColor.CGColor
    }

    roundedRectLayer.lineWidth = max(view.borderWidth - 1, 0)
    roundedRectLayer.strokeColor = UIColor.blackColor().CGColor
    roundedRectLayer.position = center
  }
}

private func roundedRectComponentIntrinsicContentSize<T:UIView where T:RoundedRectComponent>(view: T) -> CGSize? {
  if view.roundedRectSize != CGSizeZero {
    return view.roundedRectSize
  }

  return nil
}

// MARK: View
class BorderedView: UIView {

  var borderTopLayer: CALayer?
  var borderBottomLayer: CALayer?

  @IBInspectable
  var borderTopWidth: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderTopColor: UIColor = UIColor.clearColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderBottomWidth: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderBottomColor: UIColor = UIColor.clearColor() {
    didSet { setNeedsLayout() }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    // create top border layer
    if borderTopWidth > 0 && borderTopLayer == nil {
      borderTopLayer = CALayer()
      layer.insertSublayer(borderTopLayer!, atIndex: 0)
    }

    // setup top border layer
    if let borderTopLayer = borderTopLayer {
      borderTopLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: borderTopWidth)
      borderTopLayer.backgroundColor = borderTopColor.CGColor
    }

    // create bottom  border layer
    if borderBottomWidth > 0 && borderBottomLayer == nil {
      borderBottomLayer = CALayer()
      layer.insertSublayer(borderBottomLayer!, atIndex: 0)
    }

    // setup border layer
    if let borderBottomLayer = borderBottomLayer {
      borderBottomLayer.frame = CGRect(x: 0, y: frame.height - borderBottomWidth, width: frame.width, height: borderBottomWidth)
      borderBottomLayer.backgroundColor = borderBottomColor.CGColor
    }
  }
}

// MARK: CircleView

//@IBDesignable
class CircleView: UIView, CircleComponent {

  @IBInspectable
  var circleSize: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var circleOffset: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderColor: UIColor = UIColor.blackColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var filledColor: UIColor = UIColor.clearColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderWidth: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  var hasRoundLayer: Bool  { return filledColor != UIColor.clearColor() }
  var hasRoundBorderLayer: Bool { return borderWidth > 0 }

  var roundBorderLayer: CALayer?
  var roundLayer: CALayer?

  override func layoutSubviews() {
    super.layoutSubviews()
    circleComponentLayoutSubviews(self)
  }

  override func intrinsicContentSize() -> CGSize {
    return circleComponentIntrinsicContentSize(self) ?? super.intrinsicContentSize()
  }
}

// MARK: RoundedRectView

//@IBDesignable
class RoundedRectView: UIView, RoundedRectComponent {

  @IBInspectable
  var roundedRectSize: CGSize = CGSizeZero {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderColor: UIColor = UIColor.blackColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var filledColor: UIColor = UIColor.clearColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderWidth: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var cornerRadius: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  var hasRoundedRectLayer: Bool { return filledColor != UIColor.clearColor() }
  var hasRoundedRectBorderLayer: Bool { return borderWidth > 0 }

  var roundedRectLayer: CAShapeLayer?
  var roundedRectBorderLayer: CAShapeLayer?

  override func layoutSubviews() {
    super.layoutSubviews()
    roundedRectComponentLayoutSubviews(self)
  }

  override func intrinsicContentSize() -> CGSize {
    return roundedRectComponentIntrinsicContentSize(self) ?? super.intrinsicContentSize()
  }
}

// MARK: Button

//@IBDesignable
class Button: UIButton {

  @IBInspectable
  var textAlign: String? {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var iconColor: UIColor = UIColor.blackColor() {
    didSet { setNeedsLayout() }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    // set icon color
    tintColor = iconColor

    // align image and title
    switch (titleLabel, imageView, textAlign) {
    case let (.Some(titleLabel), .Some(imageView), .Some(textAlign))
      where textAlign == "bottom":
      imageView.frame.origin.x = bounds.midX - imageView.frame.width / 2
      titleLabel.frame.origin.x = bounds.midX - titleLabel.frame.width / 2
      imageView.frame.origin.y = bounds.midY - imageView.frame.height - imageEdgeInsets.bottom
      titleLabel.frame.origin.y = bounds.midY + titleEdgeInsets.top
    case let (.Some(titleLabel), .Some(imageView), .Some(textAlign))
      where textAlign == "top":
      titleLabel.frame.origin.x = bounds.midX - titleLabel.frame.width / 2
      imageView.frame.origin.x = bounds.midX - imageView.frame.width / 2
      titleLabel.frame.origin.y = bounds.midY - titleLabel.frame.height - titleEdgeInsets.bottom
      imageView.frame.origin.y = bounds.midY + imageEdgeInsets.top
    case let (.Some(titleLabel), .Some(imageView), .Some(textAlign))
      where textAlign == "left":
      imageView.frame.origin.y = bounds.midY - imageView.frame.height / 2
      titleLabel.frame.origin.y = bounds.midY - titleLabel.frame.height / 2
      titleLabel.frame.origin.x = 0
      imageView.frame.origin.x = bounds.width - imageView.frame.width
    default:
      break
    }
  }

  override func intrinsicContentSize() -> CGSize {
    if let
      imageView = imageView,
      titleLabel = titleLabel,
      textAlign = textAlign
      where textAlign == "top" || textAlign == "bottom" {
        titleLabel.sizeToFit()
        imageView.sizeToFit()
        let height = titleLabel.frame.height + imageView.frame.height
          + titleEdgeInsets.top + titleEdgeInsets.bottom
          + imageEdgeInsets.top + imageEdgeInsets.bottom
        let width = titleLabel.frame.width + imageView.frame.width
          + titleEdgeInsets.left + titleEdgeInsets.right
          + imageEdgeInsets.top + imageEdgeInsets.bottom

        return CGSize(width: width, height: height)
    }

    return super.intrinsicContentSize()
  }
}

// MARK: CircleButton

//@IBDesignable
class CircleButton: Button, CircleComponent {

  @IBInspectable
  var circleSize: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var circleOffset: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderColor: UIColor = UIColor.clearColor() {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable
  var filledColor: UIColor = UIColor.clearColor() {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable
  var borderWidth: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var highlightedAlpha: CGFloat = 0.5

  var highlightedCallback: Callback?

  override var highlighted: Bool {
    didSet {
      highlightedCallback?()
      UIView.animateWithDuration(0.2) {
        self.alpha = self.highlighted ? self.highlightedAlpha : 1.0
      }
    }
  }

  var hasRoundLayer: Bool  { return filledColor != UIColor.clearColor() }
  var hasRoundBorderLayer: Bool { return borderWidth > 0 }

  var roundBorderLayer: CALayer?
  var roundLayer: CALayer?

  override func layoutSubviews() {
    super.layoutSubviews()
    circleComponentLayoutSubviews(self)
  }

  override func intrinsicContentSize() -> CGSize {
    return circleComponentIntrinsicContentSize(self) ?? super.intrinsicContentSize()
  }
}

// MARK: RoundedRectButton

//@IBDesignable
class RoundedRectButton: Button, RoundedRectComponent {

  @IBInspectable
  var roundedRectSize: CGSize = CGSizeZero {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderColor: UIColor = UIColor.clearColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var filledColor: UIColor = UIColor.clearColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderWidth: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var cornerRadius: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  override var highlighted: Bool {
    didSet {
      if let color = titleColorForState((highlighted ? .Highlighted : .Normal)) {
        borderColor = color
      }
    }
  }

  var hasRoundedRectLayer: Bool { return filledColor != UIColor.clearColor() }
  var hasRoundedRectBorderLayer: Bool { return borderWidth > 0 }

  var roundedRectLayer: CAShapeLayer?
  var roundedRectBorderLayer: CAShapeLayer?

  override func layoutSubviews() {
    super.layoutSubviews()
    roundedRectComponentLayoutSubviews(self)
  }

  override func intrinsicContentSize() -> CGSize {
    return roundedRectComponentIntrinsicContentSize(self) ?? super.intrinsicContentSize()
  }
}

// MARK: ImageView

class ImageView: UIImageView {

  @IBInspectable
  var iconColor: UIColor = UIColor.blackColor() {
    didSet { setNeedsLayout() }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    tintColor = iconColor
  }
}

// MARK: CircleImageView

//@IBDesignable
class CircleImageView: ImageView, CircleComponent {

  @IBInspectable
  var circleSize: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var circleOffset: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderColor: UIColor = UIColor.blackColor() {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable
  var filledColor: UIColor {
    get {
      return backgroundColor ?? UIColor.clearColor()
    }
    set {
      backgroundColor = newValue
    }
  }

  @IBInspectable
  var borderWidth: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var highlightedAlpha: CGFloat = 0.5

  override var highlighted: Bool {
    didSet {
      UIView.animateWithDuration(0.2) {
        self.alpha = self.highlighted ? self.highlightedAlpha : 1.0
      }
    }
  }

  var hasRoundLayer: Bool  { return filledColor != UIColor.clearColor() }
  var hasRoundBorderLayer: Bool { return borderWidth > 0 }

  var roundBorderLayer: CALayer?
  var roundLayer: CALayer?

  override func layoutSubviews() {
    super.layoutSubviews()
    circleComponentLayoutSubviews(self)
  }

  override func intrinsicContentSize() -> CGSize {
    return circleComponentIntrinsicContentSize(self) ?? super.intrinsicContentSize()
  }
}

// MARK: RoundedRectImageView

//@IBDesignable
class RoundedRectImageView: ImageView, RoundedRectComponent {


  @IBInspectable
  var roundedRectSize: CGSize = CGSizeZero {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderColor: UIColor = UIColor.blackColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var filledColor: UIColor = UIColor.clearColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderWidth: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var cornerRadius: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  var hasRoundedRectLayer: Bool { return filledColor != UIColor.clearColor() }
  var hasRoundedRectBorderLayer: Bool { return borderWidth > 0 }

  var roundedRectLayer: CAShapeLayer?
  var roundedRectBorderLayer: CAShapeLayer?

  override func layoutSubviews() {
    super.layoutSubviews()
    roundedRectComponentLayoutSubviews(self)
  }

  override func intrinsicContentSize() -> CGSize {
    return roundedRectComponentIntrinsicContentSize(self) ?? super.intrinsicContentSize()
  }
}

// MARK: CircleLabel

//@IBDesignable
class CircleLabel: UILabel, CircleComponent {

  @IBInspectable
  var circleSize: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var circleOffset: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderColor: UIColor = UIColor.blackColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var filledColor: UIColor = UIColor.clearColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderWidth: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  var hasRoundLayer: Bool  { return filledColor != UIColor.clearColor() }
  var hasRoundBorderLayer: Bool { return borderWidth > 0 }

  var roundBorderLayer: CALayer?
  var roundLayer: CALayer?

  override func layoutSubviews() {
    super.layoutSubviews()
    circleComponentLayoutSubviews(self)
  }

  override func intrinsicContentSize() -> CGSize {
    return circleComponentIntrinsicContentSize(self) ?? super.intrinsicContentSize()
  }
}

// MARK: RoundedRectImageView

//@IBDesignable
class RoundedRectLabel: UILabel, RoundedRectComponent {

  @IBInspectable
  var roundedRectSize: CGSize = CGSizeZero {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderColor: UIColor = UIColor.blackColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var filledColor: UIColor = UIColor.clearColor() {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var borderWidth: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  @IBInspectable
  var cornerRadius: CGFloat = 0 {
    didSet { setNeedsLayout() }
  }

  var hasRoundedRectLayer: Bool { return filledColor != UIColor.clearColor() }
  var hasRoundedRectBorderLayer: Bool { return borderWidth > 0 }

  var roundedRectLayer: CAShapeLayer?
  var roundedRectBorderLayer: CAShapeLayer?
  
  override func layoutSubviews() {
    super.layoutSubviews()
    roundedRectComponentLayoutSubviews(self)
  }
  
  override func intrinsicContentSize() -> CGSize {
    return roundedRectComponentIntrinsicContentSize(self) ?? super.intrinsicContentSize()
  }
}
extension UIFont {

  func heightOfString (string: String, constrainedToWidth width: CGFloat) -> CGFloat {
    return string.boundingRectWithSize(CGSize(width: width, height: CGFloat.max),
      options: NSStringDrawingOptions.UsesLineFragmentOrigin,
      attributes: [NSFontAttributeName: self],
      context: nil).size.height
  }
}

struct Colors {

  static let facebookBlue = UIColor(
    red: 53/255.0,
    green: 79/255.0,
    blue: 144/255.0,
    alpha: 1
  )

  static let twitterBlue = UIColor(
    red: 0/255.0,
    green: 171/255.0,
    blue: 234/255.0,
    alpha: 1
  )

  static let blue = UIColor(
    red: 52/255.0,
    green: 52/255.0,
    blue: 88/255.0,
    alpha: 1
  )

  static let red = UIColor(
    red: 255/255.0,
    green: 51/255.0,
    blue: 51/255.0,
    alpha: 1
  )

  static let green = UIColor(
    red: 167/255.0,
    green: 246/255.0,
    blue: 67/255.0,
    alpha: 1
  )

  static let gray = UIColor(
    red: 170/255.0,
    green: 170/255.0,
    blue: 170/255.0,
    alpha: 1
  )

  // color for follow btn in ProfileAvatarViewController
  static let lightblue = UIColor(
    red:  0/255.0,
    green: 171/255.0,
    blue: 234/255.0,
    alpha: 1
  )

  static let userCellColors: [UIColor] = [
    Colors.blue,
    UIColor(red:0.13, green:0.13, blue:0.2, alpha:1),
    UIColor(red:0.16, green:0.16, blue:0.26, alpha:1),
    UIColor(red:0.24, green:0.24, blue:0.39, alpha:1),
    UIColor(red:0.32, green:0.32, blue:0.51, alpha:1)
  ]
}






