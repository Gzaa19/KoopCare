import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primary = const Color(0xFF6B7F3F);

  int currentIndex = 0;
  bool showSaldo = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: currentIndex == 3 ? buildAccountPage() : buildHomePage(),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 15, top: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              bottomItem(Icons.home, "Beranda", 0),
              bottomItem(Icons.account_balance_wallet_outlined, "Simpanan", 1),
              bottomItem(Icons.handshake_outlined, "Cicilan", 2),
              bottomItem(Icons.person_outline, "Akun", 3),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HOME =================
  Widget buildHomePage() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [

                // HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7EBD9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("KoopCare",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Icon(Icons.notifications_none),
                        ],
                      ),

                      const SizedBox(height: 20),

                   Row(
  children: [
    const CircleAvatar(radius: 25),
    const SizedBox(width: 12),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("M.ERSA",
            style: const TextStyle(
                fontWeight: FontWeight.bold)),
        const Text("Anggota Aktif"),
      ],
    )
  ],
),

                      const SizedBox(height: 20),

                      // SALDO
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text("Total Saldo Top Up",
                                    style: TextStyle(
                                        color: Colors.white70)),
                                Text(
                                  showSaldo
                                      ? "Rp 3.500.000"
                                      : "Rp •••••••",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showSaldo = !showSaldo;
                                });
                              },
                              child: const Icon(Icons.remove_red_eye,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // MENU
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: const [
                      MenuItem(Icons.account_balance_wallet, "Top Up"),
                      MenuItem(Icons.handshake_outlined,
                          "Ajukan\nPinjaman"),
                      MenuItem(Icons.send, "Transfer"),
                      MenuItem(Icons.history, "Riwayat"),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // PEMBIAYAAN
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text("Pembiayaan Aktif",
                            style: TextStyle(
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text(
                            "Produk : Murabahah - JAK0100"),
                        const SizedBox(height: 15),

                        Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "Jadwal & Bayar # AKD100",
                              style: TextStyle(
                                  color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= ACCOUNT (FIXED) =================
  Widget buildAccountPage() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [

        // HEADER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          color: const Color(0xFFE7EBD9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: const [
                  CircleAvatar(radius: 18),
                  SizedBox(width: 10),
                  Text("KoopCare",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: const [
                  CircleAvatar(radius: 25),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("M.ERSA",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Anggota Aktif"),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text("Total Saldo Top Up",
                            style: TextStyle(color: Colors.white70)),
                        Text("Rp 3.500.000 (updated)",
                            style: TextStyle(color: Colors.white)),
                        SizedBox(height: 5),
                        Text("Total Pembiayaan",
                            style: TextStyle(color: Colors.white70)),
                        Text("Rp 1.000.000",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Icon(Icons.remove_red_eye, color: Colors.white)
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // MENU
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: const [
                AccountItem("General info"),
                Divider(height: 1),
                AccountItem("Pengaturan Keamanan"),
                Divider(height: 1),
                AccountItem("Pengaturan Notifikasi"),
                Divider(height: 1),
                AccountItem("Rekening Bank / Kartu"),
                Divider(height: 1),
                AccountItem("FAQ"),
                Divider(height: 1),
                AccountItem("Hubungi Kami"),
                Divider(height: 1),
                AccountItem("Suka? Nilai kami"),
              ],
            ),
          ),
        ),

        const SizedBox(height: 100), // 🔥 penting
      ],
    );
  }

  // ================= BOTTOM =================
  Widget bottomItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 26,
              color: currentIndex == index
                  ? primary
                  : Colors.black54),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                color: currentIndex == index
                    ? primary
                    : Colors.black54,
              )),
        ],
      ),
    );
  }
}

// ================= COMPONENT =================
class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const MenuItem(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF6B7F3F);

    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            border: Border.all(color: primary),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, size: 30, color: primary),
        ),
        const SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12))
      ],
    );
  }
}

class AccountItem extends StatelessWidget {
  final String title;

  const AccountItem(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}