// Copyright (C) 2026 Henrik Christiansen - GNU GPL v3 (see LICENSE)
// Multi-light - flashlight with blink mode, SOS signal and screen light for Ubuntu Touch.
// OpenStore version: the light is switched through the camera (Torch.qml), all texts use
// i18n.tr() so they can be translated (po/*.po; English is used when a translation is missing).
import QtQuick 2.12
import Lomiri.Components 1.3

MainView {
    id: root
    // Must match "name" in manifest.json. It is also the translation domain (i18n.domain).
    applicationName: "multilight.henrik68"
    width: units.gu(45)
    height: units.gu(80)
    backgroundColor: "#1b1b1b"

    property bool lightOn: false      // light on (steady, or blinking if blinkRate > 0)
    property bool sosRunning: false
    property bool screenLight: false
    property int blinkRate: 0         // blinks per second when the light is on; 0 = steady (default)

    // ---- Light backend: camera "video light" ----
    Torch {
        id: torch
        x: -10                        // keep the 1 px camera output off screen
        y: -10
    }

    // ---- SOS in Morse: ... --- ...  (1 unit = 250 ms) ----
    readonly property int unit: 250
    // [light on?, length in units]
    readonly property var sosPattern: [
        [true, 1], [false, 1], [true, 1], [false, 1], [true, 1], [false, 3],   // S
        [true, 3], [false, 1], [true, 3], [false, 1], [true, 3], [false, 3],   // O
        [true, 1], [false, 1], [true, 1], [false, 1], [true, 1], [false, 7]    // S + pause
    ]
    property int sosIndex: 0

    Timer {
        id: sosTimer
        repeat: false
        onTriggered: root.sosStep()
    }

    function sosStep() {
        if (!sosRunning)
            return
        var p = sosPattern[sosIndex]
        torch.set(p[0])
        sosTimer.interval = p[1] * unit
        sosTimer.start()
        sosIndex = (sosIndex + 1) % sosPattern.length
    }

    // ---- Blink mode: light on + blinkRate > 0 -> on/off at that rate ----
    property bool blinkPhase: true
    Timer {
        id: blinkTimer
        interval: 500 / Math.max(1, root.blinkRate)     // half a blink: on, then off
        repeat: true
        running: root.lightOn && root.blinkRate > 0
        onRunningChanged: {
            root.blinkPhase = true
            if (root.lightOn)
                torch.set(true)       // blink turned off while the light is on: steady light
        }
        onTriggered: {
            root.blinkPhase = !root.blinkPhase
            torch.set(root.blinkPhase)
        }
    }

    function toggleLight() {
        stopSos()
        lightOn = !lightOn
        torch.set(lightOn)
    }

    function startSos() {
        lightOn = false
        sosIndex = 0
        sosRunning = true
        sosStep()
    }

    function stopSos() {
        if (!sosRunning)
            return
        sosRunning = false
        sosTimer.stop()
        torch.set(false)
    }

    Component.onDestruction: torch.set(false)

    // Keep the screen awake while something is running (needs the keep-display-on permission).
    Loader {
        active: root.sosRunning || root.screenLight || root.lightOn
        source: "KeepAwake.qml"
    }

    // ---- Main screen ----
    Page {
        id: page
        anchors.fill: parent
        header: PageHeader {
            title: "Multi-light"
        }

        Flickable {
            anchors {
                top: page.header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            contentHeight: mainColumn.height + units.gu(8)
            clip: true

            Column {
                id: mainColumn
                anchors {
                    top: parent.top
                    topMargin: units.gu(4)
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: units.gu(3)

                // Shown when the camera (= the light) can't be used.
                Column {
                    visible: torch.failed
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: units.gu(36)
                    spacing: units.gu(1)
                    Label {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        color: "#ff8080"
                        text: i18n.tr("Multi-light needs access to the camera to switch the flashlight. Allow it in System Settings, then come back. If it still does not work, restart the phone.")
                    }
                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: i18n.tr("Open settings")
                        onClicked: Qt.openUrlExternally("settings:///system/security-privacy?service=camera")
                    }
                }

                // Big round on/off button
                Rectangle {
                    id: bigButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: units.gu(24)
                    height: width
                    radius: width / 2
                    color: root.lightOn ? "#ffd84d" : "#3a3a3a"
                    border.color: root.lightOn ? "#fff3b0" : "#5a5a5a"
                    border.width: units.gu(0.5)
                    opacity: torch.failed ? 0.5 : 1

                    Column {
                        anchors.centerIn: parent
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            // TRANSLATORS: big on/off button, keep it short
                            text: root.lightOn ? i18n.tr("ON") : i18n.tr("OFF")
                            textSize: Label.XLarge
                            font.bold: true
                            color: root.lightOn ? "#1b1b1b" : "#dddddd"
                        }
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: root.blinkRate > 0
                            // TRANSLATORS: %1 = blinks per second, shown under ON/OFF
                            text: i18n.tr("blink %1/s").arg(root.blinkRate)
                            color: root.lightOn ? "#1b1b1b" : "#aaaaaa"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.toggleLight()
                    }
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: units.gu(30)
                    height: units.gu(7)
                    text: root.sosRunning ? i18n.tr("Stop SOS") : i18n.tr("SOS")
                    color: root.sosRunning ? "#c7162b" : "#7a1a24"
                    onClicked: root.sosRunning ? root.stopSos() : root.startSos()
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: units.gu(30)
                    height: units.gu(7)
                    text: i18n.tr("Screen light")
                    onClicked: root.screenLight = true
                }

                // Flashlight blink rate (0 = off = steady light)
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: units.gu(30)
                    spacing: units.gu(0.5)
                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        color: "#dddddd"
                        text: root.blinkRate > 0
                              // TRANSLATORS: %1 = number of blinks per second
                              ? i18n.tr("Flashlight blink: %1 per second").arg(root.blinkRate)
                              : i18n.tr("Flashlight blink: off")
                    }
                    Slider {
                        width: parent.width
                        minimumValue: 0
                        maximumValue: 8      // camera light: uneven from ~10 /s on Xperia XA2
                        value: 0
                        live: true
                        function formatValue(v) {
                            // TRANSLATORS: slider value when blinking is off
                            return Math.round(v) > 0 ? Math.round(v) + "/s" : i18n.tr("off")
                        }
                        onValueChanged: root.blinkRate = Math.round(value)
                    }
                }
            }
        }
    }

    // ---- Screen light: white full screen, tap to close ----
    Rectangle {
        anchors.fill: parent
        visible: root.screenLight
        color: "white"
        z: 100

        Label {
            anchors {
                bottom: parent.bottom
                bottomMargin: units.gu(4)
                horizontalCenter: parent.horizontalCenter
            }
            text: i18n.tr("Tap to close")
            color: "#b0b0b0"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.screenLight = false
        }
    }
}
