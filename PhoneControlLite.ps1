Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.ComponentModel
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:ToolDir = Join-Path $script:Root 'scrcpy'
$script:AdbExe = Join-Path $script:ToolDir 'adb.exe'
$script:ScrcpyExe = Join-Path $script:ToolDir 'scrcpy.exe'
$script:MaxDevices = 30
$script:Devices = @()
$script:ActiveSerial = $null
$script:LiveProcesses = @()
$script:PreviewWorker = New-Object System.ComponentModel.BackgroundWorker
$script:PreviewWorker.WorkerSupportsCancellation = $false

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Phone Control Lite — Multi HP'
$form.Size = New-Object System.Drawing.Size(1240,850)
$form.MinimumSize = New-Object System.Drawing.Size(900,650)
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(17,24,39)
$form.ForeColor = [System.Drawing.Color]::FromArgb(229,231,235)
$form.Font = New-Object System.Drawing.Font('Segoe UI',9.5)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'PHONE CONTROL LITE'
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold',18)
$title.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
$title.Location = New-Object System.Drawing.Point(20,14)
$title.Size = New-Object System.Drawing.Size(380,34)
$form.Controls.Add($title)

$summary = New-Object System.Windows.Forms.Label
$summary.Text = 'Hubungkan hingga 30 HP Android melalui USB.'
$summary.Location = New-Object System.Drawing.Point(22,51)
$summary.Size = New-Object System.Drawing.Size(740,26)
$summary.ForeColor = [System.Drawing.Color]::FromArgb(190,205,214)
$form.Controls.Add($summary)

function New-Button($text, $x, $y, $w, $primary=$false) {
  $b = New-Object System.Windows.Forms.Button
  $b.Text = $text
  $b.Location = New-Object System.Drawing.Point($x,$y)
  $b.Size = New-Object System.Drawing.Size($w,36)
  $b.FlatStyle = 'Flat'
  $b.Font = New-Object System.Drawing.Font('Segoe UI Semibold',9)
  if ($primary) {
    $b.BackColor = [System.Drawing.Color]::FromArgb(34,197,154)
    $b.ForeColor = [System.Drawing.Color]::FromArgb(10,20,25)
    $b.FlatAppearance.BorderSize = 0
  } else {
    $b.BackColor = [System.Drawing.Color]::FromArgb(31,41,55)
    $b.ForeColor = [System.Drawing.Color]::FromArgb(229,231,235)
    $b.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(75,91,105)
  }
  $form.Controls.Add($b)
  return $b
}
$download = New-Button 'Unduh / Perbarui' 20 87 145
$refresh = New-Button 'Muat ulang HP' 174 87 135
$selectAll = New-Button 'Pilih semua' 318 87 108
$back = New-Button '← Kembali' 438 87 108
$homeButton = New-Button '⌂ Home' 558 87 95

$broadcast = New-Object System.Windows.Forms.CheckBox
$broadcast.Text = 'Broadcast tap/swipe ke HP terpilih'
$broadcast.Location = New-Object System.Drawing.Point(670,94)
$broadcast.Size = New-Object System.Drawing.Size(270,26)
$broadcast.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
$broadcast.Font = New-Object System.Drawing.Font('Segoe UI Semibold',9)
$form.Controls.Add($broadcast)

$textLabel = New-Object System.Windows.Forms.Label
$textLabel.Text = 'Teks ASCII:'
$textLabel.Location = New-Object System.Drawing.Point(955,66)
$textLabel.Size = New-Object System.Drawing.Size(150,20)
$textLabel.ForeColor = [System.Drawing.Color]::FromArgb(190,205,214)
$form.Controls.Add($textLabel)

