pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property var props
    required property DrawerVisibilities visibilities

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + layout.anchors.margins * 2

    radius: Appearance.rounding.normal
    color: Colours.tPalette.m3surfaceContainer

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        RowLayout {
            spacing: Appearance.spacing.normal
            z: 1

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: {
                    const h = icon.implicitHeight + Appearance.padding.smaller * 2;
                    return h - (h % 2);
                }

                radius: Appearance.rounding.full
                color: Colours.palette.m3tertiaryContainer

                MaterialIcon {
                    id: icon

                    anchors.centerIn: parent
                    text: "screenshot"
                    color: Colours.palette.m3onTertiaryContainer
                    font.pointSize: Appearance.font.size.large
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Screenshot")
                    font.pointSize: Appearance.font.size.normal
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Capture your screen")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }
            }

            SplitButton {
                active: menuItems.find(m => root.props.screenshotMode === m.icon + m.text) ?? menuItems[0]
                menu.onItemSelected: item => root.props.screenshotMode = item.icon + item.text

                menuItems: [
                    MenuItem {
                        icon: "screenshot"
                        text: qsTr("Screenshot fullscreen")
                        activeText: qsTr("Fullscreen")
                        onClicked: Screenshotter.screenshotFullscreen()
                    },
                    MenuItem {
                        icon: "screenshot_region"
                        text: qsTr("Screenshot region")
                        activeText: qsTr("Region")
                        onClicked: Screenshotter.screenshotRegion()
                    },
                    MenuItem {
                        icon: "content_copy"
                        text: qsTr("Screenshot fullscreen to clipboard")
                        activeText: qsTr("Full → Clip")
                        onClicked: Screenshotter.screenshotFullscreenClip()
                    },
                    MenuItem {
                        icon: "content_cut"
                        text: qsTr("Screenshot region to clipboard")
                        activeText: qsTr("Region → Clip")
                        onClicked: Screenshotter.screenshotRegionClip()
                    }
                ]
            }
        }

        ScreenshotList {
            props: root.props
            visibilities: root.visibilities
        }
    }

    ScreenshotDeleteModal {
        props: root.props
    }
}
