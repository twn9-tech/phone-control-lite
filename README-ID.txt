PHONE CONTROL LITE — Grid & Broadcast hingga 30 HP
==================================================

Aplikasi Windows untuk menampilkan preview sampai 30 HP Android dalam satu jendela, mengirim tap/swipe ke HP individual, atau menyiarkan input yang sama ke semua HP yang dipilih.

CARA PAKAI
1. Ekstrak ZIP ke folder di PC Windows.
2. Klik dua kali Start-PhoneControlLite.bat.
3. Tekan Unduh / Perbarui untuk mengunduh scrcpy resmi (arsipnya menyertakan ADB). Ini perlu internet.
4. Di setiap HP, aktifkan Opsi Pengembang > USB debugging, sambungkan kabel USB data, buka kunci layar, lalu setujui permintaan debugging.
5. Tekan Muat ulang HP. Perangkat berstatus unauthorized perlu disetujui di layar HP; tekan muat ulang lagi sesudahnya.
6. Klik gambar HP untuk mengirim tap, atau seret pada gambar untuk mengirim swipe ke HP tersebut.
7. Untuk broadcast, centang Broadcast pada HP tujuan, aktifkan Broadcast tap/swipe ke HP terpilih, lalu klik/seret pada salah satu preview. Tap/swipe yang sama akan dikirim ke semua perangkat yang dicentang, dengan koordinat dinormalisasi menurut ukuran layar masing-masing.
8. Tombol Kembali, Home, dan Kirim teks bekerja pada HP aktif atau pada perangkat terpilih ketika mode broadcast aktif.

BATAS DAN PERILAKU
- Maksimum 30 perangkat ditampilkan; jika lebih dari 30 terhubung, aplikasi menampilkan 30 pertama yang dilaporkan ADB.
- Preview berupa snapshot layar yang diperbarui berkala melalui ADB, bukan video langsung. Dengan banyak perangkat, pembaruan dapat memerlukan beberapa detik dan tidak serempak.
- Tap/swipe serta tombol Back/Home dikirim lewat ADB; posisi broadcast dipetakan secara proporsional pada tiap resolusi. Ketik teks mendukung karakter Latin dasar.
- Mengirim input ke banyak perangkat sekaligus dapat mengubah/menekan tombol di semua HP tujuan. Pastikan aplikasi dan halaman pada perangkat sesuai sebelum broadcast.
- Kelancaran 30 preview dan broadcast bergantung pada CPU, RAM, port/hub USB, kabel, dan perangkat.
- Windows 10/11 64-bit dan PowerShell bawaan diperlukan. Ini hanya untuk Android, bukan iPhone.
- Bila layar rusak sehingga permintaan izin tidak bisa disetujui, perangkat mungkin tidak tersambung. Mouse USB OTG dapat membantu bila tampilan masih terlihat.
- Gunakan hanya pada perangkat dan PC yang Anda percaya. Aplikasi tidak membuka kunci atau melewati PIN/proteksi Android.

SUMBER
scrcpy resmi: https://github.com/Genymobile/scrcpy (Apache-2.0). Phone Control Lite adalah launcher independen dan bukan produk resmi Genymobile.
