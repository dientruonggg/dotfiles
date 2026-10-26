pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    required property ScreenState screenState
    required property real cpuUsage
    required property string cpuPercentStr

    readonly property string timeStrWithSeconds: {
        return Time.format(GlobalConfig.services.useTwelveHourClock ? "hh:mm:ss A" : "hh:mm:ss");
    }

    implicitWidth: contentLayout.implicitWidth + 22
    implicitHeight: 26

    radius: Tokens.rounding.full
    color: Qt.alpha(Colours.tPalette.m3surfaceContainerHigh, 0.75)
    border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.35)
    border.width: 1

    StateLayer {
        id: stateLayer
        anchors.fill: parent
        radius: parent.radius
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.screenState)
                root.screenState.dashboard = !root.screenState.dashboard;
        }
    }

    RowLayout {
        id: contentLayout
        anchors.centerIn: parent
        spacing: 7

        // Clock text with seconds (reveals date on hover)
        StyledText {
            id: timeText
            Layout.alignment: Qt.AlignVCenter
            text: stateLayer.containsMouse ? Time.format("ddd, d MMM") : root.timeStrWithSeconds
            font: Tokens.font.body.builders.small.weight(Font.DemiBold).scale(1.05).build()
            color: Colours.palette.m3onSurface
        }

        // Small divider dot
        Rectangle {
            implicitWidth: 1
            implicitHeight: 12
            color: Qt.alpha(Colours.palette.m3outlineVariant, 0.5)
            Layout.alignment: Qt.AlignVCenter
        }

        // CPU Badge
        StyledText {
            id: cpuText
            Layout.alignment: Qt.AlignVCenter
            text: root.cpuPercentStr
            font: Tokens.font.body.builders.small.weight(Font.Bold).scale(0.9).build()
            color: root.cpuUsage > 0.75 ? Colours.palette.m3error : (root.cpuUsage > 0.4 ? Colours.palette.m3tertiary : Colours.palette.m3primary)

            Behavior on color {
                CAnim {}
            }
        }
    }
}