$sendText = New-Object System.Windows.Forms.TextBox
$sendText.Location = New-Object System.Drawing.Point(955,89)
$sendText.Size = New-Object System.Drawing.Size(150,30)
$sendText.BackColor = [System.Drawing.Color]::FromArgb(31,41,55)
$sendText.ForeColor = [System.Drawing.Color]::FromArgb(229,231,235)
$sendText.BorderStyle = 'FixedSingle'
$sendText.Text = ''
$sendText.AccessibleName = 'Ketik teks untuk dikirim ke perangkat aktif atau perangkat broadcast'
$form.Controls.Add($sendText)
$textButton = New-Button 'Kirim' 1112 87 75 $true

$status = New-Object System.Windows.Forms.Label
$liveButton = New-Button 'Buka mosaik LIVE (maks. 30)' 20 127 220 $true
$closeLiveButton = New-Button 'Tutup mosaik LIVE' 250 127 160
$status.Text = 'Status: unduh scrcpy dahulu. Preview grid berkala; mosaik LIVE memakai video scrcpy.'
$status.Location = New-Object System.Drawing.Point(22,169)
$status.Size = New-Object System.Drawing.Size(1170,24)
$status.Anchor = 'Top,Left,Right'
$status.ForeColor = [System.Drawing.Color]::FromArgb(251,191,36)
$form.Controls.Add($status)

$panel = New-Object System.Windows.Forms.FlowLayoutPanel
$panel.Location = New-Object System.Drawing.Point(20,201)
$panel.Size = New-Object System.Drawing.Size(1180,598)
$panel.Anchor = 'Top,Bottom,Left,Right'
$panel.AutoScroll = $true
$panel.WrapContents = $true
$panel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$panel.BackColor = [System.Drawing.Color]::FromArgb(17,24,39)
$form.Controls.Add($panel)

function Set-ReadyState {
  $ready = Test-Path $script:AdbExe
  $refresh.Enabled = $ready
  $selectAll.Enabled = $ready
  $liveButton.Enabled = (Test-Path $script:ScrcpyExe)
  $closeLiveButton.Enabled = ($script:LiveProcesses.Count -gt 0)
  if ($ready) {
    $status.Text = 'ADB siap. Sambungkan HP, setujui USB debugging pada tiap HP, lalu tekan Muat ulang HP.'
    $status.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
  } else {
    $status.Text = 'Belum ada ADB. Tekan Unduh / Perbarui untuk mengambil scrcpy resmi yang menyertakan ADB.'
    $status.ForeColor = [System.Drawing.Color]::FromArgb(251,191,36)
  }
}

function Get-ScreenSize($serial) {
  try {
    $output = & $script:AdbExe -s $serial shell wm size 2>$null | Out-String
    $matches = [regex]::Matches($output,'(\d+)x(\d+)')
    if ($matches.Count -gt 0) {
      $m = $matches[$matches.Count - 1]
      return @{ Width=[int]$m.Groups[1].Value; Height=[int]$m.Groups[2].Value }
    }
  } catch { }
  return @{ Width=1080; Height=1920 }
}

function Close-LiveMosaic {
  foreach ($proc in $script:LiveProcesses) {
    try {
      if ($proc -and -not $proc.HasExited) { $proc.Kill() }
    } catch { }
  }
  $script:LiveProcesses = @()
  $closeLiveButton.Enabled = $false
}

