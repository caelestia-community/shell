pragma ComponentBehavior: Bound

import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property var items

    Repeater {
        id: itemList

        model: root.items

        delegate: ColumnLayout {
            id: listItem

            required property var modelData
            required property int index

            Layout.fillWidth: true

            spacing: Tokens.spacing.small

            RowLayout {
                spacing: Tokens.spacing.normal

                ColumnLayout {
                    StyledText {
                        font.bold: true
                        font.pointSize: Tokens.font.size.larger
                        color: Colours.palette.m3primary
                        text: listItem.modelData.title
                    }

                    StyledText {
                        Layout.fillWidth: true

                        font.pointSize: Tokens.font.size.small
                        color: Colours.palette.m3onSurface
                        wrapMode: Text.WordWrap
                        opacity: 0.8
                        text: listItem.modelData.desc
                    }
                }

                TextButton {
                    visible: listItem.modelData.tourId ? true : false
                    text: qsTr("Show Me")
                    radius: Tokens.rounding.small
                    onClicked: Tour.startTour(listItem.modelData.tourId)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: Tokens.padding.small
                Layout.bottomMargin: Tokens.padding.small
                color: Colours.palette.m3outlineVariant
                opacity: 0.3
                visible: listItem.index < itemList.count - 1
            }
        }
    }
}
