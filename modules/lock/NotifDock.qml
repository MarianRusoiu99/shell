import "../sidebar" as Sidebar
import qs.config
import QtQuick

Item {
    id: root

    required property var lock

    anchors.fill: parent

    readonly property Sidebar.Props props: Sidebar.Props {
        reloadableId: "lockNotifs"
    }

    QtObject {
        id: dummyVisibilities
        property bool sidebar: false
    }

    Sidebar.NotifDock {
        anchors.fill: parent
        visible: !Config.lock.hideNotifs

        props: root.props
        visibilities: dummyVisibilities
        clearPopupsOnInit: false
    }
}
