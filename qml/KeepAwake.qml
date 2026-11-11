// Copyright (C) 2026 Henrik Christiansen - GNU GPL v3 (see LICENSE)
// Stops the screen from turning off while it is loaded.
// Loaded through a Loader, so the app still works if QtSystemInfo is missing.
import QtQuick 2.12
import QtSystemInfo 5.0

Item {
    ScreenSaver {
        screenSaverEnabled: false
    }
}
