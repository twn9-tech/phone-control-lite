Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:ToolDir = Join-Path $script:Root 'scrcpy'
$script:ScrcpyExe = Join-Path $script:ToolDir 'scrcpy.exe'
$script:MaxDevices = 30

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Phone Control Lite — Multi HP'
$form.Size = New-Object System.Drawing.Size(820,620)
$form.MinimumSize = New-Object System.Drawing.Size(760,560)
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(17,24,39)
$form.ForeColor = [System.Drawing.Color]::FromArgb(229,231,235)
$form.Font = New-Object System.Drawing.Font('Segoe UI',10)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'PHONE CONTROL LITE'
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold',19)
$title.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
$title.Location = New-Object System.Drawing.Point(24,18)
$title.Size = New-Object System.Drawing.Size(500,38)
$form.Controls.Add($title)

$desc = New-Object System.Windows.Forms.Label
$desc.Text = 'Pilih perangkat Android lalu buka kontrol tiap HP di jendela terpisah.'
$desc.Location = New-Object System.Drawing.Point(27,60)
$desc.Size = New-Object System.Drawing.Size(700,28)
$form.Controls.Add($desc)

$status = New-Object System.Windows.Forms.Label
$status.Text = 'Status: siapkan scrcpy terlebih dahulu.'
$status.Location = New-Object System.Drawing.Point(27,95)
$status.Size = New-Object System.Drawing.Size(750,26)
$status.ForeColor = [System.Drawing.Color]::FromArgb(209,213,219)
$form.Controls.Add($status)

$list = New-Object System.Windows.Forms.ListView
$list.Location = New-Object System.Drawing.Point(27,131)
$list.Size = New-Object System.Drawing.Size(750,335)
$list.Anchor = 'Top,Bottom,Left,Right'
$list.View = [System.Windows.Forms.View]::Details
$list.CheckBoxes = $true
$list.FullRowSelect = $true
$list.GridLines = $true
$list.HideSelection = $false
$list.BackColor = [System.Drawing.Color]::FromArgb(31,41,55)
$list.ForeColor = [System.Drawing.Color]::FromArgb(229,231,235)
$list.BorderStyle = 'FixedSingle'
[void]$list.Columns.Add('Perangkat',210)
[void]$list.Columns.Add('Serial / ID ADB',310)
[void]$list.Columns.Add('Status ADB',170)
$form.Controls.Add($list)

$help = New-Object System.Windows.Forms.Label
$help.Text = 'Tip: hanya perangkat berstatus "device" yang bisa dipilih. Jika tertulis "unauthorized", buka kunci HP lalu setujui USB debugging.'
$help.Location = New-Object System.Drawing.Point(28,474)
$help.Size = New-Object System.Drawing.Size(750,35)
$help.Anchor = 'Bottom,Left,Right'
$help.ForeColor = [System.Drawing.Color]::FromArgb(156,163,175)
$help.Font = New-Object System.Drawing.Font('Segoe UI',9)
$form.Controls.Add($help)

function New-Button($text, $x, $y, $width, $primary=$false) {
  $b = New-Object System.Windows.Forms.Button
  $b.Text = $text
  $b.Location = New-Object System.Drawing.Point($x,$y)
  $b.Size = New-Object System.Drawing.Size($width,40)
  $b.Anchor = 'Bottom,Left'
  $b.FlatStyle = 'Flat'
  $b.FlatAppearance.BorderSize = 1
  $b.Font = New-Object System.Drawing.Font('Segoe UI Semibold',9.5)
  if ($primary) {
    $b.FlatAppearance.BorderSize = 0
    $b.BackColor = [System.Drawing.Color]::FromArgb(34,197,154)
    $b.ForeColor = [System.Drawing.Color]::FromArgb(10,20,25)
  } else {
    $b.BackColor = [System.Drawing.Color]::FromArgb(31,41,55)
    $b.ForeColor = [System.Drawing.Color]::FromArgb(229,231,235)
    $b.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(75,91,105)
  }
  $form.Controls.Add($b)
  return $b
}
$download = New-Button 'Unduh / Perbarui scrcpy' 27 520 185 $false
$refresh = New-Button 'Muat ulang perangkat' 222 520 170 $false
$selectAll = New-Button 'Pilih semua siap' 402 520 145 $false
$start = New-Button 'Buka kontrol terpilih' 557 520 220 $true

