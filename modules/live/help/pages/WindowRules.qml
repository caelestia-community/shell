import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.services
import qs.components
import qs.components.containers

Item {
    id: root

    StyledFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: Math.max(contentColumn.implicitHeight, flickable.height)
        flickableDirection: Flickable.VerticalFlick

        ColumnLayout {
            id: contentColumn
            width: parent.width
            height: Math.max(implicitHeight, flickable.height)
            spacing: Tokens.padding.large

            Item { Layout.fillHeight: true }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Coming Soon"
                    font.pointSize: Tokens.font.size.extraLarge
                    font.bold: true
                    color: Colours.palette.m3onBackground
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Please stand by"
                    font.pointSize: Tokens.font.size.larger
                    color: Colours.palette.m3onSurfaceVariant
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
