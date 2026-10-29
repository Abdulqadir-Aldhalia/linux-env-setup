// Hyprland-style border around the focused window (click-through overlay)
import QtQuick
import org.kde.kwin
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: root

    readonly property int borderWidth: 2
    property var win: null

    function update() {
        const w = root.win;
        if (!w || !w.normalWindow || w.fullScreen || w.minimized || w.specialWindow) {
            frame.visible = false;
            return;
        }
        const g = w.frameGeometry;
        border.width = g.width + borderWidth * 2;
        border.height = g.height + borderWidth * 2;
        frame.visible = true;
        // the dialog ignores its position until it is shown
        frame.x = g.x - borderWidth;
        frame.y = g.y - borderWidth;
    }

    function track(w) {
        if (root.win) {
            root.win.frameGeometryChanged.disconnect(update);
            root.win.fullScreenChanged.disconnect(update);
            root.win.minimizedChanged.disconnect(update);
        }
        root.win = w;
        if (w) {
            w.frameGeometryChanged.connect(update);
            w.fullScreenChanged.connect(update);
            w.minimizedChanged.connect(update);
        }
        update();
    }

    Connections {
        target: Workspace
        function onWindowActivated(w) { root.track(w); }
        function onCurrentDesktopChanged() { root.update(); }
    }

    Component.onCompleted: track(Workspace.activeWindow)

    PlasmaCore.Dialog {
        id: frame
        type: PlasmaCore.Dialog.OnScreenDisplay
        flags: Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput
        location: PlasmaCore.Types.Floating
        backgroundHints: PlasmaCore.Types.NoBackground
        outputOnly: true
        visible: false

        mainItem: Rectangle {
            id: border
            width: 1
            height: 1
            color: "transparent"
            radius: 4
            border.width: root.borderWidth
            border.color: Kirigami.Theme.highlightColor
        }
    }
}
