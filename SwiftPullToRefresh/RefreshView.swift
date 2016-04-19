/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

protocol RefreshViewDelegate: class {
  func refreshViewDidRefresh(refreshView: RefreshView)
}

private let sceneHeight: CGFloat = 120

class RefreshView: UIView {
  private unowned var scrollView: UIScrollView
  var progressPercentage: CGFloat = 0
  weak var delegate: RefreshViewDelegate?

  var isRefreshing = false

  var refreshItems = [RefreshItem]()

  var signRefreshItem: RefreshItem!
  var isSignVisible = false

  var cloudViews: (UIView, UIView)!

  required init?(coder aDecoder: NSCoder) {
    scrollView = UIScrollView()
    assert(false, "use init(frame:scrollView:)")
    super.init(coder: aDecoder)
  }

  init(frame: CGRect, scrollView: UIScrollView) {
    self.scrollView = scrollView
    super.init(frame: frame)

    clipsToBounds = true
    updateBackgroundColor()
    setupRefreshItems()
  }

  func setupRefreshItems() {
    let groundImageView = UIImageView(image: UIImage(named: "ground"))
    let buildingsImageView = UIImageView(image: UIImage(named: "buildings"))
    let sunImageView = UIImageView(image: UIImage(named: "sun"))
    let catImageView = UIImageView(image: UIImage(named: "cat"))
    let capeBackImageView = UIImageView(image: UIImage(named: "cape_back"))
    let capeFrontImageView = UIImageView(image: UIImage(named: "cape_front"))

    refreshItems = [
      RefreshItem(view: buildingsImageView,
        centerEnd: CGPoint(x: CGRectGetMidX(bounds),
          y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds) - CGRectGetHeight(buildingsImageView.bounds) / 2), parallaxRatio: 1.5, sceneHeight: sceneHeight),
      RefreshItem(view: sunImageView,
        centerEnd: CGPoint(x: CGRectGetWidth(bounds) * 0.1, y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds) - CGRectGetHeight(sunImageView.bounds)),
        parallaxRatio: 3, sceneHeight: sceneHeight),
      RefreshItem(view: groundImageView,
        centerEnd: CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds)/2),
        parallaxRatio: 0.5, sceneHeight: sceneHeight),
      RefreshItem(view: capeBackImageView, centerEnd: CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds)/2 - CGRectGetHeight(capeBackImageView.bounds)/2), parallaxRatio: -1, sceneHeight: sceneHeight),
      RefreshItem(view: catImageView, centerEnd: CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds)/2 - CGRectGetHeight(catImageView.bounds)/2), parallaxRatio: 1, sceneHeight: sceneHeight),
      RefreshItem(view: capeFrontImageView, centerEnd: CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetHeight(bounds) - CGRectGetHeight(groundImageView.bounds)/2 - CGRectGetHeight(capeFrontImageView.bounds)/2), parallaxRatio: -1, sceneHeight: sceneHeight),
    ]

    for refreshItem in refreshItems {
      addSubview(refreshItem.view)
    }

    let signImageView = UIImageView(image: UIImage(named: "sign"))
    signRefreshItem = RefreshItem(view: signImageView, centerEnd: CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetHeight(bounds) - CGRectGetHeight(signImageView.bounds)/2), parallaxRatio: 0.5, sceneHeight: sceneHeight)
    addSubview(signImageView)

    // uber challenge: add cloud views
    cloudViews = (createCloudView(), createCloudView())
    cloudViews.0.alpha = 0
    cloudViews.1.alpha = 0
    insertSubview(cloudViews.0, atIndex: 0)
    insertSubview(cloudViews.1, atIndex: 0)
  }

  func showSign(show: Bool) {
    if isSignVisible == show {
      return
    }

    isSignVisible = show

    UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: { () -> Void in
      self.signRefreshItem.updateViewPositionForPercentage(show ? 1 : 0)
    }, completion: nil)
  }

  func updateBackgroundColor() {
    let value = progressPercentage * 0.7 + 0.2
    backgroundColor = UIColor(red: value, green: value, blue: value, alpha: 1.0)
  }

  func updateRefreshItemPositions() {
    for refreshItem in refreshItems {
      refreshItem.updateViewPositionForPercentage(progressPercentage)
    }
  }

  func beginRefreshing() {
    isRefreshing = true

    UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.scrollView.contentInset.top += sceneHeight
      }, completion: { (_) -> Void in
    })

    showSign(false)

    // Animate cat and cape
    let cape = refreshItems[5].view
    let cat = refreshItems[4].view
    cape.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/32))
    cat.transform = CGAffineTransformMakeTranslation(1.0, 0)
    UIView.animateWithDuration(0.2, delay: 0, options: [.Repeat, .Autoreverse], animations: { () -> Void in
      cape.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/32))
      cat.transform = CGAffineTransformMakeTranslation(-1.0, 0)
    }, completion: nil)

    // Animate ground and buildings
    let buildings = refreshItems[0].view
    let ground = refreshItems[2].view
    UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
      ground.center.y += sceneHeight
      buildings.center.y += sceneHeight
    }, completion: nil)

    // uber challenge: animate cloud views!
    let bounds = self.bounds
    cloudViews.0.center = CGPoint(x: CGRectGetMidX(bounds), y: -CGRectGetMidY(bounds))
    cloudViews.0.alpha = 1
    cloudViews.1.center = CGPoint(x: CGRectGetMidX(bounds), y: -CGRectGetMidY(bounds))
    cloudViews.1.alpha = 1

    // animate and synchronize with delays
    UIView.animateWithDuration(2.0, delay: 0.25, options: .Repeat, animations: { () -> Void in
      self.cloudViews.0.center.y = CGRectGetMidY(bounds) + CGRectGetHeight(bounds)
    }, completion: { (_) -> Void in
      self.cloudViews.0.center.y = -CGRectGetMidY(bounds)
    })

    UIView.animateWithDuration(2.0, delay: 1.25, options: .Repeat, animations: { () -> Void in
      self.cloudViews.1.center.y = CGRectGetMidY(bounds) + CGRectGetHeight(bounds)
    }, completion: { (_) -> Void in
        self.cloudViews.1.center.y = -CGRectGetMidY(bounds)
    })

  }

  func endRefreshing() {
    UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.scrollView.contentInset.top -= sceneHeight
      }, completion: { (_) -> Void in
        self.isRefreshing = false
    })

    let cape = refreshItems[5].view
    let cat = refreshItems[4].view
    cape.transform = CGAffineTransformIdentity
    cat.transform = CGAffineTransformIdentity
    cape.layer.removeAllAnimations()
    cat.layer.removeAllAnimations()

    // uber challenge: hide cloud views
    cloudViews.0.alpha = 0
    cloudViews.0.layer.removeAllAnimations()
    cloudViews.1.alpha = 0
    cloudViews.1.layer.removeAllAnimations()
  }

  // uber-challenge: create a cloud view
  func createCloudView() -> UIView {
    let cloudView = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(bounds), height: CGRectGetHeight(bounds)))

    let width = CGRectGetWidth(cloudView.bounds)
    let height = CGRectGetHeight(cloudView.bounds)
    let centerPoints = [
      CGPoint(x: width * 0.2, y: height * 0.2),
      CGPoint(x: width * 0.5, y: height * 0.5),
      CGPoint(x: width * 0.8, y: height * 0.8),
      CGPoint(x: width * 0.3, y: height * 0.4),
      CGPoint(x: width * 0.7, y: height * 0.3),
      CGPoint(x: width * 0.1, y: height * 0.8),
    ]

    for (index, centerPoint) in centerPoints.enumerate() {
      let imageIndex = (index % 3) + 1
      let cloud = UIImageView(image: UIImage(named: "cloud_\(imageIndex)"))
      cloud.center = centerPoint
      cloudView.addSubview(cloud)
    }

    return cloudView
  }

}

extension RefreshView: UIScrollViewDelegate {
  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if !isRefreshing && progressPercentage == 1 {
      beginRefreshing()
      targetContentOffset.memory.y = -scrollView.contentInset.top
      delegate?.refreshViewDidRefresh(self)
    }
  }

  func scrollViewDidScroll(scrollView: UIScrollView) {
    if isRefreshing {
      return
    }

    let refreshViewVisibleHeight = max(0, -(scrollView.contentOffset.y + scrollView.contentInset.top))
    progressPercentage = min(1, refreshViewVisibleHeight / sceneHeight)

    updateBackgroundColor()
    updateRefreshItemPositions()
    showSign(progressPercentage == 1)
  }
}
