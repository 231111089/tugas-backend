import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class SecurtyCode extends StatefulWidget {
  final String phoneNumber;

  const SecurtyCode({super.key, required this.phoneNumber});

  @override
  State<SecurtyCode> createState() => _SecurtyCodeState();
}

class _SecurtyCodeState extends State<SecurtyCode> {
  final _formKey = GlobalKey<FormState>();
  String _enteredCode = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.white,
          ),
          title: const Text(
            "Security Code",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Masukkan Security Code Anda saat ini",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Security Code digunakan untuk masuk ke akun Anda dan bertransaksi",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    autoFocus: true,
                    keyboardType: TextInputType.number,
                    textStyle: TextStyle(fontSize: 20),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      fieldHeight: 50,
                      fieldWidth: 40,
                      inactiveColor: Colors.black,
                      activeColor: Colors.deepPurple,
                      selectedColor: Colors.deepPurple,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _enteredCode = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Masukkan kode verifikasi terlebih dahulu';
                      }
                      if (value.length < 6) {
                        return 'Kode harus 6 digit';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        // Validasi PIN
                        if (_enteredCode.length == 6) {
                          bool result = await createAccount(_enteredCode);
                          if (result) {
                            // Navigasi ke halaman berikutnya
                            Navigator.pushReplacementNamed(context, '/home');
                          } else {
                            // Tampilkan pesan error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal membuat akun. Silakan coba lagi.')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('PIN harus 6 digit')),
                          );
                        }
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> createAccount(String pin) async {
    // Proses pembuatan akun, misal simpan ke database atau panggil API
    try {
      // Contoh: simpan ke database lokal
      // await DatabaseHelper.instance.insertUser(pin);
      return true;
    } catch (e) {
      return false;
    }
  }
}
