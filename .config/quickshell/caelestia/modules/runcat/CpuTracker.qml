pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property real cpuUsage: 0.0
    readonly property string cpuPercentStr: Math.round(cpuUsage * 100) + "%"

    // Frame interval: ~220ms at 0% load down to 25ms at 100% load
    readonly property int catInterval: Math.max(25, Math.min(220, Math.round(220 / (1 + cpuUsage * 7.8))))

    // Ball bounce duration: ~600ms at 0% load down to 220ms at 100% load
    readonly property int ballSpeed: Math.max(220, Math.min(600, Math.round(600 / (1 + cpuUsage * 2.2))))

    property real prevIdle: 0
    property real prevTotal: 0

    Timer {
        id: pollTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statFile.reload()
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        onLoaded: {
            const str = text();
            const firstLine = str.split("\n")[0];
            if (!firstLine || !firstLine.startsWith("cpu "))
                return;

            const parts = firstLine.trim().split(/\s+/).slice(1).map(Number);
            if (parts.length < 4)
                return;

            const idle = parts[3] + (parts[4] || 0);
            const total = parts.reduce((acc, val) => acc + val, 0);

            if (root.prevTotal > 0 && total > root.prevTotal) {
                const deltaIdle = idle - root.prevIdle;
                const deltaTotal = total - root.prevTotal;
                if (deltaTotal > 0) {
                    const rawUsage = 1.0 - (deltaIdle / deltaTotal);
                    root.cpuUsage = Math.max(0.0, Math.min(1.0, rawUsage));
                }
            }

            root.prevIdle = idle;
            root.prevTotal = total;
        }
    }
}
