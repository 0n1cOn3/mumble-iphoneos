import Foundation

public protocol ConnectionDelegate: AnyObject {
    func connectionDidOpen(_ connection: Connection)
    func connection(_ connection: Connection, didReceive data: Data, type: MessageType)
    func connection(_ connection: Connection, didCloseWith error: Error?)
}

public enum MessageType: UInt16 {
    case ping = 0
    case text = 1
    case voice = 2
    case unknown = 999
}

@MainActor
public final class Connection {
    private var host: String
    private var port: Int
    private var timer: Timer?
    private var isConnected = false
    public weak var delegate: ConnectionDelegate?

    public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }

    public func connect() {
        // This is a stub implementation. In a real client this would create a
        // network socket. Here we merely simulate an open connection.
        guard !isConnected else { return }
        isConnected = true
        delegate?.connectionDidOpen(self)
        startPing()
    }

    public func disconnect() {
        guard isConnected else { return }
        stopPing()
        isConnected = false
        delegate?.connection(self, didCloseWith: nil)
    }

    private func startPing() {
        timer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.sendPing() }
        }
    }

    private func stopPing() {
        timer?.invalidate()
        timer = nil
    }

    private func sendPing() async {
        let ts = UInt64(Date().timeIntervalSince1970)
        let buf = withUnsafeBytes(of: ts.bigEndian, Array.init)
        send(data: Data(buf), type: .ping)
    }

    public func send(data: Data, type: MessageType) {
        // In a real implementation data would be written to a socket.
        // We just call the delegate directly for testing.
        guard isConnected else { return }
        delegate?.connection(self, didReceive: data, type: type)
    }
}
