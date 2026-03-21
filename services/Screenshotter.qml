pragma Singleton

import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string screenshotsDir: Paths.recsdir
    readonly property string timestampFormat: "yyyyMMdd_HHmmss"

    function nextPath(): string {
        const timestamp = Qt.formatDateTime(new Date(), timestampFormat);
        return `${screenshotsDir}/screenshot_${timestamp}.png`;
    }

    function screenshotFullscreen(savePath = ""): void {
        const path = savePath || nextPath();

        ensureDirExists(screenshotsDir);
        Quickshell.execDetached(["sh", "-c", `grim "${path}"`]);
    }

    function screenshotRegion(savePath = ""): void {
        const path = savePath || nextPath();

        ensureDirExists(screenshotsDir);
        Quickshell.execDetached(["sh", "-c", `grim -g "$(slurp)" "${path}"`]);
    }

    function ensureDirExists(dir: string): void {
        Quickshell.execDetached(["mkdir", "-p", dir]);
    }
}
