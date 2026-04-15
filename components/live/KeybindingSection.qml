pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components.live
import qs.services

SectionContentArea {
    id: root

    property int targetColumns: 2
    property real responsiveBreakpoint: 1000

    property list<var> groups: []

    property real groupColumnSpacing: Tokens.spacing.large
    property real groupRowSpacing: Tokens.spacing.large * 2
    property real bindingSpacing: Tokens.spacing.normal

    // Container styling (inherited from SectionContentArea)
    customPadding: Tokens.padding.large * 2
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
