Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:ToolDir = Join-Path $script:Root 'scrcpy'
$script:ScrcpyExe = Join-Path $script:ToolDir 'scrcpy.exe'

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Phone Control Lite'
$form.Size = New-Object System.Drawing.Size(560,430)
$form.StartPosition = 'CenterScreen'
$form.MinimumSize = New-Object System.Drawing.Size(560,430)
$form.BackColor = [System.Drawing.Color]::FromArgb(17,24,39)
$form.ForeColor = [System.Drawing.Color]::FromArgb(229,231,235)
$form.Font = New-Object System.Drawing.Font('Segoe UI',10)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'PHONE CONTROL LITE'
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold',18)
$title.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
$title.Location = New-Object System.Drawing.Point(24,20)
$title.Size = New-Object System.Drawing.Size(480,38)
$form.Controls.Add($title)

$desc = New-Object System.Windows.Forms.Label
$desc.Text = 'Hubungkan Android ke PC lewat USB untuk melihat dan mengontrol layar.'
$desc.Location = New-Object System.Drawing.Point(26,66)
$desc.Size = New-Object System.Drawing.Size(495,32)
$form.Controls.Add($desc)

$status = New-Object System.Windows.Forms.Label
$status.Text = 'Status: scrcpy belum dipasang di folder aplikasi.'
$status.Location = New-Object System.Drawing.Point(26,105)
$status.Size = New-Object System.Drawing.Size(500,28)
$status.ForeColor = [System.Drawing.Color]::FromArgb(209,213,219)
$form.Controls.Add($status)

$log = New-Object System.Windows.Forms.TextBox
$log.Location = New-Object System.Drawing.Point(26,142)
$log.Size = New-Object System.Drawing.Size(492,122)
$log.Multiline = $true
$log.ReadOnly = $true
$log.ScrollBars = 'Vertical'
$log.BackColor = [System.Drawing.Color]::FromArgb(31,41,55)
$log.ForeColor = [System.Drawing.Color]::FromArgb(229,231,235)
$log.BorderStyle = 'FixedSingle'
$log.Text = "Langkah singkat:`r`n1. Aktifkan USB debugging pada Android.`r`n2. Sambungkan kabel USB dan buka kunci HP.`r`n3. Setujui dialog 'Allow USB debugging' di HP.`r`n4. Tekan Periksa koneksi, lalu Mulai kontrol."
$form.Controls.Add($log)

function New-ActionButton($text, $x, $width) {
  $b = New-Object System.Windows.Forms.Button
  $b.Text = $text
  $b.Location = New-Object System.Drawing.Point($x,280)
  $b.Size = New-Object System.Drawing.Size($width,42)
  $b.FlatStyle = 'Flat'
  $b.FlatAppearance.BorderSize = 0
  $b.BackColor = [System.Drawing.Color]::FromArgb(34,197,154)
  $b.ForeColor = [System.Drawing.Color]::FromArgb(10,20,25)
  $b.Font = New-Object System.Drawing.Font('Segoe UI Semibold',10)
  $form.Controls.Add($b)
  return $b
}
$download = New-ActionButton 'Unduh / Perbarui' 26 150
$check = New-ActionButton 'Periksa koneksi' 190 150
$start = New-ActionButton 'Mulai kontrol' 354 164

$note = New-Object System.Windows.Forms.Label
$note.Text = 'Hanya Android. Perlu USB debugging dan persetujuan awal di layar HP. Gunakan hanya pada perangkat milik Anda.'
$note.Location = New-Object System.Drawing.Point(27,340)
$note.Size = New-Object System.Drawing.Size(490,40)
$note.ForeColor = [System.Drawing.Color]::FromArgb(156,163,175)
$note.Font = New-Object System.Drawing.Font('Segoe UI',8.5)
$form.Controls.Add($note)

function Set-ReadyState {
  if (Test-Path $script:ScrcpyExe) {
    $status.Text = 'Status: scrcpy siap.'
    $status.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
  } else {
    $status.Text = 'Status: unduh scrcpy resmi terlebih dahulu.'
    $status.ForeColor = [System.Drawing.Color]::FromArgb(251,191,36)
  }
}

