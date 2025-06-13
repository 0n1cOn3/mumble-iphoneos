import UIKit
import MumbleKit

@objcMembers
public class MUUserStateAcessoryView: NSObject {
    public class func view(for user: MKUser) -> UIView {
        let iconHeight: CGFloat = 24
        let iconWidth: CGFloat = 28
        var states: [String] = []
        if user.isAuthenticated() { states.append("authenticated") }
        if user.isSelfDeafened() { states.append("deafened_self") }
        if user.isSelfMuted() { states.append("muted_self") }
        if user.isMuted() { states.append("muted_server") }
        if user.isDeafened() { states.append("deafened_server") }
        if user.isLocalMuted() { states.append("muted_local") }
        if user.isSuppressed() { states.append("muted_suppressed") }
        if user.isPrioritySpeaker() { states.append("priorityspeaker") }

        var widthOffset = CGFloat(states.count) * iconWidth
        let stateView = UIView(frame: CGRect(x: 0, y: 0, width: widthOffset, height: iconHeight))
        for imageName in states {
            guard let img = UIImage(named: imageName) else { continue }
            let imgView = UIImageView(image: img)
            let ypos = (iconHeight - img.size.height) / 2.0
            let xpos = (iconWidth - img.size.width) / 2.0
            widthOffset -= iconWidth - xpos
            imgView.frame = CGRect(x: ceil(widthOffset), y: ceil(ypos), width: img.size.width, height: img.size.height)
            stateView.addSubview(imgView)
        }
        return stateView
    }
}
