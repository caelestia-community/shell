pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    // User Setup
    property string fullname: ""
    property string username: ""
    property string hostname: ""
    property string password: ""
    property string birthday: ""

    // Timezone
    property string timezone: ""

    // Software (Initialize as empty array)
    property var software: []

    // Target Disk
    property string targetDisk: ""
}
