pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.components
import qs.components.live
import qs.components.containers
import qs.config

Item {
    id: root
    property var config: ({})

    readonly property bool isReady: true

    property bool showPassword: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        ColumnLayout {
            spacing: 0
            StyledText {
                text: qsTr("Ready to Install")
                font.family: "Nunito"
                font.pointSize: 18
                font.bold: true
                color: Colours.palette.m3onSurface
            }
            StyledText {
                text: qsTr("Please review your final configuration before writing to disk.")
                font.pointSize: 12
                color: Colours.palette.m3onSurfaceVariant
            }
        }

        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colours.palette.m3surfaceContainerHigh
            radius: 12
            border.width: 1
            border.color: Colours.palette.m3outlineVariant
            clip: true

            Flickable {
                anchors.fill: parent
                anchors.margins: 16
                contentWidth: width
                contentHeight: summaryGrid.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                GridLayout {
                    id: summaryGrid
                    width: parent.width
                    columns: 2
                    columnSpacing: 32
                    rowSpacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 12
                        MaterialIcon {
                            text: "badge"
                            font.pointSize: 24
                            color: Colours.palette.m3primary
                            Layout.alignment: Qt.AlignVCenter
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                text: qsTr("Full Name")
                                font.pointSize: 11
                                color: Colours.palette.m3onSurfaceVariant
                            }
                            StyledText {
                                text: root.config && root.config.fullname ? root.config.fullname : qsTr("Not provided")
                                font.pointSize: 14
                                font.bold: true
                                color: Colours.palette.m3onSurface
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 12
                        MaterialIcon {
                            text: "computer"
                            font.pointSize: 24
                            color: Colours.palette.m3primary
                            Layout.alignment: Qt.AlignVCenter
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                text: qsTr("Device Name (Hostname)")
                                font.pointSize: 11
                                color: Colours.palette.m3onSurfaceVariant
                            }
                            StyledText {
                                text: root.config && root.config.hostname ? root.config.hostname : qsTr("Not provided")
                                font.pointSize: 14
                                font.bold: true
                                color: Colours.palette.m3onSurface
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 12
                        MaterialIcon {
                            text: "person"
                            font.pointSize: 24
                            color: Colours.palette.m3primary
                            Layout.alignment: Qt.AlignVCenter
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                text: qsTr("Username")
                                font.pointSize: 11
                                color: Colours.palette.m3onSurfaceVariant
                            }
                            StyledText {
                                text: root.config && root.config.username ? root.config.username : qsTr("Not provided")
                                font.pointSize: 14
                                font.bold: true
                                color: Colours.palette.m3onSurface
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 12
                        MaterialIcon {
                            text: "schedule"
                            font.pointSize: 24
                            color: Colours.palette.m3primary
                            Layout.alignment: Qt.AlignVCenter
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                text: qsTr("Timezone")
                                font.pointSize: 11
                                color: Colours.palette.m3onSurfaceVariant
                            }
                            StyledText {
                                text: root.config && root.config.timezone ? root.config.timezone : qsTr("Not selected")
                                font.pointSize: 14
                                font.bold: true
                                color: Colours.palette.m3onSurface
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 12
                        MaterialIcon {
                            text: "vpn_key"
                            font.pointSize: 24
                            color: Colours.palette.m3primary
                            Layout.alignment: Qt.AlignVCenter
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                text: qsTr("Password")
                                font.pointSize: 11
                                color: Colours.palette.m3onSurfaceVariant
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                StyledText {
                                    Layout.fillWidth: true
                                    text: {
                                        if (!root.config || !root.config.password)
                                            return qsTr("Not provided");
                                        return root.showPassword ? root.config.password : "•".repeat(root.config.password.length);
                                    }
                                    font.pointSize: 14
                                    font.bold: true
                                    color: Colours.palette.m3onSurface
                                    wrapMode: Text.WrapAnywhere
                                }
                                MaterialIcon {
                                    text: root.showPassword ? "visibility_off" : "visibility"
                                    font.pointSize: 18
                                    color: Colours.palette.m3onSurfaceVariant
                                    Layout.alignment: Qt.AlignVCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -8
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.showPassword = !root.showPassword
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 12
                        MaterialIcon {
                            text: "storage"
                            font.pointSize: 24
                            color: Colours.palette.m3primary
                            Layout.alignment: Qt.AlignVCenter
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                text: qsTr("Target Disk")
                                font.pointSize: 11
                                color: Colours.palette.m3onSurfaceVariant
                            }
                            StyledText {
                                text: root.config && root.config.targetDisk ? root.config.targetDisk : qsTr("Not selected")
                                font.pointSize: 14
                                font.bold: true
                                color: Colours.palette.m3onSurface
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 12
                        MaterialIcon {
                            text: "cake"
                            font.pointSize: 24
                            color: Colours.palette.m3primary
                            Layout.alignment: Qt.AlignVCenter
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                text: qsTr("Birthday")
                                font.pointSize: 11
                                color: Colours.palette.m3onSurfaceVariant
                            }
                            StyledText {
                                text: root.config && root.config.birthday ? root.config.birthday : qsTr("Opted out")
                                font.pointSize: 14
                                font.bold: true
                                color: Colours.palette.m3onSurface
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 12
                        MaterialIcon {
                            text: "apps"
                            font.pointSize: 24
                            color: Colours.palette.m3primary
                            Layout.alignment: Qt.AlignVCenter
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                text: qsTr("Additional Software")
                                font.pointSize: 11
                                color: Colours.palette.m3onSurfaceVariant
                            }
                            StyledText {
                                text: root.config && root.config.software && root.config.software.length > 0 ? (root.config.software.length + qsTr(" Packages Selected")) : qsTr("Base System Only")
                                font.pointSize: 14
                                font.bold: true
                                color: Colours.palette.m3onSurface
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: warningRow.implicitHeight + 24
            color: Colours.palette.m3surfaceContainerHighest
            radius: 12
            border.width: 1
            border.color: Colours.palette.m3error

            RowLayout {
                id: warningRow
                anchors.fill: parent
                anchors.margins: 12
                spacing: 16

                MaterialIcon {
                    text: "warning"
                    font.pointSize: 24
                    color: Colours.palette.m3error
                    Layout.alignment: Qt.AlignVCenter
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Warning: Proceeding will permanently erase all data on the disk (") + (root.config && root.config.targetDisk ? root.config.targetDisk : qsTr("No disk selected")) + qsTr("). This action cannot be undone.")
                    font.pointSize: 12
                    font.bold: true
                    color: Colours.palette.m3error
                    wrapMode: Text.WordWrap
                    Layout.alignment: Qt.AlignVCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
