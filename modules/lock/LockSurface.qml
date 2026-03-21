pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import qs.utils
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects

WlSessionLockSurface {
    id: root

    required property WlSessionLock lock
    required property Pam pam

    readonly property alias unlocking: unlockAnim.running
    readonly property bool blurOnly: Strings.testRegexList(Config.lock.excludedScreens, root.screen.name)

    color: "transparent"

    Connections {
        function onUnlock(): void {
            if (root.blurOnly)
                root.lock.locked = false;
            else
                unlockAnim.start();
        }

        target: root.lock
    }

    SequentialAnimation {
        id: unlockAnim

        ParallelAnimation {
            Anim {
                target: lockContent
                properties: "implicitWidth,implicitHeight"
                to: lockContent.size
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
            Anim {
                target: lockBg
                property: "radius"
                to: lockContent.radius
            }
            Anim {
                target: content
                property: "scale"
                to: 0
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
            Anim {
                target: content
                property: "opacity"
                to: 0
                duration: Appearance.anim.durations.small
            }
            Anim {
                target: lockIcon
                property: "opacity"
                to: 1
                duration: Appearance.anim.durations.large
            }
            Anim {
                target: background
                property: "opacity"
                to: 0
                duration: Appearance.anim.durations.large
            }
            SequentialAnimation {
                PauseAnimation {
                    duration: Appearance.anim.durations.small
                }
                Anim {
                    target: lockContent
                    property: "opacity"
                    to: 0
                }
            }
        }
        PropertyAction {
            target: root.lock
            property: "locked"
            value: false
        }
    }

    ParallelAnimation {
        id: initAnim

        running: !root.blurOnly

        Anim {
            target: background
            property: "opacity"
            to: 1
            duration: Appearance.anim.durations.large
        }
        SequentialAnimation {
            ParallelAnimation {
                Anim {
                    target: lockContent
                    property: "scale"
                    to: 1
                    duration: Appearance.anim.durations.expressiveFastSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
                }
                Anim {
                    target: lockContent
                    property: "rotation"
                    to: 360
                    duration: Appearance.anim.durations.expressiveFastSpatial
                    easing.bezierCurve: Appearance.anim.curves.standardAccel
                }
            }
            ParallelAnimation {
                Anim {
                    target: lockIcon
                    property: "rotation"
                    to: 360
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
                Anim {
                    target: lockIcon
                    property: "opacity"
                    to: 0
                }
                Anim {
                    target: content
                    property: "opacity"
                    to: 1
                }
                Anim {
                    target: content
                    property: "scale"
                    to: 1
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
                Anim {
                    target: lockBg
                    property: "radius"
                    to: Appearance.rounding.large * 1.5
                }
                Anim {
                    target: lockContent
                    property: "implicitWidth"
                    to: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult * Config.lock.sizes.ratio
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
                Anim {
                    target: lockContent
                    property: "implicitHeight"
                    to: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }
        }
    }

    ScreencopyView {
        id: background

        anchors.fill: parent
        captureSource: root.screen
        opacity: root.blurOnly ? 1 : 0

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1
            blurMax: 64
            blurMultiplier: 1
        }
    }

    Item {
        id: lockContent

        visible: !root.blurOnly

        readonly property int size: lockIcon.implicitHeight + Appearance.padding.large * 4
        readonly property int radius: size / 4 * Appearance.rounding.scale

        anchors.centerIn: parent
        implicitWidth: size
        implicitHeight: size

        rotation: 180
        scale: 0

        StyledRect {
            id: lockBg

            anchors.fill: parent
            color: Colours.palette.m3surface
            radius: parent.radius
            opacity: Colours.transparency.enabled ? Colours.transparency.base : 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                blurMax: 15
                shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.7)
            }
        }

        MaterialIcon {
            id: lockIcon

            anchors.centerIn: parent
            text: "lock"
            font.pointSize: Appearance.font.size.extraLarge * 4
            font.bold: true
            rotation: 180
        }

        Content {
            id: content

            anchors.centerIn: parent
            width: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult * Config.lock.sizes.ratio - Appearance.padding.large * 2
            height: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult - Appearance.padding.large * 2

            lock: root
            opacity: 0
            scale: 0
        }
    }
}
