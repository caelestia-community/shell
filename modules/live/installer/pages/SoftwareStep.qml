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

    readonly property bool isReady: config !== null

    property int _selectionTrigger: 0

    Component.onCompleted: {
        if (root.config && !root.config.software) {
            root.config.software = [];
        }
    }

    readonly property var softwareGroups: [
        {
            category: "Work",
            apps: [
                {
                    appId: "libreoffice",
                    name: "LibreOffice",
                    desc: "Complete, open-source office productivity suite.",
                    iconName: "description"
                },
                {
                    appId: "thunderbird",
                    name: "Thunderbird",
                    desc: "Standalone email, news, and chat client.",
                    iconName: "mail"
                }
            ]
        },
        {
            category: "Development",
            apps: [
                {
                    appId: "codium",
                    name: "VSCodium",
                    desc: "Free, telemetry-free binary release of VS Code.",
                    iconName: "code"
                },
                {
                    appId: "github_desktop",
                    name: "GitHub Desktop",
                    desc: "Simple GitHub collaboration from your desktop.",
                    iconName: "folder_special"
                }
            ]
        },
        {
            category: "Creative",
            apps: [
                {
                    appId: "gimp",
                    name: "GIMP",
                    desc: "GNU Image Manipulation Program for image editing.",
                    iconName: "palette"
                },
                {
                    appId: "resolve",
                    name: "DaVinci Resolve",
                    desc: "Professional video editing and color correction.",
                    iconName: "movie"
                }
            ]
        },
        {
            category: "Gaming",
            apps: [
                {
                    appId: "steam",
                    name: "Steam",
                    desc: "The ultimate destination for gaming.",
                    iconName: "sports_esports"
                },
                {
                    appId: "obs",
                    name: "OBS Studio",
                    desc: "Software for video recording and streaming.",
                    iconName: "videocam"
                }
            ]
        }
    ]

    function toggleSoftware(appId) {
        if (!root.config)
            return;

        let currentList = root.config.software ? [...root.config.software] : [];
        let index = currentList.indexOf(appId);

        if (index === -1) {
            currentList.push(appId);
        } else {
            currentList.splice(index, 1);
        }

        root.config.software = currentList;
        root._selectionTrigger++;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        ColumnLayout {
            spacing: 0
            StyledText {
                text: qsTr("Additional Software")
                font.family: "Nunito"
                font.pointSize: 18
                font.bold: true
                color: Colours.palette.m3onSurface
            }
            StyledText {
                text: qsTr("Select any extra applications you'd like to install alongside the base system.")
                font.pointSize: 12
                color: Colours.palette.m3onSurfaceVariant
            }
        }

        Flickable {
            id: scrollArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            contentWidth: width
            contentHeight: scrollContent.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                id: vbar
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 6
                    implicitHeight: 40
                    radius: width / 2
                    color: vbar.pressed ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
                }
            }

            ColumnLayout {
                id: scrollContent
                width: parent.width - (vbar.visible ? 16 : 0)
                spacing: 16

                Repeater {
                    model: root.softwareGroups

                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        required property int index
                        required property var modelData

                        StyledText {
                            text: modelData.category
                            font.bold: true
                            font.pointSize: 14
                            color: Colours.palette.m3primary
                            Layout.topMargin: index === 0 ? 0 : 4
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 16
                            rowSpacing: 12
                            Repeater {
                                model: modelData.apps

                                delegate: MouseArea {
                                    id: cardRoot
                                    required property var modelData

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 72
                                    hoverEnabled: true

                                    property bool selected: {
                                        let trigger = root._selectionTrigger;
                                        return root.config && root.config.software && root.config.software.indexOf(modelData.appId) !== -1;
                                    }

                                    onClicked: root.toggleSoftware(modelData.appId)

                                    StyledRect {
                                        anchors.fill: parent
                                        color: cardRoot.selected ? Colours.palette.m3surfaceVariant : Colours.palette.m3surfaceContainerHigh
                                        radius: 12
                                        border.width: 1
                                        border.color: cardRoot.selected ? Colours.palette.m3primary : (cardRoot.containsMouse ? Colours.palette.m3outline : Colours.palette.m3outlineVariant)

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 12

                                            MaterialIcon {
                                                text: modelData.iconName
                                                font.pointSize: 24
                                                color: cardRoot.selected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                spacing: 0

                                                StyledText {
                                                    text: modelData.name
                                                    font.bold: true
                                                    font.pointSize: 13
                                                    color: cardRoot.selected ? Colours.palette.m3onSurface : Colours.palette.m3onSurface
                                                }
                                                StyledText {
                                                    Layout.fillWidth: true
                                                    text: modelData.desc
                                                    font.pointSize: 11
                                                    color: Colours.palette.m3onSurfaceVariant
                                                    wrapMode: Text.WordWrap
                                                    maximumLineCount: 2
                                                    elide: Text.ElideRight
                                                    lineHeight: 1.1
                                                }
                                            }

                                            MaterialIcon {
                                                text: cardRoot.selected ? "check_circle" : "radio_button_unchecked"
                                                font.pointSize: 22
                                                color: cardRoot.selected ? Colours.palette.m3primary : Colours.palette.m3outline
                                                Layout.alignment: Qt.AlignVCenter
                                                Behavior on color {
                                                    ColorAnimation {
                                                        duration: 150
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
