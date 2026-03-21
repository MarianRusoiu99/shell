pragma Singleton

import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string screenshotsDir: `${Paths.pictures}/Screenshots`
    readonly property string timestampFormat: "yyyyMMdd_HHmmss"

    function screenshotFullscreen(savePath = ""): void {
        const timestamp = Qt.formatDateTime(new Date(), timestampFormat);
        const filename = `screenshot_${timestamp}.png`;
        const path = savePath || `${screenshotsDir}/${filename}`;

        ensureDirExists(screenshotsDir);
        execScreenshot(["-f", path]);
    }

    function screenshotRegion(savePath = ""): void {
        const timestamp = Qt.formatDateTime(new Date(), timestampFormat);
        const filename = `screenshot_${timestamp}.png`;
        const path = savePath || `${screenshotsDir}/${filename}`;

        ensureDirExists(screenshotsDir);
        execScreenshot(["-r", path]);
    }

    function screenshotFullscreenClip(): void {
        execScreenshot(["-fc"]);
    }

    function screenshotRegionClip(): void {
        execScreenshot(["-rc"]);
    }

    function ensureDirExists(dir: string): void {
        Quickshell.execDetached(["mkdir", "-p", dir]);
    }

    function execScreenshot(args: list<string>): void {
        Quickshell.execDetached(["sh", "-c", `grim ${args.join(" ")}`]);
    }
}
