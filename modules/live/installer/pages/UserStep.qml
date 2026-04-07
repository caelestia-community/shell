pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components
import qs.components.live
import qs.components.containers
import qs.config

Item {
    id: root
    property var config: ({})

    signal requestNext

    Component.onCompleted: {
        if (root.config) {
            if (root.config.fullname)
                fullNameField.text = root.config.fullname;

            if (root.config.username) {
                usernameField.text = root.config.username;
                root.autoGenUsername = false;
            }
            if (root.config.hostname) {
                hostnameField.text = root.config.hostname;
                root.autoGenHostname = false;
            }
            if (root.config.birthday) {
                birthdayField.text = root.config.birthday;
                skipBirthday = false;
            }
            if (root.config.password) {
                passwordField.text = root.config.password;
                confirmField.text = root.config.password;
            }
        }
    }

    property bool autoGenUsername: true
    property bool autoGenHostname: true
    property bool skipBirthday: false

    property bool isBirthdayValid: {
        if (skipBirthday)
            return true;

        let txt = birthdayField.text.replace(/_/g, "").trim();
        if (txt.length < 5)
            return false;

        let parts = txt.split("/");
        if (parts.length !== 2)
            return false;

        let m = parseInt(parts[0], 10);
        let d = parseInt(parts[1], 10);

        if (isNaN(m) || isNaN(d))
            return false;
        if (m < 1 || m > 12)
            return false;
        if (d < 1 || d > 31)
            return false;

        if ((m === 4 || m === 6 || m === 9 || m === 11) && d > 30)
            return false;
        if (m === 2 && d > 29)
            return false;

        return true;
    }

    readonly property bool isReady: config && fullNameField.text.trim() !== "" && isBirthdayValid && usernameField.text.trim() !== "" && hostnameField.text.trim() !== "" && passwordField.text !== "" && passwordField.text === confirmField.text

    function handleEnter() {
        if (root.isReady) {
            root.requestNext();
        } else {
            if (fullNameField.text.trim() === "")
                fullNameField.forceActiveFocus();
            else if (!skipBirthday && !isBirthdayValid)
                birthdayField.forceActiveFocus();
            else if (usernameField.text.trim() === "")
                usernameField.forceActiveFocus();
            else if (hostnameField.text.trim() === "")
                hostnameField.forceActiveFocus();
            else if (passwordField.text === "")
                passwordField.forceActiveFocus();
            else if (confirmField.text === "" || confirmField.text !== passwordField.text)
                confirmField.forceActiveFocus();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        ColumnLayout {
            spacing: 0
            StyledText {
                text: qsTr("User Setup")
                font.family: "Nunito"
                font.pointSize: 18
                font.bold: true
                color: Colours.palette.m3onSurface
            }
            StyledText {
                text: qsTr("Configure your primary account and device name.")
                font.pointSize: 12
                color: Colours.palette.m3onSurfaceVariant
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 16
            rowSpacing: 16

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                spacing: 8

                StyledText {
                    text: qsTr("Full Name")
                    font.bold: true
                    color: Colours.palette.m3primary
                }

                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: Colours.palette.m3surfaceContainerHigh
                    radius: 8
                    border.width: 1
                    border.color: fullNameField.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant

                    TextInput {
                        id: fullNameField
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: Colours.palette.m3onSurface
                        font.pointSize: 14

                        KeyNavigation.tab: skipBirthday ? usernameField : birthdayField
                        onAccepted: root.handleEnter()

                        onTextChanged: {
                            if (root.config)
                                root.config.fullname = text;

                            let baseName = text.split(" ")[0].toLowerCase().replace(/[^a-z0-9]/g, "");
                            if (baseName !== "") {
                                if (root.autoGenUsername)
                                    usernameField.text = baseName;
                                if (root.autoGenHostname)
                                    hostnameField.text = baseName + "-pc";
                            } else {
                                if (root.autoGenUsername)
                                    usernameField.text = "";
                                if (root.autoGenHostname)
                                    hostnameField.text = "";
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: qsTr("Birthday (MM/DD)")
                        font.bold: true
                        color: skipBirthday ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3primary
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    MouseArea {
                        Layout.preferredWidth: optOutRow.width
                        Layout.preferredHeight: optOutRow.height
                        onClicked: {
                            skipBirthday = !skipBirthday;
                            if (skipBirthday) {
                                birthdayField.text = "";
                                if (root.config)
                                    root.config.birthday = "";
                            }
                        }
                        Row {
                            id: optOutRow
                            spacing: 6
                            MaterialIcon {
                                text: skipBirthday ? "check_box" : "check_box_outline_blank"
                                color: skipBirthday ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                                font.pointSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            StyledText {
                                text: qsTr("Opt out")
                                font.pointSize: 12
                                color: Colours.palette.m3onSurfaceVariant
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: skipBirthday ? Colours.palette.m3surfaceContainer : Colours.palette.m3surfaceContainerHigh
                    radius: 8
                    border.width: 1
                    opacity: skipBirthday ? 0.5 : 1.0
                    border.color: {
                        if (skipBirthday)
                            return Colours.palette.m3outlineVariant;
                        if (birthdayField.text.replace(/_/g, "").trim().length === 5 && !isBirthdayValid)
                            return Colours.palette.m3error;
                        return birthdayField.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant;
                    }

                    TextInput {
                        id: birthdayField
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: Colours.palette.m3onSurface
                        font.pointSize: 14
                        enabled: !skipBirthday
                        inputMask: skipBirthday ? "" : "99/99;_"

                        // THE FIX: Tab and Enter Bindings
                        KeyNavigation.tab: usernameField
                        KeyNavigation.backtab: fullNameField
                        onAccepted: root.handleEnter()

                        onTextChanged: if (root.config && !skipBirthday)
                            root.config.birthday = text
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                spacing: 8

                StyledText {
                    text: qsTr("Username")
                    font.bold: true
                    color: Colours.palette.m3primary
                }

                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: Colours.palette.m3surfaceContainerHigh
                    radius: 8
                    border.width: 1
                    border.color: usernameField.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant

                    TextInput {
                        id: usernameField
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: Colours.palette.m3onSurface
                        font.pointSize: 14

                        KeyNavigation.tab: hostnameField
                        KeyNavigation.backtab: skipBirthday ? fullNameField : birthdayField
                        onAccepted: root.handleEnter()

                        onTextEdited: root.autoGenUsername = false
                        onTextChanged: if (root.config)
                            root.config.username = text
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                spacing: 8

                StyledText {
                    text: qsTr("Device Name (Hostname)")
                    font.bold: true
                    color: Colours.palette.m3primary
                }

                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: Colours.palette.m3surfaceContainerHigh
                    radius: 8
                    border.width: 1
                    border.color: hostnameField.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant

                    TextInput {
                        id: hostnameField
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: Colours.palette.m3onSurface
                        font.pointSize: 14

                        KeyNavigation.tab: passwordField
                        KeyNavigation.backtab: usernameField
                        onAccepted: root.handleEnter()

                        onTextEdited: root.autoGenHostname = false
                        onTextChanged: if (root.config)
                            root.config.hostname = text
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                spacing: 8

                StyledText {
                    text: qsTr("Password")
                    font.bold: true
                    color: Colours.palette.m3primary
                }

                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: Colours.palette.m3surfaceContainerHigh
                    radius: 8
                    border.width: 1
                    border.color: passwordField.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant

                    TextInput {
                        id: passwordField
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        color: Colours.palette.m3onSurface
                        font.pointSize: 14

                        KeyNavigation.tab: confirmField
                        KeyNavigation.backtab: hostnameField
                        onAccepted: root.handleEnter()

                        onTextChanged: if (root.config)
                            root.config.password = text
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                spacing: 8

                StyledText {
                    text: qsTr("Confirm Password")
                    font.bold: true
                    color: Colours.palette.m3primary
                }

                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: Colours.palette.m3surfaceContainerHigh
                    radius: 8
                    border.width: 1
                    border.color: (confirmField.text !== "" && confirmField.text !== passwordField.text) ? Colours.palette.m3error : (confirmField.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant)

                    TextInput {
                        id: confirmField
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        color: Colours.palette.m3onSurface
                        font.pointSize: 14

                        KeyNavigation.tab: fullNameField
                        KeyNavigation.backtab: passwordField
                        onAccepted: root.handleEnter()
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 24

            StyledText {
                text: qsTr("Passwords do not match")
                visible: confirmField.text !== "" && confirmField.text !== passwordField.text
                color: Colours.palette.m3error
                font.pointSize: 12
            }

            StyledText {
                text: qsTr("Invalid calendar date")
                visible: !skipBirthday && birthdayField.text.replace(/_/g, "").trim().length === 5 && !isBirthdayValid
                color: Colours.palette.m3error
                font.pointSize: 12
            }
        }

        Item {
            Layout.fillHeight: true
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: privacyRow.implicitHeight + 32
            color: Colours.palette.m3surfaceContainerHigh
            radius: 12
            border.width: 1
            border.color: Colours.palette.m3outlineVariant

            RowLayout {
                id: privacyRow
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                MaterialIcon {
                    text: "lock"
                    font.pointSize: 24
                    color: Colours.palette.m3primary
                    Layout.alignment: Qt.AlignVCenter
                }

                StyledText {
                    text: qsTr("Privacy Notice: All data entered here is strictly used for your local installation. No telemetry or personal information is ever transmitted.")
                    font.pointSize: 12
                    color: Colours.palette.m3onSurfaceVariant
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    lineHeight: 1.2
                }
            }
        }
    }
}
