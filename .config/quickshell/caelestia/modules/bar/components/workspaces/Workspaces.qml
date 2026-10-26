pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

StyledClippingRect {
    id: root

    required property ShellScreen screen
    required property bool fullscreen

    readonly property bool onSpecial: (GlobalConfig.bar.workspaces.perMonitorWorkspaces ? Hypr.monitorFor(screen) : Hypr.focusedMonitor)?.lastIpcObject.specialWorkspace?.name !== ""
    readonly property int activeWsId: GlobalConfig.bar.workspaces.perMonitorWorkspaces ? (Hypr.monitorFor(screen).activeWorkspace?.id ?? 1) : Hypr.activeWsId

    readonly property var occupied: {
        const occ = {};
        for (const ws of Hypr.workspaces.values)
            occ[ws.id] = ws.lastIpcObject.windows > 0;
        return occ;
    }
    readonly property int groupOffset: Math.floor((activeWsId - 1) / Config.bar.workspaces.shown) * Config.bar.workspaces.shown

    property real blur: onSpecial ? 1 : 0
    property real maxHeight: Infinity

    readonly property alias flickable: flickable

    function scrollBy(delta: real): void {
        if (flickable.interactive) {
            flickable.contentY = Math.max(0, Math.min(flickable.contentY + delta, flickable.contentHeight - flickable.height));
        }
    }

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: Math.min(layout.implicitHeight + Tokens.padding.small, maxHeight)

    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.full

    Item {
        anchors.fill: parent
        scale: root.onSpecial ? 0.8 : 1
        opacity: root.onSpecial ? 0.5 : 1
        visible: !root.fullscreen

        layer.enabled: root.blur > 0
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: root.blur
            blurMax: 32
        }

        Flickable {
            id: flickable

            anchors.fill: parent
            contentWidth: width
            contentHeight: container.height
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height
            clip: true

            function scrollToActive(): void {
                if (contentHeight <= height) {
                    contentY = 0;
                    return;
                }
                let i = root.activeWsId - 1;
                while (i < 0)
                    i += Config.bar.workspaces.shown;
                const currentWsIdx = i % Config.bar.workspaces.shown;
                const item = workspaces.itemAt(currentWsIdx);
                if (item) {
                    const itemCenterY = item.y + item.height / 2 + layout.y;
                    const targetY = itemCenterY - flickable.height / 2;
                    const maxY = flickable.contentHeight - flickable.height;
                    contentY = Math.max(0, Math.min(targetY, maxY));
                }
            }

            Connections {
                target: root
                function onActiveWsIdChanged(): void {
                    flickable.scrollToActive();
                }
                function onGroupOffsetChanged(): void {
                    flickable.scrollToActive();
                }
            }

            onContentHeightChanged: scrollToActive()
            onHeightChanged: scrollToActive()

            Behavior on contentY {
                enabled: !flickable.moving
                Anim {
                    type: Anim.Emphasized
                }
            }

            Item {
                id: container

                width: flickable.width
                height: Math.max(flickable.height, layout.implicitHeight + Tokens.padding.small)

                Loader {
                    asynchronous: true
                    active: Config.bar.workspaces.occupiedBg

                    anchors.fill: layout

                    sourceComponent: OccupiedBg {
                        workspaces: workspaces
                        occupied: root.occupied
                        groupOffset: root.groupOffset
                    }
                }

                ColumnLayout {
                    id: layout

                    anchors.centerIn: parent
                    spacing: Math.floor(Tokens.spacing.extraSmall)

                    Repeater {
                        id: workspaces

                        model: Config.bar.workspaces.shown

                        Workspace {
                            activeWsId: root.activeWsId
                            occupied: root.occupied
                            groupOffset: root.groupOffset
                        }
                    }
                }

                Loader {
                    asynchronous: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    active: Config.bar.workspaces.activeIndicator

                    sourceComponent: ActiveIndicator {
                        activeWsId: root.activeWsId
                        workspaces: workspaces
                        mask: layout
                        fullscreen: root.fullscreen
                    }
                }

                MouseArea {
                    anchors.fill: layout
                    onClicked: event => {
                        const ws = (layout.childAt(event.x, event.y) as Workspace)?.ws;
                        if (!ws)
                            return;
                        if (Hypr.activeWsId !== ws)
                            Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ workspace = "${ws}" })` : `workspace ${ws}`);
                        else
                            Hypr.dispatch(Hypr.usingLua ? 'hl.dsp.workspace.toggle_special("special")' : "togglespecialworkspace special");
                    }
                }
            }
        }

        Behavior on scale {
            Anim {}
        }

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }

    Loader {
        id: specialWs

        asynchronous: true

        anchors.fill: parent
        anchors.margins: Tokens.padding.extraSmall

        active: opacity > 0

        scale: root.onSpecial ? 1 : 0.5
        opacity: root.onSpecial ? 1 : 0

        sourceComponent: SpecialWorkspaces {
            screen: root.screen
        }

        Behavior on scale {
            Anim {}
        }

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }

    Behavior on blur {
        Anim {
            type: Anim.StandardSmall
        }
    }
}