function Set-ReadyState {
  if (Test-Path $script:ScrcpyExe) {
    $status.Text = 'Status: scrcpy siap. Sambungkan HP melalui USB, lalu muat ulang perangkat.'
    $status.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
    $refresh.Enabled = $true
    $selectAll.Enabled = $true
    $start.Enabled = $true
  } else {
    $status.Text = 'Status: scrcpy belum tersedia — unduh dahulu dari rilis resmi.'
    $status.ForeColor = [System.Drawing.Color]::FromArgb(251,191,36)
    $refresh.Enabled = $false
    $selectAll.Enabled = $false
    $start.Enabled = $false
  }
}

function Get-DeviceLabel($serial, $details) {
  $model = ''
  if ($details -match '(?:^|\s)model:([^\s]+)') { $model = $Matches[1] -replace '_',' ' }
  if ($model) { return $model }
  return $serial
}

$download.Add_Click({
  $download.Enabled = $false
  $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
  $status.Text = 'Mengunduh rilis resmi scrcpy dari GitHub...'
  $form.Refresh()
  try {
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/Genymobile/scrcpy/releases/latest' -Headers @{'User-Agent'='PhoneControlLite'}
    $asset = $release.assets | Where-Object { $_.name -match '^scrcpy-win64-v.*\.zip$' } | Select-Object -First 1
    if (-not $asset) { throw 'Arsip Windows x64 tidak ditemukan di rilis resmi.' }
    $zipPath = Join-Path $env:TEMP $asset.name
    $tmp = Join-Path $env:TEMP ('scrcpy-lite-' + [guid]::NewGuid().ToString('N'))
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -Headers @{'User-Agent'='PhoneControlLite'}
    Expand-Archive -LiteralPath $zipPath -DestinationPath $tmp -Force
    $exe = Get-ChildItem -Path $tmp -Filter 'scrcpy.exe' -Recurse | Select-Object -First 1
    if (-not $exe) { throw 'scrcpy.exe tidak ditemukan di arsip.' }
    if (Test-Path $script:ToolDir) { Remove-Item $script:ToolDir -Recurse -Force }
    New-Item -ItemType Directory -Path $script:ToolDir -Force | Out-Null
    Copy-Item -Path (Join-Path $exe.Directory.FullName '*') -Destination $script:ToolDir -Recurse -Force
    Remove-Item $tmp -Recurse -Force
    Remove-Item $zipPath -Force
    [System.Windows.Forms.MessageBox]::Show("scrcpy resmi berhasil disiapkan ($($release.tag_name)). Sambungkan HP, lalu tekan Muat ulang perangkat.",'Phone Control Lite') | Out-Null
    Set-ReadyState
  } catch {
    $status.Text = 'Gagal menyiapkan scrcpy.'
    [System.Windows.Forms.MessageBox]::Show("Tidak bisa mengunduh scrcpy resmi.`r`n$($_.Exception.Message)`r`n`r`nPeriksa koneksi internet lalu coba lagi.",'Phone Control Lite','OK','Error') | Out-Null
  } finally {
    $download.Enabled = $true
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
  }
})

