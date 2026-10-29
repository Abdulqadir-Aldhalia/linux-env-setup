// Give windows their title bars back after Krohnkite (noTileBorder) is turned off
for (const w of workspace.windowList()) {
    if (w.normalWindow && !w.specialWindow) w.noBorder = false;
}
