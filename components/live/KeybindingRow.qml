pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    required property string label
    required property var keys
    property string desc

    Layout.fillWidth: true
    implicitHeight: desc ? row.implicitHeight + Tokens.padding.large * 2 : row.implicitHeight + Tokens.padding.large * 2 + Tokens.font.size.small
    radius: Tokens.rounding.normal
    color: Colours.palette.m3surfaceContainerLow

    Behavior on implicitHeight {
        Anim {}
    }

    RowLayout {
        id: row

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.normal

        RowLayout {
            spacing: Tokens.spacing.small

            Repeater {
                model: root.keys

                delegate: RowLayout {
                    id: keysItem

                    required property var modelData
                    required property int index

                    spacing: Tokens.spacing.small

                    KeyChip {
                        keyText: keysItem.modelData
                    }

                    StyledText {
                        visible: keysItem.index < root.keys.length - 1
                        text: "+"
                        font.pointSize: Tokens.font.size.small
                        color: Colours.palette.m3onSurfaceVariant
                        opacity: 0.5
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 2

            StyledText {
                Layout.alignment: Qt.AlignRight
                text: root.label
                font.pointSize: Tokens.font.size.normal
                color: Colours.palette.m3onSurface
            }

            StyledText {
                Layout.alignment: Qt.AlignRight
                text: root.desc
                visible: root.desc
                font.pointSize: Tokens.font.size.small
                color: Colours.palette.m3onSurfaceVariant
                opacity: 0.7
            }
        }
    }
}
