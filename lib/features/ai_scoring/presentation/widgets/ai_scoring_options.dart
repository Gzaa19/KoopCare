/// Dropdown option lists for the AI scoring multi-step form.
///
/// These are the **Indonesian display labels** the user picks. The mapping
/// from labels to ML API field values lives in
/// `data/datasources/ai_scoring_field_mapper.dart` — keep these two in sync
/// when adding new options.
const List<String> kJenisKelamin = ['Laki-laki', 'Perempuan'];

const List<String> kTanggalLahir = [
  '< 25 tahun',
  '25–35 tahun',
  '36–45 tahun',
  '> 45 tahun',
];

const List<String> kPendidikan = ['SD', 'SMP', 'SMA/SMK', 'D3', 'S1', 'S2/S3'];

const List<String> kStatusNikah = ['Belum Menikah', 'Menikah', 'Cerai'];

const List<String> kStatusTempat = [
  'Milik Pribadi',
  'Kontrak/Sewa',
  'Rumah Orang Tua',
  'Dinas',
];

const List<String> kTransportasi = [
  'Motor',
  'Mobil',
  'Motor & Mobil',
  'Tidak Ada',
];

const List<String> kJenisPekerjaan = [
  'PNS',
  'Swasta',
  'Wiraswasta',
  'Freelance',
  'Tidak Bekerja',
];

const List<String> kSumberPenghasilan = ['Gaji', 'Usaha', 'Investasi', 'Lainnya'];

const List<String> kAsetLainnya = [
  'Tidak Ada',
  'TV DST',
  'Elektronik',
  'Tanah',
  'Kendaraan',
];

const List<String> kTanggungan = ['0', '1', '2', '3', '4', '5+'];

const List<String> kPendapatan = [
  '< Rp 1.000.000',
  'Rp 1–3 juta',
  'Rp 3–5 juta',
  'Rp 5–7 juta',
  '> Rp 7 juta',
];

const List<String> kJumlahPinjaman = [
  'Rp 500.000',
  'Rp 1.000.000',
  'Rp 3.000.000',
  'Rp 5.000.000',
  'Rp 10.000.000',
];
