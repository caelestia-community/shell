pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components.live
import qs.services
import qs.config

GridLayout {
    id: root

    property int targetColumns: 2
    property int minColumns: 1
    property int maxColumns: 3
    property real responsiveBreakpoint: 1000
    
    property real customColumnSpacing: Appearance.spacing.large
    property real customRowSpacing: Appearance.spacing.large
    
    columns: {
        if (parent && parent.width < root.responsiveBreakpoint) {
            return root.minColumns
        }
        return Math.min(root.targetColumns, root.maxColumns)
    }
    
    columnSpacing: root.customColumnSpacing
    rowSpacing: root.customRowSpacing
    
    property bool uniformCellHeight: true
    
    Layout.fillWidth: true
    
    Component.onCompleted: {
        if (uniformCellHeight) {
            for (let i = 0; i < children.length; i++) {
                if (children[i].Layout) {
                    children[i].Layout.fillHeight = true
                }
            }
        }
    }
}
