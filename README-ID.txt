PHONE CONTROL LITE — Mosaik LIVE & Broadcast hingga 30 HP
=========================================================

Aplikasi Windows untuk mengelola banyak HP Android melalui USB. Preview dashboard biasa adalah snapshot berkala. Untuk video langsung, aplikasi membuka jendela scrcpy terpisah dan menatanya sebagai mosaik di monitor utama. Setiap jendela bisa dikontrol sendiri dengan mouse.

CARA PAKAI
1. Ekstrak ZIP ke folder di PC Windows.
2. Klik dua kali Start-PhoneControlLite.bat.
3. Tekan Unduh / Perbarui untuk mengunduh scrcpy resmi yang menyertakan ADB. Perlu internet.
4. Di setiap HP, aktifkan Opsi Pengembang > USB debugging, sambungkan kabel USB data, buka kunci layar, lalu setujui permintaan debugging.
5. Tekan Muat ulang HP. Perangkat berstatus unauthorized perlu disetujui di layar HP; tekan muat ulang lagi sesudahnya.
6. Opsional: centang kotak Broadcast pada perangkat tujuan. Jika ada perangkat yang dicentang, tombol Buka mosaik LIVE hanya membuka perangkat yang dicentang. Jika tidak ada yang dicentang, tombol itu membuka semua HP berstatus device (maksimum 30).
7. Tekan Buka mosaik LIVE (maks. 30), baca konfirmasi, lalu pilih Yes. Jendela live disusun otomatis di monitor utama. Contohnya, 20 HP memakai 5 kolom × 4 baris; 30 HP memakai 6 × 5.
8. Klik atau seret pada jendela scrcpy tertentu untuk mengontrol HP itu secara individual. Tekan Alt+Tab atau pulihkan Phone Control Lite dari taskbar untuk kembali ke dashboard. Tombol Tutup mosaik LIVE menutup stream yang dibuka aplikasi.
9. Untuk broadcast tap/swipe, centang Broadcast pada HP tujuan dan aktifkan Broadcast tap/swipe ke HP terpilih di dashboard. Gunakan snapshot dashboard sebagai area input: klik/seret pada preview untuk mengirim input yang sama ke semua HP yang dicentang. Koordinat dipetakan secara proporsional menurut resolusi masing-masing.
10. Tombol Kembali, Home, dan Kirim teks bekerja pada HP aktif atau perangkat terpilih ketika mode broadcast aktif.

BATAS DAN PERILAKU
- Maksimum 30 perangkat ditampilkan dan ditata. Bila lebih dari 30 HP terhubung, aplikasi menggunakan 30 perangkat pertama yang dilaporkan ADB.
- Mosaik LIVE adalah beberapa jendela scrcpy tanpa bingkai yang ditempatkan dalam satu monitor, bukan satu jendela video gabungan. Rasio layar HP dipertahankan; gambar portrait akan lebih sempit daripada sel grid. Jendela Phone Control Lite diminimalkan setelah mosaik dibuka.
- Stream live dibatasi secara default ke ukuran maksimum 480 piksel, 8 frame per detik, bitrate 1 Mbps per HP, tanpa audio. Ini mengurangi beban tetapi dapat membuat gerakan kurang mulus dan detail kecil sulit terlihat. Performa nyata bergantung pada kemampuan encoding HP, CPU/GPU PC, port atau hub USB, kabel, dan jumlah perangkat.
- Preview grid di dashboard tetap snapshot ADB berkala, bukan video langsung. Gunakan jendela mosaik scrcpy untuk melihat video live.
- Broadcast tap/swipe, Back/Home, dan teks akan memengaruhi semua perangkat yang dipilih. Pastikan aplikasi dan halaman pada perangkat sesuai sebelum mengirim input.
- Windows 10/11 64-bit dan PowerShell bawaan diperlukan. Hanya Android, bukan iPhone.
- Bila layar rusak sehingga permintaan izin USB debugging tidak bisa disetujui, perangkat mungkin tidak tersambung. Mouse USB OTG dapat membantu bila tampilan masih terlihat.
- Gunakan hanya pada perangkat dan PC yang Anda percaya. Aplikasi tidak membuka kunci atau melewati PIN/proteksi Android.

SUMBER
scrcpy resmi: https://github.com/Genymobile/scrcpy (Apache-2.0). Phone Control Lite adalah launcher independen dan bukan produk resmi Genymobile.
