pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    property int animSpeed: 500

    implicitWidth: 20
    implicitHeight: 24

    property real ballY: 0
    property real ballScaleX: 1.0
    property real ballScaleY: 1.0

    // Ground shadow that breathes with the ball's elevation
    Rectangle {
        id: shadow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        width: 14 * Math.max(0.6, 1.1 - (-root.ballY / 18))
        height: 3
        radius: 1.5
        color: Colours.palette.m3shadow
        opacity: Math.max(0.08, 0.38 * (1 - (-root.ballY / 12)))
    }

    // Ball container for bouncing & squashing
    Item {
        id: jumper
        x: Math.round((parent.width - width) / 2)
        y: parent.height - height - 2 + root.ballY
        width: 14
        height: 14

        transform: Scale {
            origin.x: 7
            origin.y: 14
            xScale: root.ballScaleX
            yScale: root.ballScaleY
        }

        // Rotating body (rolls forward)
        Item {
            id: rotator
            anchors.fill: parent

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: Math.max(250, root.animSpeed * 1.6)
                loops: Animation.Infinite
                running: true
            }

            // Ball base
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Colours.palette.m3tertiary
                clip: true

                // Horizontal accent stripe
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: 2.5
                    radius: 1.25
                    color: Qt.darker(Colours.palette.m3tertiary, 1.25)
                }

                // Vertical accent stripe
                Rectangle {
                    anchors.centerIn: parent
                    width: 2.5
                    height: parent.height
                    radius: 1.25
                    color: Qt.darker(Colours.palette.m3tertiary, 1.25)
                }
            }
        }

        // Specular highlight (stays fixed at top-left for persistent 3D lighting)
        Rectangle {
            x: 2.5
            y: 2
            width: 4
            height: 3
            radius: 1.5
            color: "white"
            opacity: 0.7
        }
    }

    // Continuous bouncing & squash-stretch animation
    SequentialAnimation {
        running: true
        loops: Animation.Infinite

        // Jump upward
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "ballY"
                to: -9
                duration: root.animSpeed * 0.44
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: root
                property: "ballScaleX"
                to: 0.92
                duration: root.animSpeed * 0.2
            }
            NumberAnimation {
                target: root
                property: "ballScaleY"
                to: 1.08
                duration: root.animSpeed * 0.2
            }
        }

        // Fall downward
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "ballY"
                to: 0
                duration: root.animSpeed * 0.44
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: root
                property: "ballScaleX"
                to: 1.0
                duration: root.animSpeed * 0.2
            }
            NumberAnimation {
                target: root
                property: "ballScaleY"
                to: 1.0
                duration: root.animSpeed * 0.2
            }
        }

        // Squash upon floor contact
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "ballScaleX"
                to: 1.28
                duration: root.animSpeed * 0.06
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: root
                property: "ballScaleY"
                to: 0.72
                duration: root.animSpeed * 0.06
                easing.type: Easing.OutQuad
            }
        }

        // Rebound back to spherical shape
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "ballScaleX"
                to: 1.0
                duration: root.animSpeed * 0.06
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: root
                property: "ballScaleY"
                to: 1.0
                duration: root.animSpeed * 0.06
                easing.type: Easing.OutBack
            }
        }
    }
}
