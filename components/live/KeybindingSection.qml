pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components.live
import qs.services
import qs.config

SectionContentArea {
    id: root

    property int targetColumns: 2
    property real responsiveBreakpoint: 1000

    property list<var> groups: []
    
    property real groupColumnSpacing: Appearance.spacing.large
    property real groupRowSpacing: Appearance.spacing.large * 2
    property real bindingSpacing: Appearance.spacing.normal
    
    // Container styling (inherited from SectionContentArea)
    customPadding: Appearance.padding.large * 2
    enablePadding: true
    enableBackground: true

    content: Component {
        GridLayout {
            columns: parent.width > root.responsiveBreakpoint ? root.targetColumns : 1
            columnSpacing: root.groupColumnSpacing
            rowSpacing: root.groupRowSpacing

            Repeater {
                model: root.groups

                delegate: SectionContentArea {
                    id: keybindingContentArea

                    required property var modelData

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    title: modelData.title
                    
                    enablePadding: false
                    enableBackground: false

                    content: Component {
                        ColumnLayout {
                            spacing: root.bindingSpacing

                            Repeater {
                                model: keybindingContentArea.modelData.bindings

                                delegate: KeybindingRow {
                                    required property var modelData

                                    label: modelData.label
                                    keys: modelData.keys
                                    desc: modelData.desc || ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
