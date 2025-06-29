import Foundation
import MumbleKit

@objc(MUConnectionController)
@MainActor
final class MUConnectionController: NSObject, MKConnectionDelegate {
    @Published private(set) var status = "Disconnected"

    private let connection = MKConnection(host: "localhost", port: 64738)
    var isConnected: Bool { connectionIsConnected }
    private var connectionIsConnected = false

    override init() {
        super.init()
        connection.delegate = self
    }

    func connect() {
        connection.connect()
    }

    func disconnect() {
        connection.disconnect()
    }

    // MARK: MKConnectionDelegate
    func connectionOpened(_ conn: MKConnection!) {
        connectionIsConnected = true
        status = "Connected"
    }

    func connection(_ conn: MKConnection!, closedWithError err: Error!) {
        connectionIsConnected = false
        status = "Disconnected"
    }

    func connection(_ conn: MKConnection!, unableToConnectWithError err: Error!) {
        connectionIsConnected = false
        status = "Error"
    }
}
