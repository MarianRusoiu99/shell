pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.utils
import qs.services

Singleton {
    id: root

    readonly property alias running: props.running
    readonly property alias paused: props.paused
    readonly property alias elapsed: props.elapsed
    property bool needsStart
    property list<string> startArgs
    property bool needsStop
    property bool needsPause
    readonly property string focusedMonitorName: "screen"  // Use "screen" for whole screen
    readonly property int recordingPid: recordProc.processId
    property string currentRecordingPath: ""

    function start(extraArgs = []): void {
        needsStart = true;
        startArgs = extraArgs;
        checkProc.running = true;
    }

    function stop(): void {
        needsStop = true;
        checkProc.running = true;
    }

    function togglePause(): void {
        needsPause = true;
        checkProc.running = true;
    }

    function ensureDirExists(dir: string): void {
        Quickshell.execDetached(["mkdir", "-p", dir]);
    }

    function generateRecordingPath(): string {
        const timestamp = Qt.formatDateTime(new Date(), "yyyyMMdd_HHmmss");
        return `${Paths.recsdir}/recording_${timestamp}.mp4`;
    }

    function startRecording(args: list<string>): void {
        const outputPath = generateRecordingPath();
        currentRecordingPath = outputPath;
        ensureDirExists(Paths.recsdir);
        let command = ["gpu-screen-recorder", "-w", focusedMonitorName, "-f", "60", "-o", outputPath];
        
        // Check if sound is requested
        if (args.includes("-s") || args.includes("-sr")) {
            command.push("-a", "default_output");
        }
        // Note: region selection ignored for simplicity
        
        recordProc.command = command;
        recordProc.running = true;
        // Notify user
        Quickshell.execDetached(["notify-send", "-a", "caelestia-shell", "-u", "low", "Recording started", `Saving to ${outputPath}`]);
    }

    PersistentProperties {
        id: props

        property bool running: false
        property bool paused: false
        property real elapsed: 0 // Might get too large for int

        reloadableId: "recorder"
    }

    Process {
        id: checkProc

        running: true
        command: ["pidof", "gpu-screen-recorder"]
        onExited: code => {
            props.running = code === 0;

            if (code === 0) {
                if (root.needsStop) {
                    // Send SIGINT to stop recording
                    Quickshell.execDetached(["notify-send", "-a", "caelestia-shell", "-u", "low", "Stopping recording", `Sending SIGINT to PID ${root.recordingPid}`]);
                    if (root.recordingPid > 0) {
                        Quickshell.execDetached(["kill", "-SIGINT", String(root.recordingPid)]);
                    } else {
                        // fallback
                        Quickshell.execDetached(["pkill", "-SIGINT", "-f", "gpu-screen-recorder"]);
                    }
                } else if (root.needsPause) {
                    // Send SIGUSR2 to toggle pause
                    if (root.recordingPid > 0) {
                        Quickshell.execDetached(["kill", "-SIGUSR2", String(root.recordingPid)]);
                    } else {
                        Quickshell.execDetached(["pkill", "-SIGUSR2", "-f", "gpu-screen-recorder"]);
                    }
                    props.paused = !props.paused;
                }
            } else if (root.needsStart) {
                root.startRecording(root.startArgs);
                props.running = true;
                props.paused = false;
                props.elapsed = 0;
            }

            root.needsStart = false;
            root.needsStop = false;
            root.needsPause = false;
        }
    }

    Process {
        id: recordProc

        running: false
        onExited: code => {
            // Recording stopped (normally or due to error)
            props.running = false;
            props.paused = false;
            if (code !== 0) {
                // Show error notification
                const msg = `Recording failed with exit code ${code}.`;
                Quickshell.execDetached(["notify-send", "-a", "caelestia-shell", "-u", "critical", "Recording failed", msg]);
            } else {
                // Normal stop
                Quickshell.execDetached(["notify-send", "-a", "caelestia-shell", "-u", "low", "Recording saved", `Video saved to ${currentRecordingPath}`]);
            }
        }
    }

    Connections {
        function onSecondsChanged(): void {
            props.elapsed++;
        }

        enabled: props.running && !props.paused

        target: Time
    }
}
