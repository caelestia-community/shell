pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.live
import qs.config
import qs.services
import "pages"

StyledRect {
    id: root

    property string currentPage: "welcome"
    property bool navigationLocked: false

    readonly property int currentStepIndex: pages.findIndex(p => p.id === currentPage)

    InstallerConfig {
        id: sharedConfig
    }

    width: 1000
    height: 700
    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
    radius: Appearance.rounding.normal

    focus: true

    function triggerNextStep() {
        if (root.navigationLocked || contentArea.transitioning)
            return;
        if (currentPageLoader.item && !currentPageLoader.item.isReady)
            return;

        if (root.currentStepIndex >= 0 && root.currentStepIndex < root.pages.length - 2) {
            root.navigationLocked = true;
            root.currentPage = root.pages[root.currentStepIndex + 1].id;
            navigationDebounceTimer.restart();
        } else if (root.currentStepIndex === root.pages.length - 2) {
            console.log("--- INSTALLATION TRIGGERED ---");
            root.currentPage = "progress";
        }
    }

    Keys.onLeftPressed: {
        if (root.navigationLocked)
            return;
        if (root.currentStepIndex > 0) {
            root.navigationLocked = true;
            root.currentPage = root.pages[root.currentStepIndex - 1].id;
            navigationDebounceTimer.restart();
        }
    }

    Keys.onRightPressed: root.triggerNextStep()
    Keys.onReturnPressed: root.triggerNextStep()
    Keys.onEnterPressed: root.triggerNextStep()

    Timer {
        id: navigationDebounceTimer
        interval: 400
        onTriggered: root.navigationLocked = false
    }

    readonly property list<var> pages: [
        {
            id: "welcome",
            name: qsTr("Welcome"),
            icon: "waving_hand",
            source: "pages/WelcomeStep.qml"
        },
        {
            id: "timezone",
            name: qsTr("Timezone"),
            icon: "public",
            source: "pages/TimezoneStep.qml"
        },
        {
            id: "user",
            name: qsTr("User Setup"),
            icon: "person_add",
            source: "pages/UserStep.qml"
        },
        {
            id: "software",
            name: qsTr("Software"),
            icon: "grid_view",
            source: "pages/SoftwareStep.qml"
        },
        {
            id: "disk",
            name: qsTr("Select Disk"),
            icon: "storage",
            source: "pages/DiskStep.qml"
        },
        {
            id: "summary",
            name: qsTr("Summary"),
            icon: "fact_check",
            source: "pages/SummaryStep.qml"
        },
        {
            id: "progress",
            name: qsTr("Installing"),
            icon: "download",
            source: "pages/ProgressStep.qml",
            hidden: true
        }
    ]

    readonly property var currentPageData: pages.find(p => p.id === currentPage) ?? pages[0]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StyledRect {
            id: topNav
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 32
                spacing: Appearance.spacing.normal

                StyledText {
                    text: "Caelestia"
                    font.family: "Nunito"
                    font.pointSize: Appearance.font.size.large
                    font.bold: true
                    color: Colours.palette.m3onSurface
                }

                StyledFlickable {
                    id: tabsFlickable
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: tabsRow.width
                    flickableDirection: Flickable.HorizontalFlick
                    clip: true
                    interactive: true

                    Behavior on contentX {
                        Anim {
                            duration: Appearance.anim.durations.normal
                            easing.bezierCurve: Appearance.anim.curves.emphasized
                        }
                    }

                    Item {
                        width: Math.max(tabsFlickable.width, tabsRow.width)
                        height: tabsFlickable.height

                        StyledRect {
                            id: activeIndicator
                            property Item activeTab: {
                                if (typeof tabsRepeater === "undefined")
                                    return null;
                                for (let i = 0; i < tabsRepeater.count; i++) {
                                    const tab = tabsRepeater.itemAt(i);
                                    if (tab && tab.isActive)
                                        return tab;
                                }
                                return null;
                            }
                            visible: activeTab !== null
                            color: Colours.palette.m3primary
                            radius: Appearance.rounding.small
                            x: activeTab ? activeTab.x : 0
                            width: activeTab ? activeTab.width : 0
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on x {
                                Anim {
                                    duration: Appearance.anim.durations.normal
                                    easing.bezierCurve: Appearance.anim.curves.emphasized
                                }
                            }
                            Behavior on width {
                                Anim {
                                    duration: Appearance.anim.durations.normal
                                    easing.bezierCurve: Appearance.anim.curves.emphasized
                                }
                            }
                        }

                        Row {
                            id: tabsRow
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Appearance.spacing.small
                            z: 2

                            Repeater {
                                id: tabsRepeater
                                model: root.pages
                                delegate: Item {
                                    id: tabsItem
                                    required property var modelData
                                    required property int index
                                    property bool isActive: root.currentPage === modelData.id

                                    visible: !modelData.hidden
                                    implicitWidth: visible ? tabContent.implicitWidth + (Appearance.padding.normal * 2) : 0
                                    implicitHeight: visible ? 32 : 0

                                    StateLayer {
                                        anchors.fill: parent
                                        radius: Appearance.rounding.small
                                        onClicked: {
                                            root.currentPage = tabsItem.modelData.id;
                                            const targetX = tabsItem.x - (tabsFlickable.width - tabsItem.width) / 2;
                                            tabsFlickable.contentX = Math.max(0, Math.min(tabsFlickable.contentWidth - tabsFlickable.width, targetX));
                                        }
                                    }

                                    Row {
                                        id: tabContent
                                        anchors.centerIn: parent
                                        spacing: Appearance.spacing.smaller
                                        MaterialIcon {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: tabsItem.modelData.icon
                                            font.pointSize: Appearance.font.size.small
                                            color: tabsItem.isActive ? Colours.palette.m3surface : Colours.palette.m3onSurfaceVariant
                                        }
                                        StyledText {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: tabsItem.modelData.name
                                            font.pointSize: Appearance.font.size.small
                                            color: tabsItem.isActive ? Colours.palette.m3surface : Colours.palette.m3onSurfaceVariant
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                IconButton {
                    icon: "close"
                    type: IconButton.Text
                    radius: Appearance.rounding.small
                    padding: Appearance.padding.small
                    onClicked: QsWindow.window.destroy()
                }
            }
        }

        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            StyledRect {
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 32
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                color: Colours.palette.m3background
                radius: 12
                z: -1
            }

            property string activePage: "welcome"
            property bool transitioning: false
            property int direction: 0

            function triggerTransition(targetId) {
                if (transitioning || targetId === activePage)
                    return;
                const pages = ["welcome", "timezone", "user", "software", "disk", "summary", "progress"];
                const oldIdx = pages.indexOf(activePage);
                const newIdx = pages.indexOf(targetId);
                direction = newIdx > oldIdx ? 1 : -1;
                nextPageLoader.source = root.pages.find(p => p.id === targetId).source;
                nextPageContainer.x = direction > 0 ? contentArea.width : -contentArea.width;
                nextPageContainer.z = 2;
                currentPageContainer.z = 1;
                transitioning = true;
                slideAnimation.start();
            }

            SequentialAnimation {
                id: slideAnimation
                ParallelAnimation {
                    NumberAnimation {
                        target: currentPageContainer
                        property: "x"
                        to: contentArea.direction > 0 ? -100 : 100
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: currentPageContainer
                        property: "opacity"
                        to: 0
                        duration: 300
                    }
                    NumberAnimation {
                        target: nextPageContainer
                        property: "x"
                        to: 0
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: nextPageContainer
                        property: "opacity"
                        to: 1
                        duration: 300
                    }
                }
                ScriptAction {
                    script: {
                        currentPageLoader.source = nextPageLoader.source;
                        currentPageContainer.x = 0;
                        currentPageContainer.opacity = 1;
                        nextPageLoader.source = "";
                        nextPageContainer.opacity = 0;
                        contentArea.activePage = root.currentPage;
                        contentArea.transitioning = false;
                    }
                }
            }

            Item {
                id: currentPageContainer
                anchors.fill: parent
                anchors.margins: 24
                opacity: 1
                Loader {
                    id: currentPageLoader
                    anchors.fill: parent
                    source: "pages/WelcomeStep.qml"
                    onLoaded: if (item && item.hasOwnProperty("config"))
                        item.config = sharedConfig

                    Connections {
                        target: currentPageLoader.item
                        ignoreUnknownSignals: true
                        function onRequestNext() {
                            root.triggerNextStep();
                        }
                    }
                }
            }

            Item {
                id: nextPageContainer
                width: parent.width
                height: parent.height
                x: parent.width
                opacity: 0
                Loader {
                    id: nextPageLoader
                    anchors.fill: parent
                    anchors.margins: 24
                    onLoaded: if (item && item.hasOwnProperty("config"))
                        item.config = sharedConfig
                }
            }

            Connections {
                target: root
                function onCurrentPageChanged() {
                    contentArea.triggerTransition(root.currentPage);
                }
            }
        }

        StyledRect {
            id: bottomNav
            visible: root.currentPage !== "progress"
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 32
                spacing: Appearance.spacing.normal

                StyledRect {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    color: parentContainsMouse ? Colours.palette.m3surfaceVariant : "transparent"
                    border.width: 1
                    border.color: Colours.palette.m3outlineVariant
                    radius: Appearance.rounding.small
                    visible: root.currentStepIndex > 0
                    property bool parentContainsMouse: backMouseArea.containsMouse

                    StyledText {
                        anchors.centerIn: parent
                        text: qsTr("Back")
                        font.bold: true
                        color: Colours.palette.m3onSurface
                    }
                    MouseArea {
                        id: backMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (!contentArea.transitioning) {
                                root.currentPage = root.pages[root.currentStepIndex - 1].id;
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledRect {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    radius: Appearance.rounding.small
                    property bool isEnabled: currentPageLoader.item ? currentPageLoader.item.isReady : false
                    color: isEnabled ? Colours.palette.m3primary : Colours.palette.m3surfaceVariant
                    opacity: isEnabled ? 1.0 : 0.6

                    StyledText {
                        anchors.centerIn: parent
                        text: root.currentStepIndex === root.pages.length - 2 ? qsTr("Install") : qsTr("Next")
                        font.bold: true
                        color: parent.isEnabled ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: parent.isEnabled
                        onClicked: root.triggerNextStep()
                    }
                }
            }
        }
    }
}
