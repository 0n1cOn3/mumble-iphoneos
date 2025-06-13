import XCTest
@testable import MumbleApp
@testable import MumbleCore

final class MumbleAppTests: XCTestCase {
    final class Delegate: ConnectionDelegate {
        var didOpen = false
        var didClose = false
        func connectionDidOpen(_ connection: Connection) { didOpen = true }
        func connection(_ connection: Connection, didReceive data: Data, type: MessageType) {}
        func connection(_ connection: Connection, didCloseWith error: Error?) { didClose = true }
    }

    func testConnectionOpenClose() {
        let conn = Connection(host: "localhost", port: 1234)
        let delegate = Delegate()
        conn.delegate = delegate
        conn.connect()
        conn.disconnect()
        XCTAssertTrue(delegate.didOpen)
        XCTAssertTrue(delegate.didClose)
    }
}
