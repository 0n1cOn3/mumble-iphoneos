import UIKit
import MumbleKit

private func showAlertDialog(title: String, msg: String) {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
}

class MUCertificateDiskImportViewController: UITableViewController, UITextFieldDelegate {
    private var showHelp = false
    private var diskCertificates: [String] = []
    private var attemptIndexPath: IndexPath?

    private weak var passwordField: UITextField?

    override init(style: UITableView.Style) {
        let documentDirs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let dirContents = (try? FileManager.default.contentsOfDirectory(atPath: documentDirs.first ?? "")) ?? []
        var diskCerts: [String] = []
        for fileName in dirContents {
            if fileName.hasSuffix(".pkcs12") || fileName.hasSuffix(".p12") || fileName.hasSuffix(".pfx") {
                diskCerts.append(fileName)
            }
        }
        var tableStyle: UITableView.Style = .grouped
        if !diskCerts.isEmpty { tableStyle = .plain }
        super.init(style: tableStyle)
        if tableStyle == .grouped { showHelp = true }
        diskCertificates = diskCerts
        self.preferredContentSize = CGSize(width: 320, height: 480)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tableView.style == .grouped {
            tableView.backgroundView = MUBackgroundView.backgroundView()
        } else if #available(iOS 7, *) {
            tableView.separatorStyle = .singleLine
            tableView.separatorInset = .zero
        }
        navigationItem.title = NSLocalizedString("iTunes Import", comment: "Import a certificate from iTunes")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked(_:)))
        if !showHelp {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionClicked(_:)))
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { diskCertificates.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "DiskCertificateCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
        cell.imageView?.image = UIImage(named: "certificatecell")
        cell.textLabel?.text = diskCertificates[indexPath.row]
        cell.accessoryType = .none
        cell.selectionStyle = .gray
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 85.0 }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        attemptIndexPath = indexPath
        tryImportCertificate(password: nil)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if showHelp {
            let help = NSLocalizedString("To import your own certificate into\nMumble, please transfer them to your\ndevice using iTunes File Transfer.", comment: "Help text for iTunes File Transfer")
            let lbl = MUTableViewHeaderLabel.label(withText: help)
            lbl.font = UIFont.systemFont(ofSize: 16)
            lbl.lineBreakMode = .byWordWrapping
            lbl.numberOfLines = 0
            return lbl
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { showHelp ? 80.0 : 0.0 }

    private func tryImportCertificate(password: String?) {
        guard let fileName = diskCertificates[attemptIndexPath?.row ?? 0] as String? else { return }
        let dirs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let file = (dirs.first! as NSString).appendingPathComponent(fileName)
        guard let pkcs12Data = try? Data(contentsOf: URL(fileURLWithPath: file)) else { return }
        let chain = MKCertificate.certificates(withPKCS12: pkcs12Data, password: password)
        if chain.isEmpty {
            showPasswordDialog()
            tableView.deselectRow(at: attemptIndexPath!, animated: true)
            return
        }
        let leaf = chain[0]
        guard let transformedData = leaf.exportPKCS12(withPassword: "") else {
            showAlertDialog(title: NSLocalizedString("Import Error", comment: ""), msg: NSLocalizedString("Mumble was unable to export the specified certificate.", comment: ""))
            tableView.deselectRow(at: attemptIndexPath!, animated: true)
            return
        }
        let dict = [kSecImportExportPassphrase as String: ""]
        var items: CFArray?
        let err = SecPKCS12Import(transformedData as CFData, dict as CFDictionary, &items)
        if err == errSecSuccess, let arr = items as? [[String: Any]] {
            for cert in chain.dropFirst() {
                if let secCert = SecCertificateCreateWithData(nil, cert.certificate as CFData) {
                    let op = [kSecValueRef as String: secCert] as CFDictionary
                    let r = SecItemAdd(op, nil)
                    if r != errSecSuccess && r != errSecDuplicateItem {
                        showAlertDialog(title: NSLocalizedString("Import Error", comment: ""), msg: NSLocalizedString("Mumble was unable to import one of the intermediate certificates in the certificate chain.", comment: ""))
                    }
                }
            }
            if let pkcsDict = arr.first, let identity = pkcsDict[kSecImportItemIdentity as String] {
                let op = [kSecValueRef as String: identity, kSecReturnPersistentRef as String: true] as CFDictionary
                var dataRef: CFTypeRef?
                let addErr = SecItemAdd(op, &dataRef)
                if addErr == errSecSuccess, let dataRef = dataRef as? Data {
                    if MUCertificateController.defaultCertificate() == nil { MUCertificateController.setDefaultCertificate(byPersistentRef: dataRef) }
                    try? FileManager.default.removeItem(atPath: file)
                    tableView.deselectRow(at: attemptIndexPath!, animated: true)
                    diskCertificates.remove(at: attemptIndexPath!.row)
                    tableView.deleteRows(at: [attemptIndexPath!], with: .fade)
                    return
                } else if addErr == errSecDuplicateItem || (addErr == errSecSuccess && dataRef == nil) {
                    showAlertDialog(title: NSLocalizedString("Import Error", comment: ""), msg: NSLocalizedString("A certificate with the same name already exist.", comment: ""))
                } else {
                    let msg = String(format: NSLocalizedString("Mumble was unable to import the certificate.\nError Code: %li", comment: ""), addErr)
                    showAlertDialog(title: "Import Error", msg: msg)
                }
            }
            tableView.deselectRow(at: attemptIndexPath!, animated: true)
        } else if err == errSecAuthFailed {
            showPasswordDialog()
            tableView.deselectRow(at: attemptIndexPath!, animated: true)
        } else if err == errSecDecode {
            showAlertDialog(title: NSLocalizedString("Import Error", comment: ""), msg: "Unable to decode PKCS12 file")
            tableView.deselectRow(at: attemptIndexPath!, animated: true)
        } else {
            showAlertDialog(title: NSLocalizedString("Import Error", comment: ""), msg: NSLocalizedString("Mumble was unable to import the certificate.", comment: ""))
            tableView.deselectRow(at: attemptIndexPath!, animated: true)
        }
    }

    private func showPasswordDialog() {
        let title = NSLocalizedString("Enter Password", comment: "")
        let msg = NSLocalizedString("The certificate is protected by a password. Please enter it below:", comment: "")
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addTextField { $0.isSecureTextEntry = true; self.passwordField = $0 }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            self.tryImportCertificate(password: self.passwordField?.text)
        })
        present(alert, animated: true)
    }

    private func removeAllDiskCertificates() {
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        for fn in diskCertificates {
            let path = (dir as NSString).appendingPathComponent(fn)
            if let err = try? FileManager.default.removeItem(atPath: path) { }
            else {
                let title = NSLocalizedString("Unable to remove file", comment: "")
                let msg = String(format: NSLocalizedString("File '%@' could not be deleted: %@", comment: ""), fn, "")
                let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
                present(alert, animated: true)
            }
        }
        diskCertificates.removeAll()
        tableView.reloadData()
    }

    @objc private func doneClicked(_ sender: Any) { dismiss(animated: true) }

    private func showRemoveAlert() {
        let title = NSLocalizedString("Remove Importable Certificates", comment: "")
        let msg = NSLocalizedString("Are you sure you want to delete all importable certificates?\n\nCertificates already imported into Mumble will not be touched.", comment: "")
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default) { _ in
            self.removeAllDiskCertificates()
        })
        present(alert, animated: true)
    }

    @objc private func actionClicked(_ sender: Any) {
        let title = NSLocalizedString("Import Actions", comment: "")
        let sheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: NSLocalizedString("Remove All", comment: "Remove all importable certificates action."), style: .destructive) { _ in
            self.showRemoveAlert()
        })
        present(sheet, animated: true)
    }
}