$refresh.Add_Click({
  if (-not (Test-Path $script:ScrcpyExe)) { Set-ReadyState; return }
  $list.BeginUpdate()
  $list.Items.Clear()
  try {
    $adb = Join-Path $script:ToolDir 'adb.exe'
    $lines = & $adb devices -l 2>&1
    $rows = @()
    foreach ($line in $lines) {
      if ($line -match '^([^\s]+)\s+(device|unauthorized|offline)(?:\s+(.*))?$') {
        $rows += [pscustomobject]@{ Serial=$Matches[1]; State=$Matches[2]; Details=$Matches[3] }
      }
    }
    $total = $rows.Count
    $visible = @($rows | Select-Object -First $script:MaxDevices)
    foreach ($device in $visible) {
      $label = Get-DeviceLabel $device.Serial $device.Details
      $item = New-Object System.Windows.Forms.ListViewItem($label)
      [void]$item.SubItems.Add($device.Serial)
      [void]$item.SubItems.Add($device.State)
      $item.Tag = $device.Serial
      if ($device.State -eq 'device') {
        $item.ForeColor = [System.Drawing.Color]::FromArgb(190,245,220)
        $item.Checked = $false
      } else {
        $item.ForeColor = [System.Drawing.Color]::FromArgb(250,205,125)
        $item.Checked = $false
      }
      [void]$list.Items.Add($item)
    }
    if ($total -gt $script:MaxDevices) {
      $status.Text = "Terdeteksi $total perangkat. Batas aplikasi 30; menampilkan 30 pertama. Putuskan perangkat tambahan untuk mengganti daftar."
      $status.ForeColor = [System.Drawing.Color]::FromArgb(251,191,36)
    } else {
      $ready = @($rows | Where-Object { $_.State -eq 'device' }).Count
      $unauth = @($rows | Where-Object { $_.State -eq 'unauthorized' }).Count
      if ($total -eq 0) {
        $status.Text = 'Tidak ada HP terdeteksi. Periksa kabel data, USB debugging, dan tekan Muat ulang perangkat.'
        $status.ForeColor = [System.Drawing.Color]::FromArgb(251,191,36)
      } else {
        $status.Text = "Terdeteksi $total dari maksimum 30 · $ready siap · $unauth perlu izin."
        $status.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
      }
    }
  } catch {
    $status.Text = "Gagal membaca daftar ADB: $($_.Exception.Message)"
    $status.ForeColor = [System.Drawing.Color]::FromArgb(248,113,113)
  } finally { $list.EndUpdate() }
})

$selectAll.Add_Click({
  foreach ($item in $list.Items) { $item.Checked = ($item.SubItems[2].Text -eq 'device') }
})

$start.Add_Click({
  if (-not (Test-Path $script:ScrcpyExe)) { Set-ReadyState; return }
  $selected = @($list.CheckedItems | Where-Object { $_.SubItems[2].Text -eq 'device' })
  if ($selected.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show('Centang satu atau lebih HP berstatus device terlebih dahulu.','Belum ada perangkat dipilih') | Out-Null
    return
  }
  if ($selected.Count -gt $script:MaxDevices) {
    [System.Windows.Forms.MessageBox]::Show('Maksimum 30 HP dapat dijalankan sekaligus.','Batas perangkat') | Out-Null
    return
  }
  $message = "Akan membuka $($selected.Count) jendela kontrol scrcpy. Banyak layar sekaligus dapat membebani PC dan hub USB.`r`n`r`nLanjutkan?"
  $answer = [System.Windows.Forms.MessageBox]::Show($message,'Konfirmasi multi-HP','YesNo','Warning')
  if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return }
  $launched = 0
  foreach ($item in $selected) {
    $serial = [string]$item.Tag
    try {
      Start-Process -FilePath $script:ScrcpyExe -WorkingDirectory $script:ToolDir -ArgumentList @("--serial=$serial")
      $launched++
      Start-Sleep -Milliseconds 150
    } catch {
      [System.Windows.Forms.MessageBox]::Show("Gagal membuka kontrol untuk $serial.`r`n$($_.Exception.Message)",'Phone Control Lite','OK','Error') | Out-Null
    }
  }
  $status.Text = "Dibuka $launched dari $($selected.Count) jendela kontrol."
  $status.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
})

Set-ReadyState
[void]$form.ShowDialog()
