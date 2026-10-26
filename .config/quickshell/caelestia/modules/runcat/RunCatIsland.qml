pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Caelestia
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services

Variants {
    id: root

    model: Screens.screens

    StyledWindow {
        id: win

        required property ShellScreen modelData

        screen: modelData
        name: "runcat-island"

        readonly property ScreenState screenState: ShellState.forScreen(screen)
        readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
        readonly property bool hasSpecialWorkspace: (monitor?.lastIpcObject.specialWorkspace?.name.length ?? 0) > 0
        readonly property bool hasFullscreenOnNormalWs: monitor?.activeWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen > 1) ?? false
        readonly property bool hasFullscreen: {
            if (hasSpecialWorkspace) {
                const specialName = monitor?.lastIpcObject.specialWorkspace?.name;
                if (!specialName)
                    return false;
                const specialWs = Hypr.workspaces.values.find(ws => ws.name === specialName);
                return specialWs?.toplevels.values.some(t => t.lastIpcObject.fullscreen > 1) ?? false;
            }
            return hasFullscreenOnNormalWs;
        }

        // Floating top layer
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top

        // Anchored to bottom right corner
        anchors.bottom: true
        anchors.right: true
        color: "transparent"

        // Hide when fullscreen or when notification popups / toasts / sidebar / utilities appear
        readonly property bool shouldHide: hasFullscreen
            || Notifs.popups.length > 0
            || (Toaster.toasts?.some(t => !t.closed) ?? false)
            || (screenState?.sidebar ?? false)
            || (screenState?.utilities ?? false)

        visible: !hasFullscreen

        implicitWidth: island.implicitWidth + 28
        implicitHeight: island.implicitHeight + 28

        Region {
            id: emptyRegion
        }

        Region {
            id: activeRegion
            x: island.x
            y: island.y
            width: island.width
            height: island.height
        }

        mask: win.shouldHide ? emptyRegion : activeRegion

        CpuTracker {
            id: cpuTracker
        }

        // Notification popup style container
        Rectangle {
            id: island
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 14
            anchors.rightMargin: 14

            implicitWidth: contentRow.implicitWidth + 24
            implicitHeight: 40

            opacity: win.shouldHide ? 0.0 : 1.0

            Behavior on opacity {
                Anim {
                    type: Anim.DefaultEffects
                }
            }

            radius: Tokens.rounding.large
            color: "transparent"
            border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.45)
            border.width: 1

            // Drop shadow
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.45)
                shadowBlur: 0.5
                shadowVerticalOffset: 3
                blurMax: 16
            }

            // Notification popup background styling (with wallpaper crop and darkened tint)
            StyledClippingRect {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"

                Image {
                    anchors.fill: parent
                    source: "file:///home/bim/.local/state/caelestia/notif_bg"
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 360
                    sourceSize.height: 100
                    cache: true
                    asynchronous: false
                    opacity: 0.55
                }

                Rectangle {
                    anchors.fill: parent
                    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.88)
                }
            }

            RowLayout {
                id: contentRow
                anchors.centerIn: parent
                spacing: 10

                // Left side: Running Cat chasing Bouncing Ball
                Item {
                    id: runnerArea
                    implicitWidth: cat.implicitWidth + ball.implicitWidth + 4
                    implicitHeight: 26
                    Layout.alignment: Qt.AlignVCenter

                    StateLayer {
                        id: catStateLayer
                        anchors.fill: parent
                        radius: Tokens.rounding.full
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            Hypr.dispatch(Hypr.usingLua ? 'hl.dsp.workspace.toggle_special("sysmon")' : 'togglespecialworkspace sysmon');
                        }
                    }

                    RunCat {
                        id: cat
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        frameInterval: cpuTracker.catInterval
                        cpuUsage: cpuTracker.cpuUsage
                    }

                    Ball {
                        id: ball
                        anchors.left: cat.right
                        anchors.leftMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                        animSpeed: cpuTracker.ballSpeed
                    }
                }

                // Vertical separator
                Rectangle {
                    implicitWidth: 1
                    implicitHeight: 16
                    color: Qt.alpha(Colours.palette.m3outlineVariant, 0.45)
                    Layout.alignment: Qt.AlignVCenter
                }

                // Right side: Clock Box displaying time and CPU badge
                ClockBox {
                    id: clockBox
                    Layout.alignment: Qt.AlignVCenter
                    screenState: win.screenState
                    cpuUsage: cpuTracker.cpuUsage
                    cpuPercentStr: cpuTracker.cpuPercentStr
                }
            }
        }
    }
}
