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

  final Color naranjaOscuro = Color(0xFFE65100);
  final Color azulOscuro = Color(0xFF0D47A1);
  final Color blanco = Color(0xFFFFFFFF);
  final Color gris = Color(0xFF9E9E9E);

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
      backgroundColor: naranjaOscuro,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: blanco.withOpacity(0.95),
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
                    color: naranjaOscuro,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: fullNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    labelStyle: TextStyle(color: gris),
                    prefixIcon: Icon(Icons.person, color: azulOscuro),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: idNumberCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Número de identidad',
                    labelStyle: TextStyle(color: gris),
                    prefixIcon: Icon(Icons.badge, color: azulOscuro),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: gris),
                    prefixIcon: Icon(Icons.email, color: azulOscuro),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: gris),
                    prefixIcon: Icon(Icons.lock, color: azulOscuro),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azulOscuro,
                    foregroundColor: blanco,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? CircularProgressIndicator(color: blanco)
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
