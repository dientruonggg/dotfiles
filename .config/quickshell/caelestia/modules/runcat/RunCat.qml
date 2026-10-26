pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.effects
import qs.services

Item {
    id: root

    required property int frameInterval
    required property real cpuUsage

    property int frameIndex: 0

    implicitWidth: 38
    implicitHeight: 24

    Timer {
        id: animTimer
        running: true
        repeat: true
        interval: root.frameInterval
        onTriggered: {
            root.frameIndex = (root.frameIndex + 1) % 5;
        }
    }

    Item {
        id: catContainer
        anchors.fill: parent

        // Running gait bobbing
        transform: Translate {
            y: (root.frameIndex === 1 || root.frameIndex === 3) ? -1.5 : 0
        }

        layer.enabled: true
        layer.effect: Colouriser {
            sourceColor: "#bebebe"
            colorizationColor: Colours.palette.m3primary
        }

        Repeater {
            model: 5

            Image {
                required property int index

                anchors.fill: parent
                visible: root.frameIndex === index
                fillMode: Image.PreserveAspectFit
                asynchronous: false
                sourceSize.width: 76
                sourceSize.height: 48
                source: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/runcat/my-running-${index}-symbolic.svg`)
            }
        }
    }
}
