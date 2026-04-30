import 'package:flutter/material.dart';
import 'pin_success_page.dart';

class CreatePinPage extends StatefulWidget {
  const CreatePinPage({super.key});

  @override
  State<CreatePinPage> createState() => _CreatePinPageState();
}

class _CreatePinPageState extends State<CreatePinPage> {
  final List<TextEditingController> pin = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<TextEditingController> confirm = List.generate(
    6,
    (_) => TextEditingController(),
  );

  Widget buildBox(List<TextEditingController> list, int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: list[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        obscureText: true,
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: const Color(0xFFE5E5E5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6B7F3F)),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  String getPin(List<TextEditingController> list) {
    return list.map((e) => e.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // BACK BUTTON
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                ),

                const SizedBox(height: 30),

                // ICON
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7F3F),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // TITLE
                const Center(
                  child: Text(
                    "Akun anda sudah aktif!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    "Buat 6-digit PIN Keamanan.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                const SizedBox(height: 30),

                // BUAT PIN
                const Text(
                  "Buat PIN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => buildBox(pin, i)),
                ),

                const SizedBox(height: 30),

                // KONFIRMASI PIN
                const Text(
                  "Konfirmasi PIN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => buildBox(confirm, i)),
                ),

                const SizedBox(height: 40),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      String pinValue = getPin(pin);
                      String confirmValue = getPin(confirm);

                      if (pinValue.length != 6 || confirmValue.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("PIN harus 6 digit")),
                        );
                        return;
                      }

                      if (pinValue != confirmValue) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("PIN tidak sama")),
                        );
                        return;
                      }

                      //  PIN SUCCESS PAGE
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PinSuccessPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7F3F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Simpan & Lanjut",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
