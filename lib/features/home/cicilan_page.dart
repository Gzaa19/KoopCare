import 'package:flutter/material.dart';
import '../financial/pembayaran_detail_page.dart';

class DetailPembiayaanPage extends StatelessWidget {
  const DetailPembiayaanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      "Detail Pembiayaan",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "# AKD100",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Produk : Murabahah - Jual Beli",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),

                    _buildTable(),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (v) {},
                        ),
                        const Expanded(
                          child: Text(
                            "Aktifkan Autodebet Saldo Top Up",
                            style: TextStyle(fontSize: 14),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A8F45),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 350),
                            pageBuilder: (_, _, _) => const PembayaranDetailPage(),
                            transitionsBuilder: (_, anim, _, child) => SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: anim,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          ),
                        ),
                        child: const Text(
                          "Bayar Cicilan Sekarang",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    List<Map<String, String>> rows = [
      {"bln": "1", "tgl": "15 Nov 26", "nom": "BAYAR", "status": "Pending"},
      {"bln": "2", "tgl": "15 Nov 26", "nom": "Rp. 180.000", "status": "Due"},
      {"bln": "3", "tgl": "11 Oct 26", "nom": "Rp. 180.000", "status": "Due"},
      {"bln": "4", "tgl": "02 Oct 26", "nom": "Rp. 180.000", "status": "Due"},
      {"bln": "5", "tgl": "15 Nov 26", "nom": "Rp. 180.000", "status": "Due"},
      {"bln": "6", "tgl": "25 Dec 26", "nom": "Rp. 180.000", "status": "Due"},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(40),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
          3: FlexColumnWidth(),
        },
        border: const TableBorder(
          horizontalInside: BorderSide(color: Colors.black12),
        ),
        children: [
          _headerRow(),
          ...rows.map((r) => _dataRow(r)),
        ],
      ),
    );
  }

  TableRow _headerRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFF3F3F3)),
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Bln", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Jatuh Tempo", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Nominal", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  TableRow _dataRow(Map<String, String> r) {
    bool isBayar = r["nom"] == "BAYAR";

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(r["bln"]!),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(r["tgl"]!),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: isBayar
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A8F45),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "BAYAR",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Text(r["nom"]!),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            r["status"]!,
            style: TextStyle(
              color: r["status"] == "Pending" ? Colors.orange : Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}