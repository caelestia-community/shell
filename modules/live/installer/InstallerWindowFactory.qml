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

    function onClicked(list: var): void {
        create(null, {});
        list?.close();
    }

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

            visible: true
            implicitWidth: 1100
            implicitHeight: 700
            minimumSize: Qt.size(900, 700)
            color: "transparent"
            title: qsTr("Caelestia Installer")

            InstallerWindow {
                id: installerWindow
                anchors.fill: parent

                function close(): void {
                    win.destroy();
                }
            }
        }
    }
}
