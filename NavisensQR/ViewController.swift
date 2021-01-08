//
//  ViewController.swift
//  NavisensQR
//
//  Created by Long Lam on 30/10/20.
//

import UIKit
import MotionDnaSDK

class ViewController: UIViewController, MotionDnaSDKDelegate {

    @IBOutlet var qrLabel: UILabel!
    @IBOutlet var xyzLabel: UILabel!
    @IBOutlet var scanButton: UIButton!

    var motionDnaSDK: MotionDnaSDK!

    var qrMessage: String? = String() {
        willSet(newMessage) {
        }
        didSet(oldMessage) {
            if let message = qrMessage {
                qrLabel.text = message
                motionDnaSDK.recordObservation(withIdentifier: message.hashValue, uncertainty: 1.0)
            }
            else {
                qrLabel.text = "None detected"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startMotionDna()

    }

    // MARK: - Navigation


    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }


    // MARK: - Navisens methods

    func startMotionDna() {
        motionDnaSDK = MotionDnaSDK(delegate: self)
        let devKey = "<--DEVELOPER-KEY-HERE-->"
        motionDnaSDK.start(withDeveloperKey: devKey)
    }

    func receive(motionDna: MotionDna) {
        DispatchQueue.main.async {
            self.scanButton.isEnabled = true
            self.xyzLabel.text =
                String(format: "x: %.2f, y: %.2f, z: %.2f", arguments: [
                        motionDna.location.cartesian.x,
                        motionDna.location.cartesian.y,
                        motionDna.location.cartesian.z ])
        }
    }

    func report(status: MotionDnaSDK.Status, message: String) {
        switch status {
            case .sensorTimingIssue:
                print("Error: Sensor Timing "  + message)
            case .authenticationFailure:
                print("Error: Authentication Failed " + message)
            case .missingSensor:
                print("Error: Sensor Missing " + message)
            case .expiredSDK:
                print("Error: SDK Expired " + message)
            case .authenticationSuccess:
                print("Status Authenticated: " + message)
            case .permissionsFailure:
                print("Status Permissions: " + message)
            case .none:
                print("Status None: " + message)
            default:
                print("Error Unknown: " + message)
        }
    }

}
