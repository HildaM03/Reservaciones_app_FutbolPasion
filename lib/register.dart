import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullNameCtrl = TextEditingController();
  final idNumberCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final Color navyBlue = Color(0xFF001F3F);
  final Color brightBlue = Color(0xFF00BFFF);

  bool _loading = false;

  Future<void> register() async {
    final fullName = fullNameCtrl.text.trim();
    final idNumber = idNumberCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (fullName.isEmpty || idNumber.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage('Por favor, complete todos los campos.');
      return;
    }

    if (idNumber.length < 8) {
      showMessage('El número de identidad debe tener al menos 8 dígitos');
      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar nombre completo en displayName también
      await userCredential.user!.updateDisplayName(fullName);

      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombreCompleto': fullName,
        'numeroIdentidad': idNumber,
        'correo': email,
        'fechaRegistro': Timestamp.now(),
      });

      showMessage('✅ Registro exitoso');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      showMessage('Error: ${e.message}');
    } finally {
      setState(() => _loading = false);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyBlue,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Registro',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: navyBlue,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: fullNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person, color: navyBlue),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: idNumberCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Número de identidad',
                    prefixIcon: Icon(Icons.badge, color: navyBlue),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email, color: navyBlue),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock, color: navyBlue),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brightBlue,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text('Registrarse', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
