import UIKit

@objcMembers
class MUPreferencesViewController: UITableViewController {
    private var activeTextField: UITextField?

    init() {
        super.init(style: .grouped)
        preferredContentSize = CGSize(width: 320, height: 480)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        UserDefaults.standard.synchronize()
        (UIApplication.shared.delegate as? MUApplicationDelegate)?.reloadPreferences()
    }

    // MARK: - Looks

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationController?.navigationBar.barStyle = .blackOpaque
            navigationController?.navigationBar.setBackgroundImage(MUImage.clearColorImage(), for: .default)
            navigationController?.navigationBar.isTranslucent = true
        }

        tableView.backgroundView = MUBackgroundView.backgroundView()

        if #available(iOS 7, *) {
            tableView.separatorStyle = .singleLine
            tableView.separatorInset = .zero
        } else {
            tableView.separatorStyle = .none
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        title = NSLocalizedString("Preferences", comment: "")
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            #if ENABLE_REMOTE_CONTROL
            return 3
            #else
            return 2
            #endif
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "PreferencesCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
        cell.selectionStyle = .gray
        cell.accessoryType = .none

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let volSlider = UISlider()
                volSlider.minimumTrackTintColor = .black
                volSlider.maximumValue = 1.0
                volSlider.minimumValue = 0.0
                volSlider.value = UserDefaults.standard.float(forKey: "AudioOutputVolume")
                cell.textLabel?.text = NSLocalizedString("Volume", comment: "")
                cell.accessoryView = volSlider
                cell.selectionStyle = .none
                volSlider.addTarget(self, action: #selector(audioVolumeChanged(_:)), for: .valueChanged)
            } else if indexPath.row == 1 {
                let transmitCell = tableView.dequeueReusableCell(withIdentifier: "AudioTransmitCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "AudioTransmitCell")
                transmitCell.textLabel?.text = NSLocalizedString("Transmission", comment: "")
                let xmit = UserDefaults.standard.string(forKey: "AudioTransmitMethod")
                if xmit == "vad" {
                    transmitCell.detailTextLabel?.text = NSLocalizedString("Voice Activated", comment: "Voice activated transmission mode")
                } else if xmit == "ptt" {
                    transmitCell.detailTextLabel?.text = NSLocalizedString("Push-to-talk", comment: "Push-to-talk transmission mode")
                } else if xmit == "continuous" {
                    transmitCell.detailTextLabel?.text = NSLocalizedString("Continuous", comment: "Continuous transmission mode")
                }
                transmitCell.detailTextLabel?.textColor = MUColor.selectedTextColor()
                transmitCell.accessoryType = .disclosureIndicator
                transmitCell.selectionStyle = .gray
                return transmitCell
            } else if indexPath.row == 2 {
                cell.textLabel?.text = NSLocalizedString("Advanced", comment: "")
                cell.accessoryView = nil
                cell.accessoryType = .disclosureIndicator
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let tcpSwitch = UISwitch()
                tcpSwitch.isOn = UserDefaults.standard.bool(forKey: "NetworkForceTCP")
                cell.textLabel?.text = NSLocalizedString("Force TCP", comment: "")
                cell.accessoryView = tcpSwitch
                cell.selectionStyle = .none
                tcpSwitch.onTintColor = .black
                tcpSwitch.addTarget(self, action: #selector(forceTCPChanged(_:)), for: .valueChanged)
            } else if indexPath.row == 1 {
                let certCell = tableView.dequeueReusableCell(withIdentifier: "PrefCertificateCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "PrefCertificateCell")
                let cert = MUCertificateController.defaultCertificate()
                certCell.textLabel?.text = NSLocalizedString("Certificate", comment: "")
                certCell.detailTextLabel?.text = cert?.subjectName ?? NSLocalizedString("None", comment: "None (No certificate chosen)")
                certCell.detailTextLabel?.textColor = MUColor.selectedTextColor()
                certCell.accessoryType = .disclosureIndicator
                certCell.selectionStyle = .gray
                return certCell
            } else if indexPath.row == 2 {
                let remoteCell = tableView.dequeueReusableCell(withIdentifier: "RemoteControlCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "RemoteControlCell")
                remoteCell.textLabel?.text = NSLocalizedString("Remote Control", comment: "")
                let isOn = MURemoteControlServer.sharedRemoteControlServer().isRunning()
                remoteCell.detailTextLabel?.text = isOn ? NSLocalizedString("On", comment: "") : NSLocalizedString("Off", comment: "")
                remoteCell.detailTextLabel?.textColor = MUColor.selectedTextColor()
                remoteCell.accessoryType = .disclosureIndicator
                remoteCell.selectionStyle = .gray
                return remoteCell
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return MUTableViewHeaderLabel.label(withText: NSLocalizedString("Audio", comment: ""))
        } else if section == 1 {
            return MUTableViewHeaderLabel.label(withText: NSLocalizedString("Network", comment: ""))
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MUTableViewHeaderLabel.defaultHeaderHeight()
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                let audioXmit = MUAudioTransmissionPreferencesViewController()
                navigationController?.pushViewController(audioXmit, animated: true)
            } else if indexPath.row == 2 {
                let advAudio = MUAdvancedAudioPreferencesViewController()
                navigationController?.pushViewController(advAudio, animated: true)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 1 {
                let certPref = MUCertificatePreferencesViewController()
                navigationController?.pushViewController(certPref, animated: true)
            } else if indexPath.row == 2 {
                let remotePref = MURemoteControlPreferencesViewController()
                navigationController?.pushViewController(remotePref, animated: true)
            }
        }
    }

    // MARK: - Actions

    @objc func audioVolumeChanged(_ volumeSlider: UISlider) {
        UserDefaults.standard.set(volumeSlider.value, forKey: "AudioOutputVolume")
    }

    @objc func forceTCPChanged(_ tcpSwitch: UISwitch) {
        UserDefaults.standard.set(tcpSwitch.isOn, forKey: "NetworkForceTCP")
    }

    @objc func keyboardWasShown(_ notification: Notification) {
        // Placeholder for keyboard handling if needed
    }

    @objc func keyboardWillBeHidden(_ notification: Notification) {
        // Placeholder for keyboard handling if needed
    }
}

