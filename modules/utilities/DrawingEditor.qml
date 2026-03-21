pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import Caelestia
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

MouseArea {
    id: root

    required property ShellScreen screen
    required property string screenshotPath
    required property var onClose

    property color brushColor: Colours.palette.m3primary
    property real brushSize: 4
    property int tool: DrawingTool.Pen
    property bool drawing: false
    property point lastPos: Qt.point(0, 0)

    enum Tool {
        Pen,
        Eraser,
        Arrow,
        Rectangle,
        Circle
    }

    anchors.fill: parent
    opacity: 0
    hoverEnabled: true

    Component.onCompleted: opacity = 1

    // Background overlay
    StyledRect {
        anchors.fill: parent
        color: Colours.palette.m3scrim
        opacity: 0.8
    }

    // Screenshot display area
    StyledRect {
        id: screenshotArea

        anchors.centerIn: parent
        width: Math.min(parent.width - 200, sourceImage.implicitWidth)
        height: Math.min(parent.height - 150, sourceImage.implicitHeight)
        radius: Appearance.rounding.normal
        color: Colours.palette.m3surfaceContainerHigh
        clip: true

        Image {
            id: sourceImage

            anchors.fill: parent
            source: root.screenshotPath
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            onStatusChanged: {
                if (status === Image.Ready) {
                    const imgWidth = Math.min(root.width - 200, implicitWidth);
                    const imgHeight = Math.min(root.height - 150, implicitHeight);
                    screenshotArea.width = imgWidth;
                    screenshotArea.height = imgHeight;
                    drawingCanvas.width = imgWidth;
                    drawingCanvas.height = imgHeight;
                }
            }
        }

        // Drawing canvas overlay
        Canvas {
            id: drawingCanvas

            anchors.fill: parent

            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                // Draw all stored paths
                for (const path of pathStorage) {
                    drawPath(ctx, path);
                }

                // Draw current path
                if (currentPath.points.length > 0) {
                    drawPath(ctx, currentPath);
                }
            }

            function drawPath(ctx, pathData) {
                if (pathData.points.length < 2) return;

                ctx.beginPath();
                ctx.strokeStyle = pathData.color;
                ctx.lineWidth = pathData.size;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";

                if (pathData.tool === DrawingTool.Eraser) {
                    ctx.globalCompositeOperation = "destination-out";
                }

                ctx.moveTo(pathData.points[0].x, pathData.points[0].y);
                for (let i = 1; i < pathData.points.length; i++) {
                    const p0 = pathData.points[i - 1];
                    const p1 = pathData.points[i];
                    const midX = (p0.x + p1.x) / 2;
                    const midY = (p0.y + p1.y) / 2;
                    ctx.quadraticCurveTo(p0.x, p0.y, midX, midY);
                }
                ctx.stroke();

                ctx.globalCompositeOperation = "source-over";
            }

            property var pathStorage: []
            property var currentPath: ({points: [], color: root.brushColor, size: root.brushSize, tool: root.tool})

            function startNewPath() {
                currentPath = {
                    points: [],
                    color: root.brushColor,
                    size: root.brushSize,
                    tool: root.tool
                };
            }

            function finishPath() {
                if (currentPath.points.length > 0) {
                    pathStorage.push({...currentPath, points: [...currentPath.points]});
                    currentPath = {points: [], color: root.brushColor, size: root.brushSize, tool: root.tool};
                }
            }

            function clearAll() {
                pathStorage = [];
                currentPath = {points: [], color: root.brushColor, size: root.brushSize, tool: root.tool};
                requestPaint();
            }

            function undo() {
                if (pathStorage.length > 0) {
                    pathStorage.pop();
                    requestPaint();
                }
            }
        }
    }

    // Mouse handling for drawing
    onPressed: event => {
        const pos = drawingCanvas.mapFromItem(root, event.x, event.y);
        drawingCanvas.currentPath.points = [pos];
        drawing = true;
        drawingCanvas.requestPaint();
    }

    onPositionChanged: event => {
        if (!drawing) return;

        const pos = drawingCanvas.mapFromItem(root, event.x, event.y);
        drawingCanvas.currentPath.points.push(pos);
        drawingCanvas.requestPaint();
    }

    onReleased: {
        if (drawing) {
            drawingCanvas.finishPath();
            drawing = false;
            drawingCanvas.requestPaint();
        }
    }

    // Toolbar
    StyledRect {
        id: toolbar

        anchors.top: screenshotArea.top
        anchors.right: screenshotArea.left
        anchors.rightMargin: Appearance.padding.large
        anchors.topMargin: 20
        width: 56
        radius: Appearance.rounding.normal
        color: Colours.palette.m3surfaceContainerHighest

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.small
            spacing: Appearance.spacing.small

            // Pen tool
            IconButton {
                icon: "edit"
                type: IconButton.Tonal
                toggle: true
                checked: root.tool === DrawingTool.Pen
                onClicked: root.tool = DrawingTool.Pen
            }

            // Eraser tool
            IconButton {
                icon: "auto_fix_normal"
                type: IconButton.Tonal
                toggle: true
                checked: root.tool === DrawingTool.Eraser
                onClicked: root.tool = DrawingTool.Eraser
            }

            // Separator
            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colours.palette.m3outline
                Layout.topMargin: Appearance.spacing.small
                Layout.bottomMargin: Appearance.spacing.small
            }

            // Color picker buttons
            Repeater {
                model: [
                    Colours.palette.m3primary,
                    Colours.palette.m3error,
                    Colours.palette.m3tertiary,
                    Colours.palette.m3inverseSurface,
                    "#FFFFFF"
                ]

                StyledRect {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: Appearance.rounding.full
                    color: modelData

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.brushColor = modelData
                    }

                    // Selection indicator
                    StyledRect {
                        anchors.fill: parent
                        radius: Appearance.rounding.full
                        color: "transparent"
                        border.width: root.brushColor === modelData ? 3 : 0
                        border.color: Colours.palette.m3onSurface
                    }
                }
            }

            // Brush size
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Undo button
            IconButton {
                icon: "undo"
                type: IconButton.Tonal
                onClicked: drawingCanvas.undo()
            }

            // Clear button
            IconButton {
                icon: "delete_sweep"
                type: IconButton.Tonal
                onClicked: drawingCanvas.clearAll()
            }
        }
    }

    // Bottom action bar
    StyledRect {
        anchors.bottom: screenshotArea.bottom
        anchors.horizontalCenter: screenshotArea.horizontalCenter
        anchors.bottomMargin: -Appearance.padding.large
        width: actionLayout.implicitWidth + Appearance.padding.large * 2
        height: actionLayout.implicitHeight + Appearance.padding.normal * 2
        radius: Appearance.rounding.normal
        color: Colours.palette.m3surfaceContainerHighest

        RowLayout {
            id: actionLayout

            anchors.centerIn: parent
            spacing: Appearance.spacing.normal

            TextButton {
                text: qsTr("Cancel")
                type: TextButton.Text
                onClicked: {
                    root.opacity = 0;
                    Qt.callLater(root.onClose, "");
                }
            }

            TextButton {
                text: qsTr("Save")
                onClicked: saveScreenshot()
            }

            TextButton {
                text: qsTr("Save As...")
                type: TextButton.Text
                onClicked: saveScreenshotAs()
            }
        }
    }

    // Keyboard shortcuts
    focus: true
    Keys.onEscapePressed: {
        root.opacity = 0;
        Qt.callLater(root.onClose, "");
    }
    Keys.onZPressed: {
        if (event.modifiers & Qt.ControlModifier) {
            drawingCanvas.undo();
            event.accepted = true;
        }
    }

    Behavior on opacity {
        Anim {
            duration: Appearance.anim.durations.large
        }
    }

    function saveScreenshot(): void {
        const mergedImage = mergeImages();
        const timestamp = Qt.formatDateTime(new Date(), Screenshotter.timestampFormat);
        const filename = `screenshot_${timestamp}.png`;
        const path = `${Screenshotter.screenshotsDir}/${filename}`;

        Screenshotter.ensureDirExists(Screenshotter.screenshotsDir);
        CUtils.saveItem(mergedImage, Qt.resolvedUrl(path), savedPath => {
            Quickshell.execDetached(["notify-send", "-a", "caelestia", "-i", savedPath, "Screenshot saved", "Saved to " + savedPath]);
            root.opacity = 0;
            Qt.callLater(root.onClose, savedPath);
        });
    }

    function saveScreenshotAs(): void {
        // For now, just save - could be extended with file dialog
        saveScreenshot();
    }

    function mergeImages(): Item {
        // Returns the combined item to capture
        return screenshotArea;
    }

    function loadExistingScreenshot(path: string): void {
        // Could be used to edit existing screenshots
    }
}
