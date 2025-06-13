import UIKit
import Combine

@objc(MUNotificationController)
@MainActor
public final class MUNotificationController: NSObject {
    @objc(sharedController)
    public static let shared = MUNotificationController()

    private var notificationView: UIView?
    private var notificationQueue: [String] = []
    private var running = false
    private var keyboardFrame: CGRect = .zero
    private var cancellables: Set<AnyCancellable> = []

    private override init() {
        super.init()
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .sink { [weak self] frame in
                self?.keyboardFrame = frame
            }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)
            .sink { [weak self] _ in
                self?.keyboardFrame = .zero
            }
            .store(in: &cancellables)
    }

    @objc(addNotification:)
    public func addNotification(_ text: String) {
        if notificationQueue.count < 10 {
            notificationQueue.append(text)
        }
        if !running {
            showNext()
        }
    }

    private func showNext() {
        running = true

        let screenBounds = UIScreen.main.bounds
        let width = ceil(screenBounds.width - 50.0)
        let height: CGFloat = 50.0
        let frame = CGRect(x: 25.0,
                           y: ceil((screenBounds.height - keyboardFrame.height) / 2) - 25.0,
                           width: width,
                           height: height)

        let container = UIView(frame: frame)
        container.alpha = 0.0
        container.isUserInteractionEnabled = false

        let bg = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        bg.layer.cornerRadius = 8.0
        bg.backgroundColor = .black
        bg.alpha = 0.8
        container.addSubview(bg)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.font = .systemFont(ofSize: 16.0)
        label.text = notificationQueue.removeFirst()
        label.textColor = .white
        label.backgroundColor = .clear
        label.textAlignment = .center
        container.addSubview(label)

        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(container)
        }

        notificationView = container
        UIView.animate(withDuration: 0.1) {
            container.alpha = 1.0
        } completion: { _ in
            Task {
                try? await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000))
                await self.hideCurrent()
            }
        }
    }

    private func hideCurrent() {
        guard let current = notificationView else { return }
        UIView.animate(withDuration: 0.1) {
            current.alpha = 0.0
        } completion: { _ in
            current.removeFromSuperview()
            self.notificationView = nil
            if !self.notificationQueue.isEmpty {
                self.showNext()
            } else {
                self.running = false
            }
        }
    }
}
