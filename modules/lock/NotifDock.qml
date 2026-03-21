import "../sidebar" as Sidebar
import qs.components
import qs.config
import QtQuick

Item {
    id: root

    required property var lock

    anchors.fill: parent

    readonly property Sidebar.Props props: Sidebar.Props {
        reloadableId: "lockNotifs"
    }

    DrawerVisibilities {
        id: dummyVisibilities
    }

    Sidebar.NotifDock {
        anchors.fill: parent
        visible: !Config.lock.hideNotifs

        props: root.props
        visibilities: dummyVisibilities
        clearPopupsOnInit: false
    }
}
