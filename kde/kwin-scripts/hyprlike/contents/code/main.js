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

// Krohnkite skips maximized windows, so apps that restore themselves maximized never tile.
// Un-maximize on open only; SUPER+F still maximizes afterwards.
workspace.windowAdded.connect(win => {
    if (win.normalWindow && !win.specialWindow && win.maximizable && win.maximizeMode !== 0) {
        win.setMaximize(false, false);
    }
});

// SUPER+ALT+T / SUPER+SHIFT+T: tiling on/off. Runs ~/.config/kde-hypr/toggle-tiling.sh via its launcher.
function toggleTiling() {
    callDBus("org.kde.kglobalaccel", "/component/hypr_tiling_desktop", "org.kde.kglobalaccel.Component",
        "invokeShortcut", "_launch");
}
registerShortcut("Hyprlike Toggle Tiling", "Hyprlike: Toggle tiling on/off", "Meta+Alt+T", toggleTiling);
registerShortcut("Hyprlike Toggle Tiling Alt", "Hyprlike: Toggle tiling on/off (alternate key)", "Meta+Shift+T", toggleTiling);
