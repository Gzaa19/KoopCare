import 'package:koopcare/features/faq/data/models/faq_item.dart';

/// Static FAQ content for the KoopCare app.
const List<FaqItem> kFaqData = [
  FaqItem(
    'Apa itu KoopCare',
    'KoopCare adalah aplikasi digital resmi dari koperasi kami yang memudahkan '
    'anggota untuk melakukan transaksi, mengajukan peminjaman, memantau simpanan, '
    'dan mengakses layanan koperasi secara online dan kapan saja.',
  ),
  FaqItem(
    'Apa Saja layanan KoopCare',
    'KoopCare menyediakan berbagai jenis layanan seperti:\n'
    '• Transaksi digital — Top Up, Transfer, Tarik dana\n'
    '• Peminjaman — Pengajuan pembiayaan Murabahah & Qardhul Hasan\n'
    '• Riwayat transaksi — Pantau semua aktivitas akun Anda\n'
    '• Notifikasi — Pemberitahuan jatuh tempo dan status pengajuan',
  ),
  FaqItem(
    'Sistem Peminjaman',
    'Sistem peminjaman pada KoopCare menggunakan sistem AI yang dikembangkan '
    'di mana AI akan memberikan nilai selisih dalam jangka waktu 1–24 jam serta '
    'memberikan nilai selisih ai berdasarkan kepada admin untuk menerima dan '
    'menolak pemberian kepada anggota yang mengajukan permohonan tersebut.',
  ),
  FaqItem(
    'Proses pencairan dana',
    'Proses pencairan dana akan diproses dalam jangka waktu 1–3 hari kerja '
    'setelah pengajuan disetujui oleh admin. Dana akan ditransfer langsung ke '
    'rekening bank yang telah Anda daftarkan pada data top up.',
  ),
  FaqItem(
    'Lupa Password',
    'Jika pengguna KoopCare melupakan kata sandi, lakukan pemulihan melalui '
    'halaman login dengan langkah berikut:\n'
    '1. Tap tombol "Lupa Password" di halaman login\n'
    '2. Masukkan nomor WhatsApp/NIK terdaftar\n'
    '3. Verifikasi identitas melalui OTP (kode 6 digit)\n'
    '4. Buat kata sandi baru\n'
    '5. Serta mengaktifkan keamanan 2FA, fingerprint, facial ID',
  ),
  FaqItem(
    'Apakah Data Saya Aman?',
    'KoopCare menggunakan enkripsi tingkat tinggi (AES-256) dan server bank '
    'lokal (AKS-256) dan mengikuti standar keamanan ISO 27001. Data anggota '
    'dilindungi secara akurat dengan keamanan 2FA, fingerprint, facial di '
    'setiap transaksi untuk memastikan keamanan data Anda selalu terjaga.',
  ),
  FaqItem(
    'Bagaimana Sistem Bekerja',
    'KoopCare bekerja dengan cara yang sederhana namun canggih untuk kebutuhan '
    'anggota koperasi. Menggunakan AI untuk setiap kondisi dan kebutuhan data '
    'anggota secara akurat.\n\n'
    'Setelah Anda mendaftarkan diri sebagai anggota koperasi, sistem akan '
    'menganalisis informasi Anda dan memberikan rekomendasi layanan yang sesuai. '
    'Semua proses layanan yang berjalan cukup singkat.',
  ),
];
