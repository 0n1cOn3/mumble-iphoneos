import SwiftUI
import MumbleCore

@main
struct MumbleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var connectionController = ConnectionController()

    var body: some View {
        VStack {
            Text(connectionController.status)
                .padding()
            Button("Connect") {
                connectionController.connect()
            }
            .disabled(connectionController.isConnected)
            Button("Disconnect") {
                connectionController.disconnect()
            }
            .disabled(!connectionController.isConnected)
        }
        .padding()
    }
}

final class ConnectionController: ObservableObject {
    @Published var status = "Disconnected"

    private let connection = Connection(host: "localhost", port: 64738)
    var isConnected: Bool { connectionIsConnected }
    private var connectionIsConnected = false

    init() {
        connection.delegate = self
    }

    func connect() {
        connection.connect()
    }

    func disconnect() {
        connection.disconnect()
    }
}

extension ConnectionController: ConnectionDelegate {
    func connectionDidOpen(_ connection: Connection) {
        connectionIsConnected = true
        DispatchQueue.main.async { self.status = "Connected" }
    }

    func connection(_ connection: Connection, didReceive data: Data, type: MessageType) {
        // For this demo just log the ping.
        if type == .ping {
            print("Ping: \(data)")
        }
    }

    func connection(_ connection: Connection, didCloseWith error: Error?) {
        connectionIsConnected = false
        DispatchQueue.main.async { self.status = "Disconnected" }
    }
}
