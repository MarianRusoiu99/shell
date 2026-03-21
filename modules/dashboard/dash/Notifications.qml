import "../../sidebar" as Sidebar
import qs.config
import QtQuick

Item {
    id: root

    required property var visibilities
    readonly property Sidebar.Props props: Sidebar.Props {
        reloadableId: "dashboardNotifs"
    }

    anchors.fill: parent
    implicitWidth: Config.dashboard.sizes.notificationsWidth

    Sidebar.NotifDock {
        anchors.fill: parent

        props: root.props
        visibilities: root.visibilities
        clearPopupsOnInit: false
    }
}
