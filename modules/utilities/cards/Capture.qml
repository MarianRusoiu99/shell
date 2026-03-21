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

    readonly property bool isVideoMode: root.props.captureMode === "video"

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

            // Mode toggle (Video / Screenshot)
            StyledRect {
                implicitWidth: modeToggleLayout.implicitWidth + Appearance.padding.small * 2
                implicitHeight: modeToggleLayout.implicitHeight + Appearance.padding.smaller * 2

                radius: Appearance.rounding.full
                color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 1)

                RowLayout {
                    id: modeToggleLayout

                    anchors.centerIn: parent
                    spacing: 0

                    StyledRect {
                        id: videoTab

                        implicitWidth: videoText.implicitWidth + Appearance.padding.normal * 2
                        implicitHeight: videoText.implicitHeight + Appearance.padding.smaller * 2

                        radius: Appearance.rounding.full
                        color: root.isVideoMode ? Colours.palette.m3secondary : "transparent"

                        StyledText {
                            id: videoText

                            anchors.centerIn: parent
                            text: qsTr("Video")
                            color: root.isVideoMode ? Colours.palette.m3onSecondary : Colours.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.small
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.props.captureMode = "video"
                        }
                    }

                    StyledRect {
                        id: screenshotTab

                        implicitWidth: screenshotText.implicitWidth + Appearance.padding.normal * 2
                        implicitHeight: screenshotText.implicitHeight + Appearance.padding.smaller * 2

                        radius: Appearance.rounding.full
                        color: !root.isVideoMode ? Colours.palette.m3tertiary : "transparent"

                        StyledText {
                            id: screenshotText

                            anchors.centerIn: parent
                            text: qsTr("Screenshot")
                            color: !root.isVideoMode ? Colours.palette.m3onTertiary : Colours.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.small
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.props.captureMode = "screenshot"
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            // Video mode: SplitButton for recording options
            SplitButton {
                visible: root.isVideoMode
                disabled: Recorder.running
                active: menuItems.find(m => root.props.recordingMode === m.icon + m.text) ?? menuItems[0]
                menu.onItemSelected: item => root.props.recordingMode = item.icon + item.text

                menuItems: [
                    MenuItem {
                        icon: "fullscreen"
                        text: qsTr("Record fullscreen")
                        activeText: qsTr("Fullscreen")
                        onClicked: Recorder.start()
                    },
                    MenuItem {
                        icon: "screenshot_region"
                        text: qsTr("Record region")
                        activeText: qsTr("Region")
                        onClicked: Recorder.start(["-r"])
                    },
                    MenuItem {
                        icon: "select_to_speak"
                        text: qsTr("Record fullscreen with sound")
                        activeText: qsTr("Fullscreen")
                        onClicked: Recorder.start(["-s"])
                    },
                    MenuItem {
                        icon: "volume_up"
                        text: qsTr("Record region with sound")
                        activeText: qsTr("Region")
                        onClicked: Recorder.start(["-sr"])
                    }
                ]
            }

            // Screenshot mode: SplitButton for screenshot options
            SplitButton {
                visible: !root.isVideoMode
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
                        icon: "draw"
                        text: qsTr("Screenshot fullscreen and draw")
                        activeText: qsTr("Full + Draw")
                        onClicked: Screenshotter.screenshotFullscreenDraw()
                    },
                    MenuItem {
                        icon: "ink_selection"
                        text: qsTr("Screenshot region and draw")
                        activeText: qsTr("Region + Draw")
                        onClicked: Screenshotter.screenshotRegionDraw()
                    },
                    MenuItem {
                        icon: "content_copy"
                        text: qsTr("Screenshot fullscreen to clipboard")
                        activeText: qsTr("Full -> Clip")
                        onClicked: Screenshotter.screenshotFullscreenClip()
                    },
                    MenuItem {
                        icon: "content_cut"
                        text: qsTr("Screenshot region to clipboard")
                        activeText: qsTr("Region -> Clip")
                        onClicked: Screenshotter.screenshotRegionClip()
                    }
                ]
            }
        }

        // Recording controls (when video is recording)
        Loader {
            id: recordingControls

            visible: root.isVideoMode && Recorder.running
            active: visible

            Layout.fillWidth: true
            Layout.preferredHeight: active ? item?.implicitHeight ?? 0 : 0

            sourceComponent: RowLayout {
                spacing: Appearance.spacing.normal

                StyledRect {
                    radius: Appearance.rounding.full
                    color: Recorder.paused ? Colours.palette.m3tertiary : Colours.palette.m3error

                    implicitWidth: recText.implicitWidth + Appearance.padding.normal * 2
                    implicitHeight: recText.implicitHeight + Appearance.padding.smaller * 2

                    StyledText {
                        id: recText

                        anchors.centerIn: parent
                        animate: true
                        text: Recorder.paused ? "PAUSED" : "REC"
                        color: Recorder.paused ? Colours.palette.m3onTertiary : Colours.palette.m3onError
                        font.family: Appearance.font.family.mono
                    }

                    Behavior on implicitWidth {
                        Anim {}
                    }

                    SequentialAnimation on opacity {
                        running: !Recorder.paused
                        alwaysRunToEnd: true
                        loops: Animation.Infinite

                        Anim {
                            from: 1
                            to: 0
                            duration: Appearance.anim.durations.large
                            easing.bezierCurve: Appearance.anim.curves.emphasizedAccel
                        }
                        Anim {
                            from: 0
                            to: 1
                            duration: Appearance.anim.durations.extraLarge
                            easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
                        }
                    }
                }

                StyledText {
                    text: {
                        const elapsed = Recorder.elapsed;

                        const hours = Math.floor(elapsed / 3600);
                        const mins = Math.floor((elapsed % 3600) / 60);
                        const secs = Math.floor(elapsed % 60).toString().padStart(2, "0");

                        let time;
                        if (hours > 0)
                            time = `${hours}:${mins.toString().padStart(2, "0")}:${secs}`;
                        else
                            time = `${mins}:${secs}`;

                        return qsTr("Recording for %1").arg(time);
                    }
                    font.pointSize: Appearance.font.size.normal
                }

                Item {
                    Layout.fillWidth: true
                }

                IconButton {
                    label.animate: true
                    icon: Recorder.paused ? "play_arrow" : "pause"
                    toggle: true
                    checked: Recorder.paused
                    type: IconButton.Tonal
                    font.pointSize: Appearance.font.size.large
                    onClicked: {
                        Recorder.togglePause();
                        internalChecked = Recorder.paused;
                    }
                }

                IconButton {
                    icon: "stop"
                    inactiveColour: Colours.palette.m3error
                    inactiveOnColour: Colours.palette.m3onError
                    font.pointSize: Appearance.font.size.large
                    onClicked: Recorder.stop()
                }
            }
        }

        // Shared history list
        CaptureHistory {
            props: root.props
            visibilities: root.visibilities
        }
    }

}
