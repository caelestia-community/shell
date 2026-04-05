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
    readonly property bool isReady: config && config.timezone && config.timezone !== ""

    readonly property var tzDatabase: [
        {
            id: "America/Anchorage",
            name: "Anchorage",
            lat: 61.21,
            lon: -149.90
        },
        {
            id: "America/Vancouver",
            name: "Vancouver",
            lat: 49.28,
            lon: -123.12
        },
        {
            id: "America/Los_Angeles",
            name: "Los Angeles",
            lat: 34.05,
            lon: -118.24
        },
        {
            id: "America/Denver",
            name: "Denver",
            lat: 39.73,
            lon: -104.99
        },
        {
            id: "America/Chicago",
            name: "Chicago",
            lat: 41.87,
            lon: -87.62
        },
        {
            id: "America/New_York",
            name: "New York",
            lat: 40.71,
            lon: -74.00
        },
        {
            id: "America/Halifax",
            name: "Halifax",
            lat: 44.64,
            lon: -63.57
        },
        {
            id: "America/Mexico_City",
            name: "Mexico City",
            lat: 19.43,
            lon: -99.13
        },
        {
            id: "America/Bogota",
            name: "Bogotá",
            lat: 4.71,
            lon: -74.07
        },
        {
            id: "America/Lima",
            name: "Lima",
            lat: -12.04,
            lon: -77.02
        },
        {
            id: "America/Santiago",
            name: "Santiago",
            lat: -33.44,
            lon: -70.66
        },
        {
            id: "America/Buenos_Aires",
            name: "Buenos Aires",
            lat: -34.60,
            lon: -58.38
        },
        {
            id: "America/Sao_Paulo",
            name: "São Paulo",
            lat: -23.55,
            lon: -46.63
        },
        {
            id: "Europe/London",
            name: "London",
            lat: 51.50,
            lon: -0.12
        },
        {
            id: "Europe/Paris",
            name: "Paris",
            lat: 48.85,
            lon: 2.35
        },
        {
            id: "Europe/Berlin",
            name: "Berlin",
            lat: 52.52,
            lon: 13.40
        },
        {
            id: "Europe/Rome",
            name: "Rome",
            lat: 41.90,
            lon: 12.49
        },
        {
            id: "Europe/Athens",
            name: "Athens",
            lat: 37.98,
            lon: 23.72
        },
        {
            id: "Europe/Moscow",
            name: "Moscow",
            lat: 55.75,
            lon: 37.61
        },
        {
            id: "Africa/Cairo",
            name: "Cairo",
            lat: 30.04,
            lon: 31.23
        },
        {
            id: "Africa/Lagos",
            name: "Lagos",
            lat: 6.52,
            lon: 3.37
        },
        {
            id: "Africa/Nairobi",
            name: "Nairobi",
            lat: -1.29,
            lon: 36.82
        },
        {
            id: "Africa/Johannesburg",
            name: "Johannesburg",
            lat: -26.20,
            lon: 28.04
        },
        {
            id: "Asia/Riyadh",
            name: "Riyadh",
            lat: 24.71,
            lon: 46.67
        },
        {
            id: "Asia/Dubai",
            name: "Dubai",
            lat: 25.20,
            lon: 55.27
        },
        {
            id: "Asia/Karachi",
            name: "Karachi",
            lat: 24.86,
            lon: 67.00
        },
        {
            id: "Asia/Kolkata",
            name: "Kolkata",
            lat: 22.57,
            lon: 88.36
        },
        {
            id: "Asia/Bangkok",
            name: "Bangkok",
            lat: 13.75,
            lon: 100.50
        },
        {
            id: "Asia/Singapore",
            name: "Singapore",
            lat: 1.35,
            lon: 103.81
        },
        {
            id: "Asia/Shanghai",
            name: "Shanghai",
            lat: 31.23,
            lon: 121.47
        },
        {
            id: "Asia/Seoul",
            name: "Seoul",
            lat: 37.56,
            lon: 126.97
        },
        {
            id: "Asia/Tokyo",
            name: "Tokyo",
            lat: 35.67,
            lon: 139.65
        },
        {
            id: "Australia/Perth",
            name: "Perth",
            lat: -31.95,
            lon: 115.86
        },
        {
            id: "Australia/Sydney",
            name: "Sydney",
            lat: -33.86,
            lon: 151.20
        },
        {
            id: "Pacific/Auckland",
            name: "Auckland",
            lat: -36.85,
            lon: 174.76
        },
        {
            id: "Pacific/Honolulu",
            name: "Honolulu",
            lat: 21.30,
            lon: -157.85
        }
    ]

    property var tzOptions: tzDatabase.map(tz => tz.name + " (" + tz.id + ")")
    property var selectedCity: null

    Component.onCompleted: {
        if (root.config && root.config.timezone) {
            for (let i = 0; i < tzDatabase.length; i++) {
                if (tzDatabase[i].id === root.config.timezone) {
                    selectedCity = tzDatabase[i];
                    timeZoneBox.currentIndex = i;
                    break;
                }
            }
        } else {
            timeZoneBox.currentIndex = -1;
        }
    }

    function selectTimezoneByCoords(mouseX, mouseY) {
        let pWidth = worldMap.status === Image.Ready ? worldMap.paintedWidth : worldMap.width;
        let pHeight = worldMap.status === Image.Ready ? worldMap.paintedHeight : worldMap.height;
        let xOffset = (worldMap.width - pWidth) / 2;
        let yOffset = (worldMap.height - pHeight) / 2;
        let realX = mouseX - xOffset;
        let realY = mouseY - yOffset;

        if (realX < 0 || realX > pWidth || realY < 0 || realY > pHeight)
            return;

        let lon = (realX / pWidth) * 360 - 180;
        let lat = 90 - (realY / pHeight) * 180;

        let nearest = null;
        let minDist = Infinity;
        for (let i = 0; i < tzDatabase.length; i++) {
            let city = tzDatabase[i];
            let dx = city.lon - lon;
            let dy = city.lat - lat;
            let dist = dx * dx + dy * dy;
            if (dist < minDist) {
                minDist = dist;
                nearest = city;
            }
        }

        if (nearest) {
            selectedCity = nearest;
            if (root.config)
                root.config.timezone = nearest.id;

            let newIdx = tzDatabase.indexOf(nearest);
            if (newIdx !== -1 && !timeZoneBox._updating) {
                timeZoneBox.currentIndex = newIdx;
            }
        }
    }

    function getPinX(lon, pWidth) {
        return ((lon + 180) / 360) * pWidth;
    }
    function getPinY(lat, pHeight) {
        return ((90 - lat) / 180) * pHeight;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            StyledText {
                text: qsTr("Where are you?")
                font.family: "Nunito"
                font.pointSize: 18
                font.bold: true
                color: Colours.palette.m3onSurface
            }
            StyledText {
                text: qsTr("Click your location on the map or select from the menu to set the system clock.")
                font.pointSize: 12
                color: Colours.palette.m3onSurfaceVariant
            }
        }

        Item {
            Layout.fillHeight: true
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 608
            spacing: 24

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 320

                Image {
                    id: worldMap
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: "../../assets/world_map.png"
                    smooth: true
                    mipmap: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mouse => selectTimezoneByCoords(mouse.x, mouse.y)
                    }

                    MaterialIcon {
                        visible: selectedCity !== null
                        text: "location_on"
                        color: Colours.palette.m3primary
                        font.pointSize: 24

                        property real pWidth: worldMap.status === Image.Ready ? worldMap.paintedWidth : worldMap.width
                        property real pHeight: worldMap.status === Image.Ready ? worldMap.paintedHeight : worldMap.height

                        x: selectedCity ? ((worldMap.width - pWidth) / 2) + root.getPinX(selectedCity.lon, pWidth) - width / 2 : 0
                        y: selectedCity ? ((worldMap.height - pHeight) / 2) + root.getPinY(selectedCity.lat, pHeight) - height : 0

                        Behavior on x {
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on y {
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }

            ComboBox {
                id: timeZoneBox
                Layout.fillWidth: true
                Layout.preferredHeight: 56

                model: root.tzOptions

                property bool _updating: false

                onActivated: index => {
                    if (index >= 0 && index < tzDatabase.length) {
                        _updating = true;
                        selectedCity = tzDatabase[index];
                        if (root.config)
                            root.config.timezone = selectedCity.id;
                        _updating = false;
                    }
                }

                background: StyledRect {
                    color: Colours.palette.m3surfaceContainerHigh
                    radius: 8
                    border.width: 1
                    border.color: timeZoneBox.pressed || timeZoneBox.popup.visible ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
                }

                contentItem: RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    MaterialIcon {
                        text: "schedule"
                        font.pointSize: 20
                        color: selectedCity ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: timeZoneBox.currentIndex !== -1 ? timeZoneBox.currentText : qsTr("Select a Timezone...")
                        font.pointSize: 14
                        color: selectedCity ? Colours.palette.m3onSurface : Colours.palette.m3onSurfaceVariant
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                indicator: MaterialIcon {
                    x: timeZoneBox.width - width - 16
                    y: (timeZoneBox.height - height) / 2
                    text: timeZoneBox.popup.visible ? "expand_less" : "expand_more"
                    font.pointSize: 24
                    color: Colours.palette.m3onSurfaceVariant
                }

                popup: Popup {
                    y: timeZoneBox.height + 4
                    width: timeZoneBox.width
                    height: Math.min(200, contentItem.implicitHeight + 8)
                    padding: 4

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: timeZoneBox.delegateModel
                        currentIndex: timeZoneBox.highlightedIndex
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }
                    }

                    background: StyledRect {
                        color: Colours.palette.m3surfaceContainerHigh
                        border.width: 1
                        border.color: Colours.palette.m3outlineVariant
                        radius: 8
                    }
                }

                delegate: ItemDelegate {
                    id: delegateItem

                    required property string modelData
                    required property int index

                    width: timeZoneBox.popup.width - 8
                    height: 48
                    highlighted: timeZoneBox.highlightedIndex === delegateItem.index

                    background: Rectangle {
                        radius: 6
                        color: delegateItem.highlighted ? Colours.palette.m3surfaceVariant : "transparent"
                    }

                    contentItem: StyledText {
                        text: delegateItem.modelData
                        color: delegateItem.highlighted ? Colours.palette.m3primary : Colours.palette.m3onSurface
                        font.pointSize: 12
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