function Start-LiveMosaic {
  if (-not (Test-Path $script:ScrcpyExe)) {
    [System.Windows.Forms.MessageBox]::Show('Tekan Unduh / Perbarui dahulu untuk memasang scrcpy.','Phone Control Lite') | Out-Null
    return
  }
  $readyDevices = @($script:Devices | Where-Object { $_.State -eq 'device' })
  if ($readyDevices.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show('Tekan Muat ulang HP dan pastikan setidaknya satu perangkat berstatus device.','Belum ada HP siap') | Out-Null
    return
  }
  if ($readyDevices.Count -gt $script:MaxDevices) { $readyDevices = @($readyDevices | Select-Object -First $script:MaxDevices) }
  $selectedDevices = @($readyDevices | Where-Object { $_.Select.Checked })
  if ($selectedDevices.Count -gt 0) { $readyDevices = $selectedDevices }
  $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
  $columns = [int][Math]::Ceiling([Math]::Sqrt($readyDevices.Count))
  $rows = [int][Math]::Ceiling($readyDevices.Count/[double]$columns)
  $cellW = [int][Math]::Floor($screen.Width/[double]$columns)
  $cellH = [int][Math]::Floor($screen.Height/[double]$rows)
  $msg = "Akan membuka $($readyDevices.Count) stream scrcpy live dalam mosaik pada monitor utama.`r`nResolusi dibatasi 480 px, maksimum 8 fps, audio mati. Performa bergantung pada PC dan USB.`r`n`r`nLanjutkan?"
  if ([System.Windows.Forms.MessageBox]::Show($msg,'Mosaik LIVE','YesNo','Warning') -ne [System.Windows.Forms.DialogResult]::Yes) { return }
  Close-LiveMosaic
  $timer.Stop()
  $started = 0
  for ($i=0; $i -lt $readyDevices.Count; $i++) {
    $device = $readyDevices[$i]
    $col = $i % $columns; $row = [int][Math]::Floor($i/[double]$columns)
    $ratio = [Math]::Max(0.25,$device.Width/[double][Math]::Max(1,$device.Height))
    $winW = $cellW; $winH = $cellH
    if (($winW/[double]$winH) -gt $ratio) { $winW = [int][Math]::Floor($winH*$ratio) }
    else { $winH = [int][Math]::Floor($winW/$ratio) }
    $winX = [int]($screen.Left + $col*$cellW + ($cellW-$winW)/2)
    $winY = [int]($screen.Top + $row*$cellH + ($cellH-$winH)/2)
    $args = @(
      "--serial=$($device.Serial)", '--max-size=480', '--max-fps=8',
      '--video-bit-rate=1M', '--no-audio', '--window-borderless',
      "--window-x=$winX", "--window-y=$winY", "--window-width=$winW", "--window-height=$winH",
      "--window-title=PCL_$($i+1)"
    )
    try {
      $proc = Start-Process -FilePath $script:ScrcpyExe -WorkingDirectory $script:ToolDir -ArgumentList $args -PassThru
      $script:LiveProcesses += $proc
      $started++
      Start-Sleep -Milliseconds 180
    } catch { }
  }
  $closeLiveButton.Enabled = ($script:LiveProcesses.Count -gt 0)
  if ($started -eq 0) {
    $status.Text = 'Gagal membuka jendela scrcpy. Periksa instalasi scrcpy, kabel, dan status USB debugging.'
    $status.ForeColor = [System.Drawing.Color]::FromArgb(248,113,113)
    $timer.Start()
    return
  }
  $status.Text = "Mosaik live dibuka: $started/$($readyDevices.Count) HP · $columns kolom × $rows baris · 480 px/8 fps."
  $status.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
  $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
}

function Get-SelectedTargets($singleSerial=$null) {
  if ($script:Devices.Count -eq 0) { return @() }
  if ($broadcast.Checked) {
    return @($script:Devices | Where-Object { $_.Select.Checked -and $_.State -eq 'device' })
  }
  if ($singleSerial) { return @($script:Devices | Where-Object { $_.Serial -eq $singleSerial -and $_.State -eq 'device' }) }
  if ($script:ActiveSerial) { return @($script:Devices | Where-Object { $_.Serial -eq $script:ActiveSerial -and $_.State -eq 'device' }) }
  return @()
}

