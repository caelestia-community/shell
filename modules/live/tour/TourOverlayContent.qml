import qs.components
import qs.components.controls
import qs.services
import Caelestia.Config
import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

Item {
    id: root

    property rect targetRect: Tour.targetRect
    property bool isTourActive: Tour.tourActive
    property var currentStep: Tour.currentStep
    property int stepIndex: Tour.currentStepIndex
    property int totalSteps: Tour.currentTour?.steps.length ?? 0

    opacity: 0

    property bool initialAppearance: true
    property bool hasValidRect: false
    property bool tourJustStarted: false

    readonly property real paddingLarge: Tokens.padding.large
    readonly property real roundingNormal: Tokens.rounding.normal

    onIsTourActiveChanged: {
        if (isTourActive && stepIndex === 0) {
            tourJustStarted = true;
            initialAppearance = true;
            hasValidRect = false;
        } else if (!isTourActive) {
            initialAppearance = false;
        }
    }

    onTargetRectChanged: {
        if (targetRect.width > 0 && targetRect.height > 0 && !hasValidRect && tourJustStarted) {
            hasValidRect = true;
            tourJustStarted = false;
            Qt.callLater(() => {
                initialAppearance = false;
                opacity = 1;
            });
        }
    }

    Component.onCompleted: {
        if (targetRect.width > 0 && targetRect.height > 0) {
            hasValidRect = true;
            Qt.callLater(() => {
                initialAppearance = false;
                opacity = 1;
            });
        }
    }

    Behavior on opacity {
        enabled: !root.initialAppearance
        NumberAnimation {
            duration: Tokens.anim.durations.normal
            easing.type: Easing.InOutQuad
        }
    }

    Shape {
        id: dimShape
        anchors.fill: parent

        ShapePath {
            fillColor: Qt.rgba(0, 0, 0, 0.5)
            strokeColor: "transparent"

            PathSvg {
                path: {
                    const w = dimShape.width;
                    const h = dimShape.height;
                    const x = root.targetRect.x - root.paddingLarge;
                    const y = root.targetRect.y - root.paddingLarge;
                    const rw = root.targetRect.width + root.paddingLarge * 2;
                    const rh = root.targetRect.height + root.paddingLarge * 2;
                    const r = root.roundingNormal;

                    if (root.targetRect.width <= 0 || root.targetRect.height <= 0) {
                        return `M 0,0 L ${w},0 L ${w},${h} L 0,${h} Z`;
                    }

                    return `M 0,0 L ${w},0 L ${w},${h} L 0,${h} Z
                            M ${x + r},${y}
                            L ${x + rw - r},${y}
                            Q ${x + rw},${y} ${x + rw},${y + r}
                            L ${x + rw},${y + rh - r}
                            Q ${x + rw},${y + rh} ${x + rw - r},${y + rh}
                            L ${x + r},${y + rh}
                            Q ${x},${y + rh} ${x},${y + rh - r}
                            L ${x},${y + r}
                            Q ${x},${y} ${x + r},${y} Z`;
                }
            }
        }
    }

    Rectangle {
        id: highlightBorder
        x: root.targetRect.x - Tokens.padding.large
        y: root.targetRect.y - Tokens.padding.large
        width: root.targetRect.width + Tokens.padding.large * 2
        height: root.targetRect.height + Tokens.padding.large * 2
        color: "transparent"
        border.color: Colours.palette.m3error
        border.width: 3
        radius: Tokens.rounding.normal
        visible: root.targetRect.width > 0

        Behavior on x { enabled: !root.initialAppearance; Anim { duration: Tokens.anim.durations.normal; easing.bezierCurve: Tokens.anim.emphasized } }
        Behavior on y { enabled: !root.initialAppearance; Anim { duration: Tokens.anim.durations.normal; easing.bezierCurve: Tokens.anim.emphasized } }
        Behavior on width { enabled: !root.initialAppearance; Anim { duration: Tokens.anim.durations.normal; easing.bezierCurve: Tokens.anim.emphasized } }
        Behavior on height { enabled: !root.initialAppearance; Anim { duration: Tokens.anim.durations.normal; easing.bezierCurve: Tokens.anim.emphasized } }

        SequentialAnimation on opacity {
            running: highlightBorder.visible
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 0.3; duration: 1000; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 0.3; to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.visible
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        z: 1

        onClicked: mouse => {
            const rect = root.targetRect;
            const inTarget = mouse.x >= rect.x && mouse.x <= rect.x + rect.width &&
                           mouse.y >= rect.y && mouse.y <= rect.y + rect.height;
            const inTooltip = tooltip.visible && mouse.x >= tooltip.x && mouse.x <= tooltip.x + tooltip.width &&
                            mouse.y >= tooltip.y && mouse.y <= tooltip.y + tooltip.height;

            if (!inTarget && !inTooltip) {
                mouse.accepted = true;
            } else {
                mouse.accepted = false;
            }
        }
    }

    Rectangle {
        id: tooltip

        visible: root.isTourActive && root.currentStep && root.targetRect.width > 0

        readonly property string position: root.currentStep?.tooltipPosition ?? "bottom"

        property real targetX: {
            if (position === "left") {
                return root.targetRect.x - width - Tokens.padding.large * 2;
            } else if (position === "right") {
                return root.targetRect.x + root.targetRect.width + Tokens.padding.large * 2;
            } else {
                return root.targetRect.x;
            }
        }

        property real targetY: {
            if (position === "top") {
                return root.targetRect.y - height - Tokens.padding.large * 2;
            } else if (position === "bottom") {
                return root.targetRect.y + root.targetRect.height + Tokens.padding.large * 2;
            } else {
                return root.targetRect.y;
            }
        }

        x: Math.max(Tokens.padding.normal, Math.min(targetX, parent.width - width - Tokens.padding.normal))
        y: Math.max(Tokens.padding.normal, Math.min(targetY, parent.height - height - Tokens.padding.normal))

        width: Math.min(400, parent.width - Tokens.padding.normal * 2)
        height: tooltipContent.implicitHeight + Tokens.padding.large * 2

        color: Colours.palette.m3surfaceContainer
        radius: Tokens.rounding.normal
        border.color: Colours.palette.m3primary
        border.width: 2
        z: 3

        Behavior on x {
            Anim {
                type: Anim.Emphasized
            }
        }

        Behavior on y {
            Anim {
                type: Anim.Emphasized
            }
        }

        ColumnLayout {
            id: tooltipContent
            anchors.fill: parent
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.normal

            StyledText {
                visible: root.totalSteps > 1
                text: qsTr("Step %1 of %2").arg(root.stepIndex + 1).arg(root.totalSteps)
                font.pointSize: Tokens.font.size.small
                color: Colours.palette.m3onSurface
                opacity: 0.7
            }

            StyledText {
                text: root.currentStep?.title ?? ""
                font.pointSize: Tokens.font.size.large
                font.bold: true
                color: Colours.palette.m3primary
            }

            StyledText {
                Layout.fillWidth: true
                text: root.currentStep?.tooltip ?? ""
                font.pointSize: Tokens.font.size.normal
                color: Colours.palette.m3onSurface
                wrapMode: Text.WordWrap
            }

            Row {
                Layout.fillWidth: true
                visible: root.totalSteps === 1

                TextButton {
                    text: qsTr("Close")
                    radius: Tokens.rounding.small
                    onClicked: Tour.nextStep()
                }
            }

            Row {
                Layout.fillWidth: true
                spacing: Tokens.spacing.normal
                visible: root.totalSteps > 1

                TextButton {
                    text: qsTr("Previous")
                    radius: Tokens.rounding.small
                    visible: root.stepIndex > 0
                    enabled: root.stepIndex > 0
                    onClicked: Tour.previousStep()
                }

                TextButton {
                    text: root.stepIndex < root.totalSteps - 1 ? qsTr("Next") : qsTr("Complete")
                    radius: Tokens.rounding.small
                    onClicked: Tour.nextStep()
                }

                Item { Layout.fillWidth: true }

                TextButton {
                    text: qsTr("Skip Tour")
                    radius: Tokens.rounding.small
                    inactiveColour: Colours.palette.m3errorContainer
                    inactiveOnColour: Colours.palette.m3onErrorContainer
                    onClicked: Tour.skipTour()
                }
            }
        }
    }
}
