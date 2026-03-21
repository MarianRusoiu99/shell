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
        Quickshell.execDetached(["grim", path]);
    }

    function screenshotRegion(savePath = ""): void {
        const path = savePath || nextPath();

        ensureDirExists(screenshotsDir);
        Quickshell.execDetached(["sh", "-c", `grim -g "$(slurp)" "${path}"`]);
    }

    function screenshotFullscreenDraw(): void {
        const path = nextPath();

        ensureDirExists(screenshotsDir);
        Quickshell.execDetached(["sh", "-c", `grim "${path}" && swappy -f "${path}"`]);
    }

    function screenshotRegionDraw(): void {
        const path = nextPath();

        ensureDirExists(screenshotsDir);
        Quickshell.execDetached(["sh", "-c", `grim -g "$(slurp)" "${path}" && swappy -f "${path}"`]);
    }

    function screenshotFullscreenClip(): void {
        Quickshell.execDetached(["sh", "-c", "grim - | wl-copy --type image/png"]);
    }

    function screenshotRegionClip(): void {
        // For region to clipboard, we need to use slurp first to get the region
        Quickshell.execDetached(["sh", "-c", "slurp | grim -g - - | wl-copy --type image/png"]);
    }

    function ensureDirExists(dir: string): void {
        Quickshell.execDetached(["mkdir", "-p", dir]);
    }
}