function Invoke-Input($serial, $kind, $x1=0, $y1=0, $x2=0, $y2=0, $duration=350, $textValue='') {
  $device = $script:Devices | Where-Object { $_.Serial -eq $serial } | Select-Object -First 1
  if (-not $device) { return }
  $adbArgs = @('-s',$serial,'shell','input')
  switch ($kind) {
    'tap' { $adbArgs += @('tap',[string]$x1,[string]$y1) }
    'swipe' { $adbArgs += @('swipe',[string]$x1,[string]$y1,[string]$x2,[string]$y2,[string]$duration) }
    'back' { $adbArgs += @('keyevent','4') }
    'home' { $adbArgs += @('keyevent','3') }
    'text' {
      if ([string]::IsNullOrWhiteSpace($textValue)) { return }
      $escaped = $textValue -replace '\s','%s' -replace '[^a-zA-Z0-9@._%+-]',''
      if (-not $escaped) { return }
      $adbArgs += @('text',$escaped)
    }
  }
  try { Start-Process -FilePath $script:AdbExe -ArgumentList $adbArgs -WindowStyle Hidden | Out-Null } catch { }
}

function Convert-PreviewPoint($picture, $x, $y) {
  if (-not $picture.Image) { return @{ X=0.5; Y=0.5 } }
  $scale = [Math]::Min($picture.Width/[double]$picture.Image.Width,$picture.Height/[double]$picture.Image.Height)
  $drawW = $picture.Image.Width * $scale; $drawH = $picture.Image.Height * $scale
  $offsetX = ($picture.Width - $drawW) / 2; $offsetY = ($picture.Height - $drawH) / 2
  return @{
    X=[Math]::Max(0,[Math]::Min(1,($x-$offsetX)/[Math]::Max(1,$drawW)))
    Y=[Math]::Max(0,[Math]::Min(1,($y-$offsetY)/[Math]::Max(1,$drawH)))
  }
}

function Send-Action($kind, $serial=$null, $x1=0, $y1=0, $x2=0, $y2=0, $duration=350, $textValue='') {
  $targets = @(Get-SelectedTargets $serial)
  if ($targets.Count -eq 0) {
    $status.Text = if ($broadcast.Checked) { 'Pilih minimal satu HP berstatus device untuk broadcast.' } else { 'Klik salah satu preview HP dahulu untuk memilih perangkat aktif.' }
    $status.ForeColor = [System.Drawing.Color]::FromArgb(251,191,36)
    return
  }
  foreach ($d in $targets) {
    $px1 = [int]($x1 * $d.Width); $py1 = [int]($y1 * $d.Height)
    $px2 = [int]($x2 * $d.Width); $py2 = [int]($y2 * $d.Height)
    Invoke-Input $d.Serial $kind $px1 $py1 $px2 $py2 $duration $textValue
  }
}

