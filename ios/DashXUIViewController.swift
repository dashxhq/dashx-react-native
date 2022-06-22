import Foundation

extension UIViewController {
    static func swizzle() {
        let originalSelector = #selector(viewDidLoad)
        let swizzledSelector = #selector(swizzledViewDidLoad)
        swizzler(UIViewController.self, UIViewController.self, originalSelector, swizzledSelector)
    }

    @objc func swizzledViewDidLoad() {
        DashXClient.instance.track(Constants.INTERNAL_EVENT_APP_SCREEN_VIEWED, withData: [:])
        // Call the original viewDidLoad - using the swizzledViewDidLoad signature
        swizzledViewDidLoad()
    }
}
