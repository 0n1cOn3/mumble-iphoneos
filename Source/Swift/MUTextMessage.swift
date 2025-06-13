import UIKit

@objcMembers
public class MUTextMessage: NSObject {
    private var headingValue: String?
    private var msg: String?
    private var dateValue: Date?
    private var links: [Any]?
    private var images: [Any]?
    private var sentBySelf: Bool

    init(heading: String?, message: String?, date: Date?, embeddedLinks: [Any]?, embeddedImages: [Any]?, timestampDate: Date?, sentBySelf: Bool) {
        self.headingValue = heading
        self.msg = message
        self.dateValue = date
        self.links = embeddedLinks
        self.images = embeddedImages
        self.sentBySelf = sentBySelf
    }

    public override convenience init() {
        self.init(heading: nil, message: nil, date: nil, embeddedLinks: nil, embeddedImages: nil, timestampDate: nil, sentBySelf: false)
    }

    public class func textMessage(withHeading heading: String?, andMessage msg: String?, andEmbeddedLinks links: [Any]?, andEmbeddedImages images: [Any]?, andTimestampDate timestampDate: Date?, isSentBySelf sentBySelf: Bool) -> MUTextMessage {
        return MUTextMessage(heading: heading, message: msg, date: timestampDate, embeddedLinks: links, embeddedImages: images, timestampDate: timestampDate, sentBySelf: sentBySelf)
    }

    public var heading: String? { headingValue }
    public var message: String? { msg }
    public var date: Date? { dateValue }
    public var embeddedLinks: [Any]? { links }
    public var embeddedImages: [Any]? { images }

    public func numberOfAttachments() -> Int {
        return (links?.count ?? 0) + (images?.count ?? 0)
    }

    public func hasAttachments() -> Bool {
        return numberOfAttachments() > 0
    }

    public func isSentBySelf() -> Bool {
        return sentBySelf
    }
}
