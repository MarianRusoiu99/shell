import "../sidebar" as Sidebar
import qs.components
import qs.config
import QtQuick
import QtQuick.Layouts

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

    Loader {
        anchors.centerIn: parent
        active: Config.lock.hideNotifs
        asynchronous: true

        sourceComponent: ColumnLayout {
            spacing: Appearance.spacing.large

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "lock"
                color: Colours.palette.m3outlineVariant
                font.pointSize: Appearance.font.size.extraLarge * 2
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Unlock for Notifications")
                color: Colours.palette.m3outlineVariant
                font.pointSize: Appearance.font.size.large
                font.family: Appearance.font.family.mono
                font.weight: 500
            }
        }
    }
}
