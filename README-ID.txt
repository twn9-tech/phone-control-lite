PHONE CONTROL LITE — Multi HP untuk Windows
============================================

Launcher sederhana untuk mendeteksi dan membuka kontrol hingga 30 HP Android sekaligus. Setiap HP dibuka di jendela scrcpy terpisah.

CARA PAKAI
1. Ekstrak ZIP ke folder di PC Windows.
2. Klik dua kali Start-PhoneControlLite.bat.
3. Pastikan internet tersedia, lalu tekan Unduh / Perbarui scrcpy. Aplikasi mengambil rilis Windows x64 langsung dari GitHub resmi Genymobile/scrcpy.
4. Di setiap HP Android, aktifkan Opsi Pengembang > USB debugging.
5. Hubungkan HP menggunakan kabel USB data dan buka kunci perangkat.
6. Setujui dialog Allow USB debugging pada setiap HP.
7. Tekan Muat ulang perangkat, centang HP yang ingin dikontrol, lalu tekan Buka kontrol terpilih.

BATAS DAN CATATAN
- Maksimum 30 perangkat ditampilkan dan dapat dipilih oleh aplikasi.
- Masing-masing HP dibuka dalam jendela scrcpy terpisah. Kinerja 30 layar sekaligus bergantung pada CPU/GPU, RAM, port dan hub USB, kabel, resolusi serta frame rate.
- Jika HP lebih dari 30 terhubung, aplikasi menampilkan 30 perangkat pertama yang dilaporkan ADB.
- Status unauthorized berarti izin debugging belum disetujui di layar HP.
- Ini hanya untuk Android, bukan iPhone. Windows 10/11 64-bit dan PowerShell bawaan Windows diperlukan.
- Jika layar HP tidak bisa dipakai untuk menyetujui dialog, koneksi mungkin tidak dapat dimulai. Mouse USB melalui adaptor OTG bisa membantu bila gambar masih terlihat.
- Jangan mengotorisasi USB debugging pada komputer umum/tidak dipercaya. Aplikasi tidak membuka kunci, melewati PIN, atau mengakali proteksi Android.

SUMBER
scrcpy resmi: https://github.com/Genymobile/scrcpy (Apache-2.0). Phone Control Lite adalah launcher independen dan bukan produk resmi Genymobile.
