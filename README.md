# Phone Control Lite — Live Mosaic & Broadcast

A Windows launcher for managing up to 30 Android phones over USB. The dashboard preview remains periodic ADB snapshots. For live video, the app starts one official scrcpy window per ready phone and tiles the borderless windows across the primary monitor. Each scrcpy window accepts individual mouse control.

- Landing page: `index.html`
- Windows ZIP: `downloads/PhoneControlLite-Windows.zip`
- Launcher: `PhoneControlLite.ps1` and `Start-PhoneControlLite.bat`

## Use

Extract the ZIP and run `Start-PhoneControlLite.bat`. Choose **Unduh / Perbarui** once to download the official Windows scrcpy package (which includes ADB). Enable USB debugging on each Android phone, connect data-capable USB cables, approve the debugging prompt on each phone, and click **Muat ulang HP**.

Select device checkboxes before launching the mosaic to open only those checked devices. If none are checked, **Buka mosaik LIVE** opens every ready device, up to 30. The layout is computed automatically: 20 devices use 5 columns by 4 rows; 30 use 6 by 5. Click or drag inside a scrcpy window to control that phone. Use **Tutup mosaik LIVE** in the dashboard to close the launched streams.

To broadcast, check the target phones and enable **Broadcast tap/swipe ke HP terpilih**. Use the dashboard snapshots as the broadcast input surface. The same normalized tap or swipe is sent to all checked devices. Back, Home, and ASCII text also follow the active or broadcast selection.

## Live stream and limitations

Each live stream defaults to a maximum video side of 480 pixels, 8 fps, 1 Mbps, and no audio. This is a low-resource starting point, not a performance guarantee. Smoothness depends on the phones' encoders, PC CPU/GPU, USB topology, cables, and the number of simultaneous devices. Portrait phone images keep their aspect ratio and therefore occupy only part of wider grid cells. The dashboard's own previews remain periodic snapshots, not live video. A multi-phone broadcast can change screens or activate controls on every selected phone; verify the target state before using it.

Windows 10/11 64-bit and PowerShell are required. This is Android-only. USB debugging must be authorized on each phone; the app does not bypass Android locks or security prompts.

Phone Control Lite downloads scrcpy/ADB for Windows x64 from the official Genymobile release. scrcpy is a separate Apache-2.0 project; Phone Control Lite is not an official Genymobile product. See [scrcpy](https://github.com/Genymobile/scrcpy).
