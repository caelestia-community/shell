pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components.live
import qs.services
import qs.config

ColumnLayout {
    id: root

    required property string sectionId
    required property string sectionName
    required property string sectionIcon
    
    property alias sectionHeader: header
    default property alias contentItems: contentArea.data
    
    property real customMargins: Appearance.padding.larger           // Outer margins (12px)
    property real customSpacing: Appearance.spacing.larger           // Spacing between header and content (15px)
    property real sectionBottomSpacing: Appearance.padding.larger * 4  // Bottom spacing (48px)

    Layout.fillWidth: true
    Layout.margins: root.customMargins
    spacing: root.customSpacing

    SectionHeader {
        id: header
    }

    ColumnLayout {
        id: contentArea
        
        Layout.fillWidth: true
        spacing: 0
    }

    Item {
        Layout.preferredHeight: root.sectionBottomSpacing
    }
}
