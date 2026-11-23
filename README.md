# Phone Control Lite — Embedded Live Screens & Broadcast

A Windows launcher for managing up to 30 Android phones over USB. Live scrcpy video is hosted inside each phone card in the Phone Control Lite dashboard, so an individual phone can be controlled by clicking or dragging directly on its embedded screen. It does not open a separate desktop mosaic window.

- Landing page: `index.html`
- Windows ZIP: `downloads/PhoneControlLite-Windows-DashboardLive.zip`
- Launcher: `PhoneControlLite.ps1` and `Start-PhoneControlLite.bat`

## Use

Extract the ZIP and run `Start-PhoneControlLite.bat`. Choose **Unduh / Perbarui** once to download the official Windows scrcpy package (which includes ADB). Enable USB debugging on each Android phone, connect data-capable USB cables, approve the debugging prompt on each phone, and click **Muat ulang HP**.

Optionally check device boxes to restrict which phones open. If none are selected, **Tampilkan layar LIVE di sini** opens all ready devices, up to 30. The screen cards resize to fit the dashboard; 20 devices are laid out in roughly 5 columns by 4 rows. Click or drag within a live card to control that phone. Use **Tutup layar LIVE** to stop the streams and return to snapshot previews.

For broadcast tap/swipe, check target phones and enable **Broadcast tap/swipe ke HP terpilih**. While broadcast is active, the app temporarily shows ADB snapshots instead of embedded live video so the same normalized click or swipe can be sent to every checked device. Turn broadcast off to restore the embedded live screens. Back, Home, and ASCII text also follow the active or broadcast selection.

## Stream and limitations

Each live stream defaults to a maximum video side of 480 pixels, 8 fps, 1 Mbps, and no audio. This is a low-resource starting point, not a performance guarantee. Smoothness depends on the phones' encoders, PC CPU/GPU, USB topology, cables, and simultaneous stream count. All 30 screens fit into one dashboard, but each card becomes small on a single monitor. When live streams are closed or broadcast mode is active, the dashboard uses periodic ADB snapshots, which may be delayed.

Windows 10/11 64-bit and PowerShell are required. USB debugging must be authorized on each phone; the app does not bypass Android locks or security prompts.

Phone Control Lite downloads scrcpy/ADB for Windows x64 from the official Genymobile release. scrcpy is a separate Apache-2.0 project; Phone Control Lite is not an official Genymobile product. See [scrcpy](https://github.com/Genymobile/scrcpy).
