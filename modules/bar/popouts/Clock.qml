pragma ComponentBehavior: Bound

import qs.components
import qs.config
import QtQuick
import "../../dashboard/dash"

Item {
    id: root

    readonly property QtObject state: QtObject {
        property date currentDate: new Date()
    }

    implicitWidth: Config.bar.sizes.clockWidth
    implicitHeight: calendar.implicitHeight

    Calendar {
        id: calendar

        anchors.left: parent.left
        anchors.right: parent.right
        state: root.state
    }
}