function New-DeviceCard($device) {
  $card = New-Object System.Windows.Forms.Panel
  $card.Size = New-Object System.Drawing.Size(220,365)
  $card.Margin = New-Object System.Windows.Forms.Padding(8)
  $card.BackColor = [System.Drawing.Color]::FromArgb(24,38,49)
  $card.BorderStyle = 'FixedSingle'

  $check = New-Object System.Windows.Forms.CheckBox
  $check.Text = 'Broadcast'
  $check.Location = New-Object System.Drawing.Point(8,7)
  $check.Size = New-Object System.Drawing.Size(90,22)
  $check.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
  $check.Enabled = ($device.State -eq 'device')
  $card.Controls.Add($check)

  $label = New-Object System.Windows.Forms.Label
  $label.Text = $device.Label
  $label.Location = New-Object System.Drawing.Point(102,8)
  $label.Size = New-Object System.Drawing.Size(108,22)
  $label.ForeColor = [System.Drawing.Color]::FromArgb(229,231,235)
  $label.Font = New-Object System.Drawing.Font('Segoe UI Semibold',9)
  $label.TextAlign = 'MiddleRight'
  $card.Controls.Add($label)

  $picture = New-Object System.Windows.Forms.PictureBox
  $picture.Location = New-Object System.Drawing.Point(10,35)
  $picture.Size = New-Object System.Drawing.Size(198,275)
  $picture.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
  $picture.BackColor = [System.Drawing.Color]::FromArgb(8,13,18)
  $picture.BorderStyle = 'FixedSingle'
  $picture.Cursor = [System.Windows.Forms.Cursors]::Cross
  $picture.Tag = $device.Serial
  $card.Controls.Add($picture)

  $state = New-Object System.Windows.Forms.Label
  $state.Text = "$($device.State) · $($device.Serial)"
  $state.Location = New-Object System.Drawing.Point(10,316)
  $state.Size = New-Object System.Drawing.Size(198,38)
  $state.ForeColor = if ($device.State -eq 'device') { [System.Drawing.Color]::FromArgb(96,225,190) } else { [System.Drawing.Color]::FromArgb(251,191,36) }
  $state.Font = New-Object System.Drawing.Font('Segoe UI',8)
  $state.AutoEllipsis = $true
  $card.Controls.Add($state)

  $picture.Add_MouseDown({
    param($sender,$e)
    $point = Convert-PreviewPoint $sender $e.X $e.Y
    $script:MouseStart = @{Serial=$sender.Tag; X=$point.X; Y=$point.Y; RawX=$e.X; RawY=$e.Y; Time=[datetime]::UtcNow}
  })
  $picture.Add_MouseUp({
    param($sender,$e)
    if (-not $script:MouseStart -or $script:MouseStart.Serial -ne $sender.Tag) { return }
    $serial = [string]$sender.Tag
    $script:ActiveSerial = $serial
    $device = $script:Devices | Where-Object { $_.Serial -eq $serial } | Select-Object -First 1
    if (-not $device -or $device.State -ne 'device') { return }
    $start = $script:MouseStart
    $end = Convert-PreviewPoint $sender $e.X $e.Y
    $x1 = [double]$start.X; $y1 = [double]$start.Y
    $x2 = [double]$end.X; $y2 = [double]$end.Y
    $delta = [Math]::Abs($e.X-$start.RawX)+[Math]::Abs($e.Y-$start.RawY)
    if ($delta -lt 8) { Send-Action 'tap' $serial $x1 $y1 } else { Send-Action 'swipe' $serial $x1 $y1 $x2 $y2 350 }
    $script:MouseStart = $null
  })
  $device | Add-Member -NotePropertyName Card -NotePropertyValue $card -Force
  $device | Add-Member -NotePropertyName Select -NotePropertyValue $check -Force
  $device | Add-Member -NotePropertyName Picture -NotePropertyValue $picture -Force
  return $card
}

function Refresh-Previews {
  if (-not (Test-Path $script:AdbExe) -or $script:PreviewWorker.IsBusy -or $script:Devices.Count -eq 0) { return }
  $snapshot = @($script:Devices | Where-Object { $_.State -eq 'device' } | ForEach-Object { [pscustomobject]@{ Serial=$_.Serial } })
  if ($snapshot.Count -eq 0) { return }
  $script:PreviewWorker.RunWorkerAsync($snapshot)
}

$script:PreviewWorker.add_DoWork({
  param($sender,$e)
  $results = New-Object System.Collections.Generic.List[object]
  foreach ($dev in $e.Argument) {
    $safe = [regex]::Replace([string]$dev.Serial,'[^a-zA-Z0-9_-]','_')
    $file = Join-Path $env:TEMP ('pcl-' + $safe + '-' + [guid]::NewGuid().ToString('N') + '.png')
    try {
      $psi = New-Object System.Diagnostics.ProcessStartInfo
      $psi.FileName = $script:AdbExe
      $psi.Arguments = '-s "' + $dev.Serial + '" exec-out screencap -p'
      $psi.UseShellExecute = $false
      $psi.CreateNoWindow = $true
      $psi.RedirectStandardOutput = $true
      $psi.RedirectStandardError = $true
      $proc = New-Object System.Diagnostics.Process
      $proc.StartInfo = $psi
      [void]$proc.Start()
      $fs = [System.IO.File]::Open($file,[System.IO.FileMode]::Create,[System.IO.FileAccess]::Write,[System.IO.FileShare]::None)
      $proc.StandardOutput.BaseStream.CopyTo($fs)
      $fs.Dispose()
      $err = $proc.StandardError.ReadToEnd()
      if (-not $proc.WaitForExit(6000)) { $proc.Kill(); throw 'Timeout' }
      if ($proc.ExitCode -eq 0 -and (Get-Item $file).Length -gt 100) { $results.Add([pscustomobject]@{Serial=$dev.Serial; Path=$file}) }
      else { Remove-Item $file -Force -ErrorAction SilentlyContinue }
    } catch { Remove-Item $file -Force -ErrorAction SilentlyContinue }
  }
  $e.Result = @($results.ToArray())
})

