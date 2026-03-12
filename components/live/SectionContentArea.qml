pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

StyledRect {
    id: root

    property string title
    property string subtitle
    required property var content
    
    property bool enablePadding: true
    property real customPadding: Appearance.padding.large * 2
    readonly property real effectivePadding: enablePadding ? customPadding : 0
    
    property bool enableBackground: true
    property color customColor: Colours.palette.m3surfaceContainer
    
    property real titleFontSize: Appearance.font.size.larger
    property real subtitleFontSize: Appearance.font.size.normal
    
    property real titleSubtitleSpacing: Appearance.spacing.small
    property real contentTopMargin: Appearance.padding.large

    Layout.fillWidth: true
    implicitHeight: contentColumn.implicitHeight + root.effectivePadding * 2
    color: enableBackground ? customColor : "transparent"
    radius: enableBackground ? Appearance.rounding.normal : 0

    ColumnLayout {
        id: contentColumn

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.effectivePadding
        spacing: root.titleSubtitleSpacing

        StyledText {
            visible: root.title
            font.pointSize: root.titleFontSize
            font.bold: true
            color: Colours.palette.m3primary
            text: root.title
        }

        StyledText {
            Layout.fillWidth: true
            visible: root.subtitle
            font.pointSize: root.subtitleFontSize
            color: Colours.palette.m3onSurface
            wrapMode: Text.WordWrap
            text: root.subtitle
        }

        Loader {
            Layout.fillWidth: true
            Layout.topMargin: root.title || root.subtitle ? root.contentTopMargin : 0

            sourceComponent: root.content
        }
    }
}