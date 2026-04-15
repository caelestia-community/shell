pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services

Variants {
    model: Screens.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        Exclusions {
            screen: scope.modelData
            bar: content.bar
        }

        ContentWindow {
            id: content

            screen: scope.modelData

            Loader {
                id: tourOverlayLoader

                anchors.fill: parent
                active: tourOverlayActive
                z: 10000

                source: "../live/tour/TourOverlayContent.qml"

                property bool tourOverlayActive: Tour.spotlightActive || Tour.tourActive

                Timer {
                    id: deactivateTimer
                    interval: 250
                    repeat: false
                    onTriggered: tourOverlayLoader.active = false
                }

                onTourOverlayActiveChanged: {
                    if (tourOverlayActive) {
                        deactivateTimer.stop();
                        active = true;
                    } else if (item) {
                        item.opacity = 0;
                        deactivateTimer.restart();
                    } else {
                        active = false;
                    }
                }
            }
        }
    }
}