$script:PreviewWorker.add_RunWorkerCompleted({
  param($sender,$e)
  if ($e.Error) { $status.Text = 'Gagal memperbarui preview: ' + $e.Error.Message; return }
  foreach ($result in $e.Result) {
    $device = $script:Devices | Where-Object { $_.Serial -eq $result.Serial } | Select-Object -First 1
    if ($device -and (Test-Path $result.Path)) {
      try {
        $stream = [System.IO.File]::OpenRead($result.Path)
        $img = [System.Drawing.Image]::FromStream($stream)
        $copy = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $img
        $img.Dispose(); $stream.Dispose()
        if ($device.Picture.Image) { $device.Picture.Image.Dispose() }
        $device.Picture.Image = $copy
      } catch { }
      Remove-Item $result.Path -Force -ErrorAction SilentlyContinue
    }
  }
  $status.Text = "Preview diperbarui untuk perangkat tersambung. Klik gambar untuk kontrol individual; centang Broadcast lalu klik untuk mengirim tap/swipe yang sama ke HP terpilih."
  $status.ForeColor = [System.Drawing.Color]::FromArgb(190,205,214)
})

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 4500
$timer.Add_Tick({ Refresh-Previews })

$download.Add_Click({
  $download.Enabled = $false
  $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
  $status.Text = 'Mengunduh rilis resmi scrcpy untuk mendapatkan ADB...'
  $form.Refresh()
  try {
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/Genymobile/scrcpy/releases/latest' -Headers @{'User-Agent'='PhoneControlLite'}
    $asset = $release.assets | Where-Object { $_.name -match '^scrcpy-win64-v.*\.zip$' } | Select-Object -First 1
    if (-not $asset) { throw 'Arsip Windows x64 tidak ditemukan di rilis resmi.' }
    $zipPath = Join-Path $env:TEMP $asset.name
    $tmp = Join-Path $env:TEMP ('scrcpy-lite-' + [guid]::NewGuid().ToString('N'))
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -Headers @{'User-Agent'='PhoneControlLite'}
    Expand-Archive -LiteralPath $zipPath -DestinationPath $tmp -Force
    $exe = Get-ChildItem -Path $tmp -Filter 'adb.exe' -Recurse | Select-Object -First 1
    if (-not $exe) { throw 'adb.exe tidak ditemukan di arsip.' }
    if (Test-Path $script:ToolDir) { Remove-Item $script:ToolDir -Recurse -Force }
    New-Item -ItemType Directory -Path $script:ToolDir -Force | Out-Null
    Copy-Item -Path (Join-Path $exe.Directory.FullName '*') -Destination $script:ToolDir -Recurse -Force
    Remove-Item $tmp -Recurse -Force; Remove-Item $zipPath -Force
    [System.Windows.Forms.MessageBox]::Show("ADB dan scrcpy siap ($($release.tag_name)). Sambungkan HP, lalu tekan Muat ulang HP.",'Phone Control Lite') | Out-Null
    Set-ReadyState
  } catch {
    $status.Text = 'Gagal mengunduh ADB/scrcpy.'
    [System.Windows.Forms.MessageBox]::Show("Tidak bisa mengunduh scrcpy resmi.`r`n$($_.Exception.Message)",'Phone Control Lite','OK','Error') | Out-Null
  } finally { $download.Enabled = $true; $form.Cursor = [System.Windows.Forms.Cursors]::Default }
})

