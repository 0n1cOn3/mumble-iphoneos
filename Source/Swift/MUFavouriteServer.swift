import UIKit

@objcMembers
public class MUFavouriteServer: NSObject, NSCopying {
    public var primaryKey: Int = -1
    public var displayName: String?
    public var hostName: String?
    public var port: UInt = 0
    public var userName: String?
    public var password: String?

    public init(displayName: String?, hostName: String?, port: UInt, userName: String?, password: String?) {
        self.displayName = displayName
        self.hostName = hostName
        self.port = port
        self.userName = userName
        self.password = password
    }

    public override convenience init() {
        self.init(displayName: nil, hostName: nil, port: 0, userName: nil, password: nil)
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = MUFavouriteServer(displayName: displayName, hostName: hostName, port: port, userName: userName, password: password)
        if hasPrimaryKey() { copy.primaryKey = primaryKey }
        return copy
    }

    public func hasPrimaryKey() -> Bool {
        return primaryKey != -1
    }

    public func compare(_ favServ: MUFavouriteServer) -> ComparisonResult {
        return (displayName ?? "").caseInsensitiveCompare(favServ.displayName ?? "")
    }
}
