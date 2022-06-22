import Foundation

let swizzler: (AnyClass, AnyClass, Selector, Selector) -> Void = { mainClass, swizzledClass, originalSelector, swizzledSelector in
    guard let swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector) else {
        return
    }

    if let originalMethod = class_getInstanceMethod(mainClass, originalSelector) {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    } else {
        class_addMethod(mainClass, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    }
}
