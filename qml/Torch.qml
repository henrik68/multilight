// Copyright (C) 2026 Henrik Christiansen - GNU GPL v3 (see LICENSE)
// Light backend for the OpenStore version: switches the flashlight through the camera
// ("video light" flash mode), like uTorch does. Works on most Ubuntu Touch phones and needs
// only the "camera" permission (no system files, no unconfined app).
// Same interface as the sysfs backend of the personal version: set(on), isOn, error(message).
import QtQuick 2.12
import QtMultimedia 5.12

Item {
    id: torch
    width: 1
    height: 1

    property bool isOn: false
    // true when the camera could not be opened (no permission, or the camera is busy)
    property bool failed: false

    signal error(string message)

    function set(on) {
        isOn = on
    }

    // (Re)open the camera. Done shortly after start, and again when the app comes back
    // to the front if it had failed (e.g. after the user allowed camera access).
    function restart() {
        camera.cameraState = Camera.LoadedState
        camera.cameraState = Camera.ActiveState
    }

    Camera {
        id: camera
        // Ask for the back camera: the light is only switched if the open camera has a flash
        // (the driver ignores flash modes the camera doesn't list). Tested on Xperia XA2:
        // back camera supports FlashVideoLight (64), not FlashTorch (32).
        position: Camera.BackFace
        flash.mode: torch.isOn ? Camera.FlashVideoLight : Camera.FlashOff
        onError: {
            torch.failed = true
            torch.error(errorString)
        }
        // The system closes the camera when the app goes to the background; only count it
        // as a failure while the app is in front.
        onCameraStateChanged: torch.failed = (cameraState === Camera.UnloadedState && Qt.application.active)
    }

    // A tiny video output; some phones only switch the light while the camera has an output.
    VideoOutput {
        source: camera
        width: 1
        height: 1
    }

    Timer {
        id: startTimer
        interval: 400
        onTriggered: torch.restart()
    }
    Component.onCompleted: startTimer.start()

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (!Qt.application.active)
                torch.failed = false
            else if (camera.cameraState === Camera.UnloadedState || torch.failed)
                startTimer.start()
        }
    }
}
