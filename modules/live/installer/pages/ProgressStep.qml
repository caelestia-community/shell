pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.components
import qs.components.live
import qs.components.containers
import qs.config
import qs.services

Item {
    id: root
    property var config: ({})

    property real currentProgress: 0.0
    property string currentStatus: "Initializing..."
    property string logText: ""
    property bool isFinished: currentProgress >= 1.0

    // --- MOCK BACKEND DATA ---
    property int _mockIndex: 0
    property var mockLog: [
        {
            p: 0.05,
            t: "Preparing installation environment..."
        },
        {
            p: 0.15,
            t: "Wiping and formatting target disk (" + (config.targetDisk || "null") + ")..."
        },
        {
            p: 0.30,
            t: "Mounting file systems..."
        },
        {
            p: 0.45,
            t: "Fetching base system packages..."
        },
        {
            p: 0.60,
            t: "Unpacking Caelestia base system..."
        },
        {
            p: 0.70,
            t: "Installing additional software packages..."
        },
        {
            p: 0.85,
            t: "Configuring user account (" + (config.username || "null") + ")..."
        },
        {
            p: 0.95,
            t: "Installing bootloader..."
        },
        {
            p: 1.00,
            t: "Installation Complete!"
        }
    ]

    Timer {
        id: dryRunTimer
        interval: 1500
        running: true
        repeat: true
        onTriggered: {
            if (_mockIndex < mockLog.length) {
                let step = mockLog[_mockIndex];

                root.currentProgress = step.p;
                root.currentStatus = step.t;

                root.logText += "[ " + new Date().toLocaleTimeString() + " ] " + step.t + "\n";

                _mockIndex++;
            } else {
                running = false;
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 48
        spacing: 24

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            LogoIntro {
                id: installLogo
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 80 * (implicitWidth / implicitHeight)
                Layout.preferredHeight: 80
                skipIntroAnimation: false

                scale: root.isFinished ? 1.0 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                SequentialAnimation on scale {
                    running: !root.isFinished
                    loops: Animation.Infinite
                    NumberAnimation {
                        to: 1.1
                        duration: 1200
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        to: 0.95
                        duration: 1200
                        easing.type: Easing.InOutSine
                    }
                }
            }

            StyledText {
                text: root.isFinished ? qsTr("Caelestia is Ready") : qsTr("Installing Caelestia...")
                font.family: "Nunito"
                font.pointSize: 24
                font.bold: true
                color: Colours.palette.m3onSurface
                Layout.alignment: Qt.AlignHCenter
            }

            StyledText {
                text: root.currentStatus
                font.pointSize: 14
                color: Colours.palette.m3onSurfaceVariant
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // --- Progress Bar ---
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            Layout.topMargin: 24
            Layout.bottomMargin: 24

            Rectangle {
                anchors.fill: parent
                color: Colours.palette.m3surfaceContainerHigh
                radius: height / 2
            }

            Rectangle {
                height: parent.height
                width: parent.width * root.currentProgress
                color: Colours.palette.m3primary
                radius: height / 2

                Behavior on width {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colours.palette.m3surfaceContainerLowest
            border.width: 1
            border.color: Colours.palette.m3outlineVariant
            radius: 8
            clip: true

            Flickable {
                id: logFlickable
                anchors.fill: parent
                anchors.margins: 16
                contentWidth: width
                contentHeight: logTextElement.height
                boundsBehavior: Flickable.StopAtBounds

                onContentHeightChanged: {
                    contentY = Math.max(0, contentHeight - height);
                }

                Text {
                    id: logTextElement
                    width: parent.width
                    text: root.logText
                    color: Colours.palette.m3onSurfaceVariant
                    font.family: "monospace"
                    font.pointSize: 10
                    wrapMode: Text.WrapAnywhere
                }
            }
        }

        StyledRect {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 160
            Layout.preferredHeight: 45
            radius: 8
            color: Colours.palette.m3primary
            visible: root.isFinished

            StyledText {
                anchors.centerIn: parent
                text: qsTr("Restart Now")
                font.bold: true
                color: Colours.palette.m3onPrimary
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    console.log("Triggering System Reboot...");
                }
            }
        }
    }
}