$refresh.Add_Click({
  if (-not (Test-Path $script:AdbExe)) { Set-ReadyState; return }
  $refresh.Enabled = $false
  $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
  try {
    $lines = & $script:AdbExe devices -l 2>&1
    $rows = @()
    foreach ($line in $lines) {
      if ($line -match '^(.*?)\s+(device|unauthorized|offline)(?:\s+(.*))?$') {
        $serial = $Matches[1]; $state = $Matches[2]; $details = $Matches[3]
        $label = $serial
        if ($details -match '(?:^|\s)model:(\S+)') { $label = $Matches[1] -replace '_',' ' }
        $size = if ($state -eq 'device') { Get-ScreenSize $serial } else { @{Width=1080;Height=1920} }
        $rows += [pscustomobject]@{Serial=$serial; State=$state; Label=$label; Width=$size.Width; Height=$size.Height}
      }
    }
    $oldDevices = $script:Devices
    foreach ($oldDevice in $oldDevices) { if ($oldDevice.Picture -and $oldDevice.Picture.Image) { $oldDevice.Picture.Image.Dispose() } }
    $script:Devices = @($rows | Select-Object -First $script:MaxDevices)
    $panel.SuspendLayout(); $panel.Controls.Clear()
    foreach ($device in $script:Devices) { [void]$panel.Controls.Add((New-DeviceCard $device)) }
    $panel.ResumeLayout()
    $ready = @($script:Devices | Where-Object { $_.State -eq 'device' }).Count
    $unauthorized = @($script:Devices | Where-Object { $_.State -eq 'unauthorized' }).Count
    if ($rows.Count -gt $script:MaxDevices) { $status.Text = "Terdeteksi $($rows.Count); batas 30, menampilkan 30 pertama. Putuskan perangkat tambahan untuk mengganti daftar." }
    elseif ($rows.Count -eq 0) { $status.Text = 'Belum ada perangkat. Periksa kabel data dan USB debugging.' }
    else { $status.Text = "Terdeteksi $($rows.Count) HP · $ready siap · $unauthorized perlu persetujuan USB debugging. Preview diperbarui berkala." }
    $status.ForeColor = [System.Drawing.Color]::FromArgb(96,225,190)
    $script:ActiveSerial = if ($ready -gt 0) { ($script:Devices | Where-Object { $_.State -eq 'device' } | Select-Object -First 1).Serial } else { $null }
  } catch {
    $status.Text = "Gagal membaca ADB: $($_.Exception.Message)"
    $status.ForeColor = [System.Drawing.Color]::FromArgb(248,113,113)
  } finally { $refresh.Enabled = $true; $form.Cursor = [System.Windows.Forms.Cursors]::Default }
  Refresh-Previews
})

$selectAll.Add_Click({ foreach ($device in $script:Devices) { if ($device.State -eq 'device') { $device.Select.Checked = $true } } })
$liveButton.Add_Click({ Start-LiveMosaic })
$closeLiveButton.Add_Click({ Close-LiveMosaic; $timer.Start(); $status.Text = 'Semua jendela mosaik live Phone Control Lite ditutup.' })
$back.Add_Click({ Send-Action 'back' })
$homeButton.Add_Click({ Send-Action 'home' })
$textButton.Add_Click({ Send-Action 'text' $null 0 0 0 0 350 $sendText.Text })
$form.Add_FormClosing({ $timer.Stop(); Close-LiveMosaic; foreach ($device in $script:Devices) { if ($device.Picture.Image) { $device.Picture.Image.Dispose() } } })

Set-ReadyState
$timer.Start()
[void]$form.ShowDialog()
