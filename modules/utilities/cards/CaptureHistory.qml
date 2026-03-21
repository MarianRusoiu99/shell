pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Caelestia.Models
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property var props
    required property DrawerVisibilities visibilities

    spacing: 0

    WrapperMouseArea {
        Layout.fillWidth: true

        cursorShape: Qt.PointingHandCursor
        onClicked: root.props.historyExpanded = !root.props.historyExpanded

        RowLayout {
            spacing: Appearance.spacing.smaller

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                text: "history"
                font.pointSize: Appearance.font.size.large
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                text: qsTr("Captures")
                font.pointSize: Appearance.font.size.normal
            }

            IconButton {
                icon: root.props.historyExpanded ? "unfold_less" : "unfold_more"
                type: IconButton.Text
                label.animate: true
                onClicked: root.props.historyExpanded = !root.props.historyExpanded
            }
        }
    }

    StyledListView {
        id: list

        model: FileSystemModel {
            path: Paths.recsdir
            nameFilters: ["recording_*.mp4", "screenshot_*.png"]
            sortReverse: true
        }

        Layout.fillWidth: true
        Layout.rightMargin: -Appearance.spacing.small
        implicitHeight: (Appearance.font.size.larger + Appearance.padding.small) * (root.props.historyExpanded ? 10 : 3)
        clip: true

        StyledScrollBar.vertical: StyledScrollBar {
            flickable: list
        }

        delegate: RowLayout {
            id: capture

            required property FileSystemEntry modelData
            property string baseName
            property bool isScreenshot: modelData.baseName.startsWith("screenshot_")

            anchors.left: list.contentItem.left
            anchors.right: list.contentItem.right
            anchors.rightMargin: Appearance.spacing.small
            spacing: Appearance.spacing.small / 2

            Component.onCompleted: baseName = modelData.baseName

            // Icon indicator for type
            MaterialIcon {
                text: capture.isScreenshot ? "screenshot" : "videocam"
                color: capture.isScreenshot ? Colours.palette.m3tertiary : Colours.palette.m3secondary
                font.pointSize: Appearance.font.size.normal
            }

            StyledText {
                Layout.fillWidth: true
                Layout.rightMargin: Appearance.spacing.small / 2
                text: {
                    const time = capture.baseName;
                    const isScreenshot = capture.isScreenshot;

                    if (isScreenshot) {
                        const matches = time.match(/^screenshot_(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})/);
                        if (!matches)
                            return time;
                        const date = new Date(matches[1], matches[2] - 1, matches[3], matches[4], matches[5], matches[6]);
                        return qsTr("Screenshot at %1").arg(Qt.formatDateTime(date, Qt.locale()));
                    } else {
                        const matches = time.match(/^recording_(\d{4})(\d{2})(\d{2})_(\d{2})-(\d{2})-(\d{2})/);
                        if (!matches)
                            return time;
                        const date = new Date(...matches.slice(1));
                        date.setMonth(date.getMonth() - 1); // Woe (months start from 0)
                        return qsTr("Recording at %1").arg(Qt.formatDateTime(date, Qt.locale()));
                    }
                }
                color: Colours.palette.m3onSurfaceVariant
                elide: Text.ElideRight
            }

            // Action buttons based on type
            IconButton {
                icon: capture.isScreenshot ? "edit" : "play_arrow"
                type: IconButton.Text
                onClicked: {
                    root.visibilities.utilities = false;
                    root.visibilities.sidebar = false;
                    if (capture.isScreenshot) {
                        Quickshell.execDetached(["sh", "-c", `swappy -f "${capture.modelData.path}"`]);
                    } else {
                        Quickshell.execDetached(["app2unit", "--", ...Config.general.apps.playback, capture.modelData.path]);
                    }
                }
            }

            IconButton {
                icon: "folder"
                type: IconButton.Text
                onClicked: {
                    root.visibilities.utilities = false;
                    root.visibilities.sidebar = false;
                    Quickshell.execDetached(["app2unit", "--", ...Config.general.apps.explorer, capture.modelData.path]);
                }
            }

            IconButton {
                icon: "delete_forever"
                type: IconButton.Text
                label.color: Colours.palette.m3error
                stateLayer.color: Colours.palette.m3error
                onClicked: root.props.captureConfirmDelete = capture.modelData.path
            }
        }

        add: Transition {
            Anim {
                property: "opacity"
                from: 0
                to: 1
            }
            Anim {
                property: "scale"
                from: 0.5
                to: 1
            }
        }

        remove: Transition {
            Anim {
                property: "opacity"
                to: 0
            }
            Anim {
                property: "scale"
                to: 0.5
            }
        }

        displaced: Transition {
            Anim {
                properties: "opacity,scale"
                to: 1
            }
            Anim {
                property: "y"
            }
        }

        Loader {
            asynchronous: true
            anchors.centerIn: parent

            opacity: list.count === 0 ? 1 : 0
            active: opacity > 0

            sourceComponent: ColumnLayout {
                spacing: Appearance.spacing.small

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "photo_library"
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.extraLarge

                    opacity: root.props.historyExpanded ? 1 : 0
                    scale: root.props.historyExpanded ? 1 : 0
                    Layout.preferredHeight: root.props.historyExpanded ? implicitHeight : 0

                    Behavior on opacity {
                        Anim {}
                    }

                    Behavior on scale {
                        Anim {}
                    }

                    Behavior on Layout.preferredHeight {
                        Anim {}
                    }
                }

                RowLayout {
                    spacing: Appearance.spacing.smaller

                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        text: "photo_library"
                        color: Colours.palette.m3outline

                        opacity: !root.props.historyExpanded ? 1 : 0
                        scale: !root.props.historyExpanded ? 1 : 0
                        Layout.preferredWidth: !root.props.historyExpanded ? implicitWidth : 0

                        Behavior on opacity {
                            Anim {}
                        }

                        Behavior on scale {
                            Anim {}
                        }

                        Behavior on Layout.preferredWidth {
                            Anim {}
                        }
                    }

                    StyledText {
                        text: qsTr("No captures found")
                        color: Colours.palette.m3outline
                    }
                }
            }

            Behavior on opacity {
                Anim {}
            }
        }

        Behavior on implicitHeight {
            Anim {
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        }
    }
}
