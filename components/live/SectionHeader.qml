import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property int fontSize: Tokens.font.size.extraLarge

    Layout.fillWidth: true
    implicitHeight: sectionHeader.implicitHeight

    ColumnLayout {
        id: sectionHeader

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Tokens.spacing.small

        StyledText {
            text: root.title
            font.pointSize: root.fontSize
            font.bold: true
            color: Colours.palette.m3onBackground
        }

        StyledText {
            Layout.fillWidth: true
            text: root.subtitle
            font.pointSize: Tokens.font.size.normal
            color: Colours.palette.m3onSurfaceVariant
            wrapMode: Text.WordWrap
        }
    }
}