$download.Add_Click({
  $download.Enabled = $false
  $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
  $status.Text = 'Mengambil rilis resmi scrcpy dari GitHub...'
  $form.Refresh()
  try {
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/Genymobile/scrcpy/releases/latest' -Headers @{'User-Agent'='PhoneControlLite'}
    $asset = $release.assets | Where-Object { $_.name -match '^scrcpy-win64-v.*\.zip$' } | Select-Object -First 1
    if (-not $asset) { throw 'Arsip Windows x64 tidak ditemukan pada rilis resmi.' }
    $zipPath = Join-Path $env:TEMP $asset.name
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -Headers @{'User-Agent'='PhoneControlLite'}
    $tmp = Join-Path $env:TEMP ('scrcpy-lite-' + [guid]::NewGuid().ToString('N'))
    Expand-Archive -LiteralPath $zipPath -DestinationPath $tmp -Force
    $exe = Get-ChildItem -Path $tmp -Filter 'scrcpy.exe' -Recurse | Select-Object -First 1
    if (-not $exe) { throw 'scrcpy.exe tidak ditemukan di arsip.' }
    if (Test-Path $script:ToolDir) { Remove-Item $script:ToolDir -Recurse -Force }
    New-Item -ItemType Directory -Path $script:ToolDir -Force | Out-Null
    Copy-Item -Path (Join-Path $exe.Directory.FullName '*') -Destination $script:ToolDir -Recurse -Force
    Remove-Item $tmp -Recurse -Force
    Remove-Item $zipPath -Force
    $log.Text = "scrcpy resmi berhasil disiapkan.`r`nVersi: $($release.tag_name)`r`nSekarang sambungkan HP dan tekan Periksa koneksi."
    Set-ReadyState
  } catch {
    $status.Text = 'Gagal menyiapkan scrcpy.'
    [System.Windows.Forms.MessageBox]::Show("Tidak bisa mengunduh scrcpy resmi.`r`n$($_.Exception.Message)`r`n`r`nPeriksa internet lalu coba lagi.",'Phone Control Lite','OK','Error') | Out-Null
  } finally {
    $download.Enabled = $true
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
  }
})

$check.Add_Click({
  if (-not (Test-Path $script:ScrcpyExe)) {
    [System.Windows.Forms.MessageBox]::Show('Tekan Unduh / Perbarui terlebih dahulu.','Phone Control Lite') | Out-Null
    return
  }
  try {
    $adb = Join-Path $script:ToolDir 'adb.exe'
    $out = & $adb devices 2>&1 | Out-String
    $log.Text = "Hasil adb devices:`r`n$out`r`nJika status 'unauthorized', buka kunci HP dan setujui izin debugging. Jika daftar kosong, coba kabel data lain atau port USB lain."
    if ($out -match '\sdevice\s') {
      $status.Text = 'Status: perangkat tersambung.'
      $status.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
    } elseif ($out -match 'unauthorized') {
      $status.Text = 'Status: izinkan koneksi pada HP.'
      $status.ForeColor = [System.Drawing.Color]::FromArgb(251,191,36)
    } else {
      $status.Text = 'Status: HP belum terdeteksi.'
      $status.ForeColor = [System.Drawing.Color]::FromArgb(251,191,36)
    }
  } catch {
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,'Gagal memeriksa koneksi') | Out-Null
  }
})

$start.Add_Click({
  if (-not (Test-Path $script:ScrcpyExe)) {
    [System.Windows.Forms.MessageBox]::Show('Tekan Unduh / Perbarui terlebih dahulu.','Phone Control Lite') | Out-Null
    return
  }
  $adb = Join-Path $script:ToolDir 'adb.exe'
  $devices = & $adb devices 2>&1 | Out-String
  if ($devices -notmatch '\sdevice\s') {
    [System.Windows.Forms.MessageBox]::Show("HP belum terotorisasi atau belum terdeteksi.`r`nPeriksa koneksi dan setujui dialog di HP.`r`n`r`n$devices",'Belum tersambung','OK','Warning') | Out-Null
    return
  }
  Start-Process -FilePath $script:ScrcpyExe -WorkingDirectory $script:ToolDir
})
Set-ReadyState
[void]$form.ShowDialog()
