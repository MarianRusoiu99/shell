import "../sidebar" as Sidebar
import qs.config
import QtQuick

Item {
    id: root

    required property var lock

    anchors.fill: parent

    readonly property Sidebar.Props props: Sidebar.Props {
        reloadableId: "dashboardNotifs"
    }

    QtObject {
        id: dummyVisibilities
        property bool sidebar: false
    }

    Sidebar.NotifDock {
        anchors.fill: parent

        props: root.props
        visibilities: dummyVisibilities
        clearPopupsOnInit: false
    }
}
