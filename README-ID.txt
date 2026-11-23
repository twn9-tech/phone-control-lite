PHONE CONTROL LITE — Layar LIVE & Broadcast hingga 30 HP
========================================================

Aplikasi Windows untuk mengelola banyak HP Android melalui USB. Layar live scrcpy tampil langsung di dalam kartu dashboard Phone Control Lite. Klik layar dalam kartu untuk mengontrol HP itu sendiri. Tidak perlu berpindah ke jendela scrcpy lain.

CARA PAKAI
1. Ekstrak ZIP ke folder di PC Windows.
2. Klik dua kali Start-PhoneControlLite.bat.
3. Tekan Unduh / Perbarui untuk mengambil scrcpy resmi beserta ADB. Perlu internet.
4. Di setiap HP, aktifkan Opsi Pengembang > USB debugging, sambungkan kabel USB data, buka kunci layar, lalu setujui permintaan debugging.
5. Tekan Muat ulang HP. Perangkat berstatus unauthorized perlu disetujui di layar HP; tekan muat ulang lagi sesudahnya.
6. Opsional: centang kotak Broadcast pada HP tujuan. Jika ada perangkat dicentang, tombol Tampilkan layar LIVE di sini hanya membuka perangkat terpilih. Jika tidak ada yang dicentang, semua HP berstatus device (maksimum 30) dibuka.
7. Tekan Tampilkan layar LIVE di sini dan setujui konfirmasi. Layar scrcpy akan ditanam di dalam kartu dashboard, bukan dibuka sebagai jendela desktop terpisah. Klik atau seret pada layar sebuah kartu untuk mengontrol HP tersebut secara individual.
8. Untuk broadcast tap/swipe, centang perangkat tujuan lalu aktifkan Broadcast tap/swipe ke HP terpilih. Saat mode broadcast aktif, layar live sementara diganti snapshot dashboard agar klik/seret bisa dikirim ke semua perangkat yang dicentang. Matikan mode broadcast untuk kembali ke video live.
9. Tombol Kembali, Home, dan Kirim teks bekerja pada HP aktif atau perangkat terpilih ketika mode broadcast aktif.
10. Tekan Tutup layar LIVE untuk menutup stream dan kembali ke snapshot.

BATAS DAN PERILAKU
- Maksimum 30 perangkat ditampilkan. Grid menyesuaikan jumlah HP; 20 perangkat memakai sekitar 5 kolom × 4 baris. Ukuran tiap layar mengecil saat perangkat bertambah, sehingga 30 layar pada satu monitor akan berukuran kecil.
- Video live memakai scrcpy resmi di dalam kartu dashboard. Stream dibatasi secara default ke ukuran maksimum 480 piksel, 8 frame per detik, bitrate 1 Mbps per HP, dan tanpa audio. Kualitas dan kelancaran bergantung pada kemampuan HP, CPU/GPU PC, port atau hub USB, kabel, dan jumlah stream.
- Saat video live ditutup atau mode broadcast aktif, kartu menggunakan snapshot ADB berkala. Snapshot dapat terlambat; broadcast memengaruhi semua perangkat yang dicentang. Pastikan aplikasi dan halaman pada semua HP sesuai sebelum mengirim input.
- Windows 10/11 64-bit dan PowerShell bawaan diperlukan. Hanya untuk Android, bukan iPhone.
- Bila layar rusak sehingga permintaan izin USB debugging tidak bisa disetujui, perangkat mungkin tidak tersambung. Mouse USB OTG dapat membantu bila tampilan masih terlihat.
- Gunakan hanya pada perangkat dan PC yang Anda percaya. Aplikasi tidak membuka kunci atau melewati PIN/proteksi Android.

SUMBER
scrcpy resmi: https://github.com/Genymobile/scrcpy (Apache-2.0). Phone Control Lite adalah launcher independen dan bukan produk resmi Genymobile.
