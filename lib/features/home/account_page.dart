import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Simpanan"),
          BottomNavigationBarItem(icon: Icon(Icons.handshake), label: "Cicilan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 🔥 penting (bawah besar)
          children: [
            // HEADER
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.purple,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("KoopCare",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("M.ERSA",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Anggota Aktif",
                        style: TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            // CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Total Saldo Top Up",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 5),
                  Text("Rp 3.500.000 (updated)",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Total Pembiayaan",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 5),
                  Text("Rp 1.000.000",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _menu("General info"),
            _menu("Pengaturan Keamanan"),
            _menu("Pengaturan Notifikasi"),
            _menu("Rekening Bank / Kartu"),
            _menu("FAQ"),
            _menu("Hubungi Kami"),
          ],
        ),
      ),
    );
  }

  Widget _menu(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}