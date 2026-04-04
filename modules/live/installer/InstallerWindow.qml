pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.components.controls
import qs.config
import "pages"

StyledRect {
    id: root

    // Navigation State
    property int currentIndex: 0
    property bool canGoNext: false // Controls the 'Next' button enablement

    // Core Data to be passed to the Python Backend
    property var installConfig: {
        "timezone": "",
        "username": "",
        "password": "",
        "targetDrive": ""
    }

    width: 800
    height: 600
    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
    radius: Appearance.rounding.normal
    border.color: Colours.palette.m3outlineVariant
    border.width: 1

    // Step definitions [cite: 6]
    readonly property list<var> steps: [
        { id: "welcome", name: qsTr("Welcome"), component: welcomeStep },
        { id: "timezone", name: qsTr("Timezone"), component: timezoneStep },
        { id: "user", name: qsTr("User Setup"), component: userStep },
        { id: "disk", name: qsTr("Select Disk"), component: diskStep },
        { id: "summary", name: qsTr("Ready?"), component: summaryStep }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header - Following Caelestia Branding
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Appearance.padding.large

                StyledText {
                    text: "Caelestia Installer"
                    font.family: "Nunito"
                    font.pointSize: Appearance.font.size.large
                    font.bold: true [cite: 14]
                    color: Colours.palette.m3onSurface
                }

                Item { Layout.fillWidth: true } // Spacer

                StyledText {
                    text: steps[currentIndex].name
                    color: Colours.palette.m3onSurfaceVariant
                    anchors.rightMargin: Appearance.padding.large
                }
            }
        }

        // Main Content Area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Loader {
                id: stepLoader
                anchors.fill: parent
                anchors.margins: Appearance.padding.large
                sourceComponent: steps[currentIndex].component

                // Transitions between steps
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

        // Footer Navigation
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: Colours.layer(Colours.palette.m3surfaceContainer, 1)

            RowLayout {
                anchors.fill: parent
                anchors.margins: Appearance.padding.large

                Button {
                    text: qsTr("Cancel")
                    onClicked: QsWindow.window.destroy() [cite: 60]
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: qsTr("Back")
                    visible: currentIndex > 0
                    onClicked: currentIndex--
                }

                Button {
                    id: nextButton
                    text: currentIndex === steps.length - 1 ? qsTr("Install") : qsTr("Next")
                    highlighted: true
                    enabled: root.canGoNext
                    onClicked: {
                        if (currentIndex < steps.length - 1) {
                            currentIndex++
                        } else {
                            // Trigger the Python backend installation script
                            console.log("Starting install with: ", JSON.stringify(installConfig))
                        }
                    }
                }
            }
        }
    }

    // Components for each page
    Component { id: welcomeStep; Text { text: "Welcome to Caelestia"; color: "white" } }
    Component { id: timezoneStep; Text { text: "Map goes here"; color: "white" } }
    Component { id: userStep; Text { text: "User fields go here"; color: "white" } }
    Component { id: diskStep; Text { text: "Disk selection goes here"; color: "white" } }
    Component { id: summaryStep; Text { text: "Final Review"; color: "white" } }
}
