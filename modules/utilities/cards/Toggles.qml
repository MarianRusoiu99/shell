pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import qs.modules.bar.popouts as BarPopouts
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property DrawerVisibilities visibilities
    required property BarPopouts.Wrapper popouts

    readonly property var quickToggles: {
        const seenIds = new Set();

        return Config.utilities.quickToggles.filter(item => {
            if (!item.enabled)
                return false;

            if (seenIds.has(item.id)) {
                return false;
            }

            if (item.id === "vpn") {
                return Config.utilities.vpn.provider.some(p => typeof p === "object" ? (p.enabled === true) : false);
            }

            seenIds.add(item.id);
            return true;
        });
    }
    readonly property int splitIndex: Math.ceil(quickToggles.length / 2)
    readonly property bool needExtraRow: quickToggles.length > 6

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2

    radius: Appearance.rounding.normal
    color: Colours.tPalette.m3surfaceContainer

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        StyledText {
            text: qsTr("Quick Toggles")
            font.pointSize: Appearance.font.size.normal
        }

        QuickToggleRow {
            rowModel: root.needExtraRow ? root.quickToggles.slice(0, root.splitIndex) : root.quickToggles
        }

        QuickToggleRow {
            visible: root.needExtraRow
            rowModel: root.needExtraRow ? root.quickToggles.slice(root.splitIndex) : []
        }

        // Idle Inhibit toggle at the bottom
        IdleInhibitToggle {}
    }

    component IdleInhibitToggle: StyledRect {
        Layout.fillWidth: true
        Layout.topMargin: Appearance.spacing.small

        implicitHeight: idleInhibitLayout.implicitHeight + Appearance.padding.normal * 2

        radius: Appearance.rounding.normal
        color: IdleInhibitor.enabled ? Colours.palette.m3secondaryContainer : Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)

        property bool hovered: false

        RowLayout {
            id: idleInhibitLayout

            anchors.fill: parent
            anchors.margins: Appearance.padding.normal
            spacing: Appearance.spacing.small

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: idleIcon.implicitHeight + Appearance.padding.smaller * 2

                radius: Appearance.rounding.full
                color: IdleInhibitor.enabled ? Colours.palette.m3secondary : "transparent"

                MaterialIcon {
                    id: idleIcon

                    anchors.centerIn: parent
                    text: "coffee"
                    color: IdleInhibitor.enabled ? Colours.palette.m3onSecondary : Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.normal
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Keep Awake")
                color: IdleInhibitor.enabled ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
            }

            StyledRect {
                implicitWidth: 40
                implicitHeight: 24
                radius: Appearance.rounding.full
                color: IdleInhibitor.enabled ? Colours.palette.m3secondary : Colours.palette.m3outline

                StyledRect {
                    id: toggleKnob

                    width: 18
                    height: 18
                    radius: Appearance.rounding.full
                    color: IdleInhibitor.enabled ? Colours.palette.m3onSecondary : Colours.palette.m3surface

                    anchors.verticalCenter: parent.verticalCenter
                    x: IdleInhibitor.enabled ? parent.width - width - 3 : 3

                    Behavior on x {
                        Anim {}
                    }

                    Behavior on color {
                        Anim {}
                    }
                }
            }
        }

        // Tooltip showing active since time
        StyledRect {
            id: activeTooltip

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: Appearance.spacing.small

            width: activeTooltipText.implicitWidth + Appearance.padding.normal * 2
            height: activeTooltipText.implicitHeight + Appearance.padding.small * 2

            radius: Appearance.rounding.small
            color: Colours.palette.m3inverseSurface
            visible: parent.hovered && IdleInhibitor.enabled

            StyledText {
                id: activeTooltipText

                anchors.centerIn: parent
                text: qsTr("Active since %1").arg(Qt.formatTime(IdleInhibitor.enabledSince, Config.services.useTwelveHourClock ? "hh:mm a" : "hh:mm"))
                color: Colours.palette.m3inverseOnSurface
                font.pointSize: Appearance.font.size.small
            }

            Behavior on visible {
                Anim {}
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: IdleInhibitor.enabled = !IdleInhibitor.enabled
            onEntered: parent.hovered = true
            onExited: parent.hovered = false
        }
    }

    component QuickToggleRow: RowLayout {
        property var rowModel: []

        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        Repeater {
            model: parent.rowModel

            delegate: DelegateChooser {
                role: "id"

                DelegateChoice {
                    roleValue: "wifi"
                    delegate: Toggle {
                        icon: "wifi"
                        checked: Nmcli.wifiEnabled
                        onClicked: Nmcli.toggleWifi()
                    }
                }
                DelegateChoice {
                    roleValue: "bluetooth"
                    delegate: Toggle {
                        icon: "bluetooth"
                        checked: Bluetooth.defaultAdapter?.enabled ?? false
                        onClicked: {
                            const adapter = Bluetooth.defaultAdapter;
                            if (adapter)
                                adapter.enabled = !adapter.enabled;
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "mic"
                    delegate: Toggle {
                        icon: "mic"
                        checked: !Audio.sourceMuted
                        onClicked: {
                            const audio = Audio.source?.audio;
                            if (audio)
                                audio.muted = !audio.muted;
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "settings"
                    delegate: Toggle {
                        icon: "settings"
                        inactiveOnColour: Colours.palette.m3onSurfaceVariant
                        toggle: false
                        onClicked: {
                            root.visibilities.utilities = false;
                            root.popouts.detach("network");
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "gameMode"
                    delegate: Toggle {
                        icon: "gamepad"
                        checked: GameMode.enabled
                        onClicked: GameMode.enabled = !GameMode.enabled
                    }
                }
                DelegateChoice {
                    roleValue: "dnd"
                    delegate: Toggle {
                        icon: "notifications_off"
                        checked: Notifs.dnd
                        onClicked: Notifs.dnd = !Notifs.dnd
                    }
                }
                DelegateChoice {
                    roleValue: "vpn"
                    delegate: Toggle {
                        icon: "vpn_key"
                        checked: VPN.connected
                        enabled: !VPN.connecting
                        onClicked: VPN.toggle()
                    }
                }
            }
        }
    }

    component Toggle: IconButton {
        Layout.fillWidth: true
        Layout.preferredWidth: implicitWidth + (stateLayer.pressed ? Appearance.padding.large : internalChecked ? Appearance.padding.smaller : 0)
        radius: stateLayer.pressed ? Appearance.rounding.small / 2 : internalChecked ? Appearance.rounding.small : Appearance.rounding.normal
        inactiveColour: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
        toggle: true
        radiusAnim.duration: Appearance.anim.durations.expressiveFastSpatial
        radiusAnim.easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial

        Behavior on Layout.preferredWidth {
            Anim {
                duration: Appearance.anim.durations.expressiveFastSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
            }
        }
    }
}
