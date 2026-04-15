import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    required property string keyText

    readonly property bool isIcon: keyText.startsWith("icon:")
    readonly property var iconList: isIcon ? keyText.split(" ") : []

    implicitWidth: isIcon ? iconRow.implicitWidth + Tokens.padding.normal * 2 : keyLabel.implicitWidth + Tokens.padding.normal * 2
    implicitHeight: isIcon ? iconRow.implicitHeight + Tokens.padding.small * 2 : keyLabel.implicitHeight + Tokens.padding.small * 2
    radius: Tokens.rounding.small
    color: Colours.palette.m3surfaceContainerHigh

    StyledText {
        id: keyLabel

        anchors.centerIn: parent
        visible: !root.isIcon
        text: root.keyText
        font.family: "monospace"
        font.pointSize: Tokens.font.size.small
        color: Colours.palette.m3onSurface
    }

    RowLayout {
        id: iconRow

        anchors.centerIn: parent
        visible: root.isIcon
        spacing: Tokens.spacing.small

        Repeater {
            model: root.iconList

            delegate: MaterialIcon {
                required property string modelData

                text: modelData.substring(5)
                font.pointSize: Tokens.font.size.normal
                color: Colours.palette.m3onSurface
            }
        }
    }
}
