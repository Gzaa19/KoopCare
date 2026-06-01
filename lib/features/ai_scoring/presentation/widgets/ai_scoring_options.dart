/// Dropdown option lists for the AI scoring multi-step form.
///
/// These are the **Indonesian display labels** the user picks. The mapping
/// from labels to BE API field values lives in
/// `data/datasources/ai_scoring_field_mapper.dart` — keep these two in sync
/// when adding new options.
///
/// Removed from UI (handled by BE / not needed):
/// - `kAsetLainnya`       — no matching DB column; collateral derived from own_car/own_realty
/// - `kJumlahPinjaman`    — comes from PengajuanPembiayaanPage as a free-text amount
library;

const List<String> kJenisKelamin = ['Laki-laki', 'Perempuan'];

const List<String> kTanggalLahir = [
  '< 25 tahun',
  '25–35 tahun',
  '36–45 tahun',
  '> 45 tahun',
];

const List<String> kPendidikan = ['SD', 'SMP', 'SMA/SMK', 'D3', 'S1', 'S2/S3'];

const List<String> kStatusNikah = ['Belum Menikah', 'Menikah', 'Cerai'];

const List<String> kPunyaProperti = [
  'Ya',
  'Tidak',
];

const List<String> kPunyaKendaraan = [
  'Ya',
  'Tidak',
];

const List<String> kSumberPenghasilan = [
  'Karyawan (Working)',
  'Pengusaha / Wiraswasta (Commercial Associate)',
  'Pensiunan (Pensioner)',
  'Tidak Bekerja (Unemployed)',
  'Ibu Rumah Tangga (State Servant)',
];

const List<String> kJenisPekerjaan = [
  'Buruh (Laborers)',
  'Staf Penjualan (Sales Staff)',
  'Staf Inti (Core Staff)',
  'Manajer (Managers)',
  'Driver',
  'Staf Akuntansi (Accountants)',
  'Petugas Medis (Medicine Staff)',
  'Staf Keamanan (Security Staff)',
  'Pekerja Masak (Cooking Staff)',
  'Pekerja Kebersihan (Cleaning Staff)',
  'Agen Properti (Realty Agents)',
  'Pekerja HR (HR Staff)',
  'IT Staff',
  'Sekretaris (Secretaries)',
  'Penjaga (Waiters/Barmen Staff)',
  'Pekerja Swasta Rendah (Low-skill Laborers)',
  'Tidak Diketahui / Lainnya',
];

const List<String> kTanggungan = ['0', '1', '2', '3', '4', '5+'];

const List<String> kPendapatan = [
  '< Rp 1.000.000',
  'Rp 1–3 juta',
  'Rp 3–5 juta',
  'Rp 5–7 juta',
  '> Rp 7 juta',
];

const List<String> kLamaBekerja = [
  '< 1 tahun',
  '1–3 tahun',
  '3–5 tahun',
  '> 5 tahun',
];

const List<String> kLamaNomorHp = [
  '< 6 bulan',
  '6–12 bulan',
  '1–2 tahun',
  '> 2 tahun',
];
