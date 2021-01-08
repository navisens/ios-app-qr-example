# ios-app-qr-example

## What it does

This project demonstrates an implementation of the Simultaneous Localization and Mapping (SLAM) functionality of the MotionDNA SDK core.

The projects messages read from detected QR codes as an identifier in a [SLAM observation](https://github.com/navisens/NaviDocs/blob/master/API.iOS.md#simultaneous-localization-and-mapping-slam).

## Setup

In our SDK we provide `MotionDnaSDKDelegate` class. In order for MotionDna to work, we need a class implements all the required delegate methods.

```swift
class MotionDnaManager: MotionDnaSDKDelegate {
  override func receive(motionDna: MotionDna) {...}
  override func report(status: MotionDnaSDK.Status, message: String) {...}
}
```

Enter your developer key in `startMotionDna()` in `ViewController.swift` and run the app. If you do not have one yet then please navigate to our [developer sign up page](https://www.navisens.com/index.html#contact) to request a free key.

```swift
func startMotionDna() {
    motionDnaSDK = MotionDnaSDK(delegate: self)
    let devKey = "<--DEVELOPER-KEY-HERE-->"
    motionDnaSDK.start(withDeveloperKey: devKey)
    }
```

## Get your Cartesian coordinates

In the `receive(motionDna: MotionDna)` callback method we return a `MotionDna` estimation object which contains [location, heading and motion type](https://github.com/navisens/NaviDocs/blob/master/API.iOS.md#estimation-properties) among many other interesting data on a users current state. Here is how we might print the cartesian values out.

```swift
func receive(motionDna: MotionDna) {
    DispatchQueue.main.async {
        self.xyzLabel.text =
            String(format: "x: %.2f, y: %.2f, z: %.2f", arguments: [
                motionDna.location.cartesian.x,
                motionDna.location.cartesian.y,
                motionDna.location.cartesian.z ])
    }
}
```

## Record a SLAM observation (from a QR code)

The project scans a QR code using `ScannerViewController.swift` and receives a String message from the QR code when performing the segue back.

```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? ViewController {
        vc.qrMessage = qrMessage
    }
}
```

The hash code of the String message received from the QR code is used as an identifier and recorded as a new [SLAM observation](https://github.com/navisens/NaviDocs/blob/master/API.iOS.md#simultaneous-localization-and-mapping-slam) with an uncertainty of `1.0` meter.

```swift
var qrMessage: String? = String() {
    didSet(oldMessage) {
        if let message = qrMessage {
            motionDnaSDK.recordObservation(withIdentifier: message.hashValue, uncertainty: 1.0)
        }
    }
}
```

## Common task

A user is indoors and revisits the same areas frequently. Through some outside mechanism the developer is aware of a return to certain landmarks and would like to indicate that the user has returned to a landmark with ID of 38 to aid in the estimation of a user's position. The developer also knows that this observation was made within `3.0` meters of the landmark `38`.

```swift
motionDnaSDK.recordObservation(withIdentifier: 38, uncertainty: 3.0)
```
