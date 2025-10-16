import SwiftUI

extension Font {
    
    static func interMedium(size: CGFloat) -> Font {
        .custom("InterTight-Medium", size: size)
    }
    
    static func interSemiBold(size: CGFloat) -> Font {
        .custom("InterTight-SemiBold", size: size)
    }
}

extension UIFont {
    static func interMediumUIKit(size: CGFloat) -> UIFont {
        return UIFont(name: "InterTight-Medium.ttf", size: size)!
    }
}
