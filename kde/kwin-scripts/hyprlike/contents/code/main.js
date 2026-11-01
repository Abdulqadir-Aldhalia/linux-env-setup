// Hyprland-style desktop movement for KWin (Plasma 6)

function moveWindowTo(index, follow) {
    const win = workspace.activeWindow;
    const desktops = workspace.desktops;
    if (!win || win.specialWindow || index < 0 || index >= desktops.length) return;
    const target = desktops[index];
    win.desktops = [target];
    if (follow) {
        workspace.currentDesktop = target;
        workspace.activeWindow = win;
    }
}

function moveWindowBy(delta, follow) {
    const desktops = workspace.desktops;
    const current = desktops.indexOf(workspace.currentDesktop);
    moveWindowTo((current + delta + desktops.length) % desktops.length, follow);
}

for (let i = 0; i < 10; i++) {
    const n = i + 1;
    const key = n === 10 ? "0" : String(n);
    registerShortcut("Hyprlike Move To Desktop " + n, "Hyprlike: Move window to desktop " + n + " and follow",
        "Meta+Shift+" + key, () => moveWindowTo(i, true));
    registerShortcut("Hyprlike Move To Desktop Silent " + n, "Hyprlike: Move window to desktop " + n + " silently",
        "Meta+Ctrl+" + key, () => moveWindowTo(i, false));
}

registerShortcut("Hyprlike Move Next", "Hyprlike: Move window to next desktop and follow", "Meta+Shift+]", () => moveWindowBy(1, true));
registerShortcut("Hyprlike Move Prev", "Hyprlike: Move window to previous desktop and follow", "Meta+Shift+[", () => moveWindowBy(-1, true));
registerShortcut("Hyprlike Move Next Silent", "Hyprlike: Move window to next desktop silently", "Meta+Ctrl+]", () => moveWindowBy(1, false));
registerShortcut("Hyprlike Move Prev Silent", "Hyprlike: Move window to previous desktop silently", "Meta+Ctrl+[", () => moveWindowBy(-1, false));

// ── Tiling on/off (SUPER+SHIFT+T / SUPER+ALT+T) ─────────────────────────────
// Krohnkite can't be unloaded at runtime: its event handlers keep running until the next
// login and keep re-tiling windows. So instead of unloading it, switch every workspace
// between Krohnkite's floating layout (off) and its tile layout (on). Krohnkite applies a
// layout to the workspace currently shown, so visit each one in turn, then come back.
let tilingOn = true;

function invokeShortcut(name, then) {
    callDBus("org.kde.kglobalaccel", "/component/kwin", "org.kde.kglobalaccel.Component",
        "invokeShortcut", name, then);
}

function setLayoutEverywhere(layoutShortcut) {
    const start = workspace.currentDesktop;
    const desktops = workspace.desktops.slice();
    // no slide animation while flipping through the workspaces
    callDBus("org.kde.KWin", "/Effects", "org.kde.kwin.Effects", "unloadEffect", "slide");
    let i = 0;
    const next = () => {
        if (i < desktops.length) {
            workspace.currentDesktop = desktops[i++];
            invokeShortcut(layoutShortcut, next); // continue once Krohnkite has applied it
            return;
        }
        workspace.currentDesktop = start;
        callDBus("org.kde.KWin", "/Effects", "org.kde.kwin.Effects", "loadEffect", "slide");
    };
    next();
}

function toggleTiling() {
    tilingOn = !tilingOn;
    setLayoutEverywhere(tilingOn ? "KrohnkiteTileLayout" : "KrohnkiteFloatingLayout");
}
registerShortcut("Hyprlike Toggle Tiling", "Hyprlike: Toggle tiling on/off", "Meta+Alt+T", toggleTiling);
registerShortcut("Hyprlike Toggle Tiling Alt", "Hyprlike: Toggle tiling on/off (alternate key)", "Meta+Shift+T", toggleTiling);

// Krohnkite skips maximized windows, so apps that restore themselves maximized never tile.
// While tiling is on, un-maximize windows as they open; SUPER+F still maximizes afterwards.
workspace.windowAdded.connect(win => {
    if (tilingOn && win.normalWindow && !win.specialWindow && win.maximizable && win.maximizeMode !== 0) {
        win.setMaximize(false, false);
    }
});
