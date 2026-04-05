pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.services
import qs.components
import qs.components.live
import qs.components.containers
import qs.config

Item {
    id: root
    property var config: ({})

    readonly property bool isReady: config && config.targetDisk && config.targetDisk !== ""

    property var diskList: []

    function selectDisk(diskId) {
        if (root.config) {
            root.config.targetDisk = diskId;
        }
    }

    Process {
        id: diskProbe
        command: ["lsblk", "-J", "-d", "-o", "NAME,MODEL,SIZE,TRAN,TYPE"]
        running: true

        stdout: StdioCollector {
            id: outCollector
            onStreamFinished: {
                try {
                    let output = outCollector.text;
                    let json = JSON.parse(output);
                    let devices = json.blockdevices || [];

                    let parsedList = [];
                    for (let i = 0; i < devices.length; i++) {
                        let d = devices[i];

                        if (d.type === "disk" && !d.name.startsWith("loop") && !d.name.startsWith("zram") && !d.name.startsWith("ram")) {
                            let icon = "storage";
                            let tran = d.tran ? d.tran.toLowerCase() : "";
                            let displayType = "HDD / SSD";

                            if (tran === "nvme") {
                                icon = "save";
                                displayType = "NVMe";
                            } else if (tran === "usb") {
                                icon = "usb";
                                displayType = "USB Drive";
                            } else if (tran === "sata") {
                                icon = "dns";
                                displayType = "SATA";
                            }

                            let modelName = d.model ? d.model.trim() : d.name;

                            parsedList.push({
                                id: "/dev/" + d.name,
                                name: modelName,
                                size: d.size,
                                type: displayType,
                                iconName: icon
                            });
                        }
                    }
                    root.diskList = parsedList;
                } catch (e) {
                    console.log("Drive probe failed. Falling back to mock data.");
                    root.diskList = [
                        {
                            id: "/dev/nvme0n1",
                            name: "Samsung SSD 980 PRO",
                            size: "1.0 TB",
                            type: "NVMe",
                            iconName: "save"
                        },
                        {
                            id: "/dev/sda",
                            name: "Crucial MX500",
                            size: "500 GB",
                            type: "SATA SSD",
                            iconName: "dns"
                        },
                        {
                            id: "/dev/sdb",
                            name: "WD Blue",
                            size: "2.0 TB",
                            type: "HDD",
                            iconName: "storage"
                        },
                        {
                            id: "/dev/sdc",
                            name: "SanDisk Ultra",
                            size: "64 GB",
                            type: "USB Drive",
                            iconName: "usb"
                        }
                    ];
                }
            }
        }
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        ColumnLayout {
            spacing: 0
            StyledText {
                text: qsTr("Select Installation Disk")
                font.family: "Nunito"
                font.pointSize: 18
                font.bold: true
                color: Colours.palette.m3onSurface
            }
            StyledText {
                text: qsTr("Choose the drive where Caelestia will be installed. Warning: All data on the selected disk will be erased.")
                font.pointSize: 12
                color: Colours.palette.m3error
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: diskColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: diskColumn
                width: parent.width
                spacing: 16

                StyledText {
                    text: qsTr("Looking for drives!")
                    font.pointSize: 14
                    color: Colours.palette.m3onSurfaceVariant
                    visible: root.diskList.length === 0
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 24
                }

                Repeater {
                    model: root.diskList

                    delegate: MouseArea {
                        id: diskCard
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        hoverEnabled: true

                        property bool isSelected: root.config && root.config.targetDisk === modelData.id

                        onClicked: root.selectDisk(modelData.id)

                        StyledRect {
                            anchors.fill: parent
                            color: diskCard.isSelected ? Colours.palette.m3surfaceVariant : Colours.palette.m3surfaceContainerHigh
                            radius: 12
                            border.width: 1
                            border.color: diskCard.isSelected ? Colours.palette.m3primary : (diskCard.containsMouse ? Colours.palette.m3outline : Colours.palette.m3outlineVariant)

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 16

                                // Disk Icon
                                MaterialIcon {
                                    text: modelData.iconName
                                    font.pointSize: 32
                                    color: diskCard.isSelected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                // Disk Details
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 2

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: modelData.name + " (" + modelData.id + ")"
                                        font.bold: true
                                        font.pointSize: 14
                                        color: diskCard.isSelected ? Colours.palette.m3onSurface : Colours.palette.m3onSurface
                                        horizontalAlignment: Text.AlignLeft
                                    }

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: modelData.size + " • " + modelData.type
                                        font.pointSize: 12
                                        color: Colours.palette.m3onSurfaceVariant
                                        horizontalAlignment: Text.AlignLeft
                                    }
                                }

                                MaterialIcon {
                                    text: diskCard.isSelected ? "radio_button_checked" : "radio_button_unchecked"
                                    font.pointSize: 24
                                    color: diskCard.isSelected ? Colours.palette.m3primary : Colours.palette.m3outline
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
