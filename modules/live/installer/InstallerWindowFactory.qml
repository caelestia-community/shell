pragma Singleton

import QtQuick
import Quickshell
import qs.components

Singleton {
    id: root

    property string name: "Installer"
    property string icon: "downloading"
    property string description: "Caelestia OS Installer"
    property bool enabled: true
    property bool dangerous: false

    // This is your access point!
    // You can call InstallerWindowFactory.create() from your launcher.
    function create(parent: Item, props: var): void {
        installerWindowWrapper.createObject(parent ?? dummy, props);
    }

    QtObject {
        id: dummy
    }

    Component {
        id: installerWindowWrapper

        FloatingWindow {
            id: win

            // Set specific dimensions for the installer
            implicitWidth: 800
            implicitHeight: 600
            minimumSize: Qt.size(600, 400)
            color: "transparent"
            title: qsTr("Caelestia Installer")

            // This is the wrapper we discussed earlier
            InstallerWindow {
                id: installerWindow
                anchors.fill: parent

                // Function to handle closing the window after install or cancel
                function close(): void {
                    win.destroy();
                }
            }
        }
    }
}
