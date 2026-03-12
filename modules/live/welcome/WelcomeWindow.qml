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
    property bool welcomeAnimationHasRun: false
    property bool navigationLocked: false
    property string currentSection: ""
    property var currentPageSubsections: []
    property var displayedSubsections: []
    property var targetPageSubsections: []

    function close(): void {
    }

    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
    border.width: 1
    border.color: Colours.palette.m3outlineVariant
    radius: Appearance.rounding.normal

    focus: true
    Keys.onLeftPressed: {
        if (root.navigationLocked) return
        const currentIndex = root.pages.findIndex(p => p.id === root.currentPage)
        if (currentIndex > 0) {
            root.navigationLocked = true
            root.currentPage = root.pages[currentIndex - 1].id
            navigationDebounceTimer.restart()
        }
    }
    Keys.onRightPressed: {
        if (root.navigationLocked) return
        const currentIndex = root.pages.findIndex(p => p.id === root.currentPage)
        if (currentIndex >= 0 && currentIndex < root.pages.length - 1) {
            root.navigationLocked = true
            root.currentPage = root.pages[currentIndex + 1].id
            navigationDebounceTimer.restart()
        }
    }
    Keys.onUpPressed: {
        if (root.currentPageSubsections.length === 0) return
        const currentIndex = root.currentPageSubsections.findIndex(s => s.id === root.currentSection)
        if (currentIndex > 0) {
            root.currentSection = root.currentPageSubsections[currentIndex - 1].id
        }
    }
    Keys.onDownPressed: {
        if (root.currentPageSubsections.length === 0) return
        const currentIndex = root.currentPageSubsections.findIndex(s => s.id === root.currentSection)
        if (currentIndex >= 0 && currentIndex < root.currentPageSubsections.length - 1) {
            root.currentSection = root.currentPageSubsections[currentIndex + 1].id
        }
    }

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
            component: welcomeComponent
        },
        {
            id: "tour",
            name: qsTr("Tour"),
            icon: "planet",
            component: tourComponent
        },
        {
            id: "getting-started",
            name: qsTr("Getting Started"),
            icon: "rocket_launch",
            component: gettingStartedComponent
        },
        {
            id: "configuration",
            name: qsTr("Configuration"),
            icon: "settings",
            component: configurationComponent
        },
        {
            id: "community",
            name: qsTr("Community"),
            icon: "people",
            component: communityComponent
        },
    ]

    readonly property var currentPageData: pages.find(p => p.id === currentPage) ?? pages[0]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StyledRect {
            id: topNav

            Layout.fillWidth: true
            Layout.preferredHeight: navContent.implicitHeight + Appearance.padding.normal * 2

            color: "transparent"
            radius: 0

            RowLayout {
                id: navContent

                anchors.fill: parent
                anchors.leftMargin: Appearance.padding.large
                anchors.rightMargin: Appearance.padding.large
                anchors.topMargin: Appearance.padding.normal
                anchors.bottomMargin: Appearance.padding.normal
                spacing: Appearance.spacing.normal

                RowLayout {
                    id: logo
                    spacing: Appearance.spacing.small

                    StyledText {
                        text: "Caelestia"
                        font.family: "Nunito"
                        font.pointSize: Appearance.font.size.large
                        font.bold: true
                        color: Colours.palette.m3onSurface
                    }
                }

                IconButton {
                    icon: "chevron_left"
                    visible: tabsFlickable.contentWidth > tabsFlickable.width
                    type: IconButton.Text
                    radius: Appearance.rounding.small
                    padding: Appearance.padding.small
                    onClicked: {
                        tabsFlickable.contentX = Math.max(0, tabsFlickable.contentX - 100);
                    }
                }

                StyledFlickable {
                    id: tabsFlickable
                    Layout.fillWidth: true
                    Layout.preferredHeight: tabsRow.height
                    flickableDirection: Flickable.HorizontalFlick
                    contentWidth: tabsRow.width
                    clip: true

                    Behavior on contentX {
                        Anim {
                            duration: Appearance.anim.durations.normal
                            easing.bezierCurve: Appearance.anim.curves.emphasized
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true

                        onWheel: wheel => {
                            const delta = wheel.angleDelta.y || wheel.angleDelta.x;
                            tabsFlickable.contentX = Math.max(0, Math.min(tabsFlickable.contentWidth - tabsFlickable.width, tabsFlickable.contentX - delta));
                            wheel.accepted = true;
                        }

                        onPressed: mouse => {
                            mouse.accepted = false;
                        }
                    }

                    Item {
                        implicitWidth: tabsRow.width
                        implicitHeight: tabsRow.height

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
                            spacing: Appearance.spacing.small

                            Repeater {
                                id: tabsRepeater
                                model: root.pages

                                delegate: Item {
                                    id: tabsItem

                                    required property var modelData
                                    required property int index

                                    property bool isActive: root.currentPage === modelData.id

                                    implicitWidth: tabContent.width + Appearance.padding.normal * 2
                                    implicitHeight: tabContent.height + Appearance.padding.smaller * 2

                                    StateLayer {
                                        anchors.fill: parent
                                        radius: Appearance.rounding.small
                                        function onClicked(): void {
                                            root.currentPage = tabsItem.modelData.id;

                                            const tabLeft = parent.x;
                                            const tabRight = parent.x + parent.width;
                                            const viewLeft = tabsFlickable.contentX;
                                            const viewRight = tabsFlickable.contentX + tabsFlickable.width;

                                            const targetX = tabLeft - (tabsFlickable.width - parent.width) / 2;

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
                                            fill: 1
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
                    icon: "chevron_right"
                    visible: tabsFlickable.contentWidth > tabsFlickable.width
                    type: IconButton.Text
                    radius: Appearance.rounding.small
                    padding: Appearance.padding.small
                    onClicked: {
                        tabsFlickable.contentX = Math.min(tabsFlickable.contentWidth - tabsFlickable.width, tabsFlickable.contentX + 100);
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
                anchors.topMargin: 0
                anchors.leftMargin: Appearance.padding.normal
                anchors.rightMargin: Appearance.padding.normal
                anchors.bottomMargin: Appearance.padding.normal
                color: Colours.palette.m3background
                radius: Appearance.rounding.normal
                z: -1
            }

            VerticalNav {
                id: globalVerticalNav
                property real targetX: root.currentPageSubsections.length > 0 ? Appearance.padding.normal : Appearance.padding.normal - Appearance.rounding.normal
                x: targetX
                y: Appearance.padding.normal + Appearance.padding.larger * 2
                implicitWidth: 200
                width: root.currentPageSubsections.length > 0 ? implicitWidth : 0
                z: 10
                visible: width > 0
                opacity: 1
                clip: false

                sections: root.displayedSubsections
                activeSection: root.currentSection
                onSectionChanged: sectionId => root.currentSection = sectionId

                Behavior on x {
                    NumberAnimation {
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.OutCubic
                    }
                }

            }

            SequentialAnimation {
                id: sidebarContentAnimation
                running: false

                ScriptAction {
                    script: {
                        if (root.currentPageSubsections.length === 0) {
                            delayedClearTimer.start()
                        }
                    }
                }

                NumberAnimation {
                    target: globalVerticalNav
                    property: "contentOpacity"
                    to: 0
                    duration: 100
                }

                ScriptAction {
                    script: {
                        if (root.currentPageSubsections.length > 0) {
                            root.displayedSubsections = root.currentPageSubsections
                        }
                    }
                }

                NumberAnimation {
                    target: globalVerticalNav
                    property: "contentOpacity"
                    to: 1
                    duration: 100
                }
            }

            Timer {
                id: delayedClearTimer
                interval: Appearance.anim.durations.normal
                onTriggered: {
                    root.displayedSubsections = []
                }
            }

            Connections {
                target: root
                function onCurrentPageSubsectionsChanged() {
                    const oldCount = root.displayedSubsections.length
                    const newCount = root.currentPageSubsections.length
                    
                    if (oldCount !== newCount && (oldCount > 0 || newCount > 0)) {
                        sidebarContentAnimation.restart()
                    } else if (newCount > 0) {
                        root.displayedSubsections = root.currentPageSubsections
                    }
                    
                    // Set to first item only if we don't have a current section or it's not in the new list
                    if (newCount > 0) {
                        const hasCurrentSection = root.currentPageSubsections.some(s => s.id === root.currentSection)
                        if (!hasCurrentSection) {
                            root.currentSection = root.currentPageSubsections[0].id
                        }
                    }
                }
            }

            property string activePage: ""
            property string targetPage: ""
            property bool transitioning: false
            property int direction: 0
            readonly property real pageY: Appearance.padding.normal

            Component.onCompleted: {
                activePage = root.currentPage;
                targetPage = root.currentPage;
                currentPageLoader.sourceComponent = root.currentPageData.component;
            }

            onTargetPageChanged: {
                if (targetPage !== activePage && !transitioning) {
                    const currentIndex = root.pages.findIndex(p => p.id === activePage);
                    const targetIndex = root.pages.findIndex(p => p.id === targetPage);
                    direction = targetIndex > currentIndex ? 1 : -1;

                    nextPageContainer.anchors.left = undefined;
                    if (direction > 0) {
                        nextPageContainer.x = contentArea.width;
                    } else {
                        nextPageContainer.x = -(nextPageContainer.width);
                    }
                    nextPageLoader.sourceComponent = root.pages.find(p => p.id === targetPage)?.component;
                    transitioning = true;
                }
            }

            Connections {
                target: nextPageLoader
                function onItemChanged() {
                    if (nextPageLoader.item && nextPageLoader.item.subsections !== undefined) {
                        root.targetPageSubsections = nextPageLoader.item.subsections
                    } else {
                        root.targetPageSubsections = []
                    }
                }
            }

            Connections {
                target: root
                function onCurrentPageChanged() {
                    contentArea.targetPage = root.currentPage;
                }
            }

            Item {
                id: currentPageContainer
                property real navOffset: root.currentPageSubsections.length > 0 ? globalVerticalNav.implicitWidth + Appearance.padding.normal : 0
                x: Appearance.padding.normal + navOffset
                y: contentArea.pageY
                width: parent.width - Appearance.padding.normal * 3 - navOffset
                height: parent.height - Appearance.padding.normal * 2 - Appearance.padding.normal
                z: contentArea.transitioning ? (contentArea.direction > 0 ? 2 : 1) : 2
                clip: true

                Behavior on x {
                    enabled: !contentArea.transitioning
                    NumberAnimation {
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on width {
                    enabled: !contentArea.transitioning
                    NumberAnimation {
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.OutCubic
                    }
                }

                Loader {
                    id: currentPageLoader
                    asynchronous: false
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    
                    onItemChanged: {
                        if (item && item.subsections !== undefined) {
                            root.currentPageSubsections = item.subsections
                            root.targetPageSubsections = item.subsections
                        } else {
                            root.currentPageSubsections = []
                            root.targetPageSubsections = []
                            root.currentSection = ""
                        }
                    }
                }
                
                Connections {
                    target: root
                    function onCurrentSectionChanged() {
                        if (currentPageLoader.item && currentPageLoader.item.scrollToSection) {
                            currentPageLoader.item.scrollToSection(root.currentSection)
                        }
                    }
                }
            }

            Item {
                id: nextPageContainer
                property real navOffset: root.targetPageSubsections.length > 0 ? globalVerticalNav.implicitWidth + Appearance.padding.normal : 0
                x: parent.width
                y: contentArea.pageY
                width: parent.width - Appearance.padding.normal * 3 - navOffset
                height: parent.height - Appearance.padding.normal * 2 - Appearance.padding.normal
                z: contentArea.transitioning ? (contentArea.direction > 0 ? 1 : 2) : 1
                clip: true

                Behavior on width {
                    enabled: !contentArea.transitioning
                    NumberAnimation {
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.OutCubic
                    }
                }

                Loader {
                    id: nextPageLoader
                    asynchronous: false
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                }
            }

            SequentialAnimation {
                id: slideAnimation
                running: false

                ParallelAnimation {
                    NumberAnimation {
                        target: currentPageContainer
                        property: "x"
                        to: contentArea.direction > 0 ? -(currentPageContainer.width) : contentArea.width
                        duration: 350
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: nextPageContainer
                        property: "x"
                        to: nextPageContainer.navOffset + Appearance.padding.normal
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                ScriptAction {
                    script: {
                        currentPageLoader.sourceComponent = nextPageLoader.sourceComponent;
                        currentPageContainer.x = Appearance.padding.normal + currentPageContainer.navOffset;
                        nextPageContainer.x = contentArea.width;
                        contentArea.activePage = contentArea.targetPage;
                        contentArea.transitioning = false;
                    }
                }
            }

            onTransitioningChanged: {
                if (transitioning) {
                    slideAnimation.start();
                }
            }
        }
    }

    Component {
        id: welcomeComponent
        Welcome {
            animationHasRun: root.welcomeAnimationHasRun
            onAnimationCompleted: {
                root.welcomeAnimationHasRun = true
            }
        }
    }

    Component {
        id:tourComponent
        Tour{}
    }

    Component {
        id: gettingStartedComponent
        GettingStarted {}
    }

    Component {
        id: configurationComponent
        Configuration {}
    }

    Component {
        id: communityComponent
        Community {}
    }
}
