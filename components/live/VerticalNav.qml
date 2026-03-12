pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.components
import qs.components.containers
import qs.config
import qs.services

Item {
    id: root

    required property var sections
    required property string activeSection
    property bool disableAnimations: false
    property real contentOpacity: 1

    signal sectionChanged(string sectionId)

    implicitWidth: 200
    implicitHeight: tabsColumn.height + Appearance.padding.normal * 2

    focus: true
    Keys.onUpPressed: {
        const currentIndex = root.sections.findIndex(s => s.id === root.activeSection)
        if (currentIndex > 0) {
            root.sectionChanged(root.sections[currentIndex - 1].id)
        }
    }
    Keys.onDownPressed: {
        const currentIndex = root.sections.findIndex(s => s.id === root.activeSection)
        if (currentIndex >= 0 && currentIndex < root.sections.length - 1) {
            root.sectionChanged(root.sections[currentIndex + 1].id)
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: -1
            fillColor: Colours.layer(Colours.palette.m3surfaceContainer, 2)

            startX: 0
            startY: 0

            // Top-left inverted corner
            PathArc {
                relativeX: Appearance.rounding.normal
                relativeY: Appearance.rounding.normal
                radiusX: Appearance.rounding.normal
                radiusY: Appearance.rounding.normal
                direction: PathArc.Counterclockwise
            }

            // Top edge
            PathLine {
                relativeX: root.width - Appearance.rounding.normal * 2
                relativeY: 0
            }

            // Top-right corner
            PathArc {
                relativeX: Appearance.rounding.normal
                relativeY: Appearance.rounding.normal
                radiusX: Appearance.rounding.normal
                radiusY: Appearance.rounding.normal
            }

            // Right edge
            PathLine {
                relativeX: 0
                relativeY: root.height - Appearance.rounding.normal * 2
            }

            // Bottom-right corner
            PathArc {
                relativeX: -Appearance.rounding.normal
                relativeY: Appearance.rounding.normal
                radiusX: Appearance.rounding.normal
                radiusY: Appearance.rounding.normal
            }

            // Bottom edge
            PathLine {
                relativeX: -(root.width - Appearance.rounding.normal * 2)
                relativeY: 0
            }

            // Bottom-left inverted corner
            PathArc {
                relativeX: -Appearance.rounding.normal
                relativeY: Appearance.rounding.normal
                radiusX: Appearance.rounding.normal
                radiusY: Appearance.rounding.normal
                direction: PathArc.Counterclockwise
            }

            // Left edge
            PathLine {
                relativeX: 0
                relativeY: -(root.height - Appearance.rounding.normal * 2)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.normal
        spacing: 0
        opacity: root.contentOpacity
        clip: true

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Appearance.rounding.normal * 1.25
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StyledRect {
                id: activeIndicator

                property Item activeTab: {
                    for (let i = 0; i < tabsRepeater.count; i++) {
                        const tab = tabsRepeater.itemAt(i);
                        if (tab && tab.isActive) {
                            return tab;
                        }
                    }
                    return null;
                }

                visible: activeTab !== null
                color: Colours.palette.m3primary
                radius: Appearance.rounding.small

                x: activeTab ? activeTab.x : 0
                y: activeTab ? activeTab.y : 0
                width: activeTab ? activeTab.width : 0
                height: activeTab ? activeTab.height : 0

                Behavior on y {
                    enabled: !root.disableAnimations
                    Anim {
                        duration: Appearance.anim.durations.normal
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                }

                Behavior on height {
                    enabled: !root.disableAnimations && root.contentOpacity > 0.5
                    Anim {
                        duration: Appearance.anim.durations.normal
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                }
            }

            Column {
                id: tabsColumn
                width: parent.width
                spacing: Appearance.spacing.small
                bottomPadding: Appearance.rounding.normal * 1.25

                Repeater {
                    id: tabsRepeater
                    model: root.sections

                    delegate: Item {
                        required property var modelData
                        required property int index

                        property bool isActive: root.activeSection === modelData.id

                        width: tabsColumn.width
                        implicitHeight: tabContent.height + Appearance.padding.small * 3

                        StateLayer {
                            anchors.fill: parent
                            radius: Appearance.rounding.small
                            function onClicked(): void {
                                root.sectionChanged(modelData.id);
                            }
                        }

                        RowLayout {
                            id: tabContent
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Appearance.padding.normal
                            anchors.rightMargin: Appearance.padding.normal
                            spacing: Appearance.spacing.small

                            MaterialIcon {
                                text: modelData.icon
                                font.pointSize: Appearance.font.size.normal
                                color: parent.parent.isActive ? Colours.palette.m3surface : Colours.palette.m3onSurfaceVariant
                                
                                Behavior on color {
                                    enabled: !root.disableAnimations
                                    ColorAnimation {
                                        duration: Appearance.anim.durations.normal
                                    }
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.name
                                font.pointSize: Appearance.font.size.normal
                                color: parent.parent.isActive ? Colours.palette.m3surface : Colours.palette.m3onSurfaceVariant
                                elide: Text.ElideRight
                                
                                Behavior on color {
                                    enabled: !root.disableAnimations
                                    ColorAnimation {
                                        duration: Appearance.anim.durations.normal
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
