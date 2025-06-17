import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notificaciones_reservas_screen.dart';
import 'register_admin.page.dart';

class AppColors {
  static const Color azulElectrico = Color(0xFF0D47A1);
  static const Color naranjaFuerte = Color(0xFFFF6F00);
  static const Color blanco = Colors.white;
  static final Color grisClaro = Colors.grey.shade300;
}

class LoginAdminPage extends StatefulWidget {
  final String? initialEmail;

  const LoginAdminPage({
    Key? key,
    this.initialEmail,
  }) : super(key: key);

  @override
  State<LoginAdminPage> createState() => _LoginAdminPageState();
}

class _LoginAdminPageState extends State<LoginAdminPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('savedEmail') ?? '';
        _passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('savedEmail', _emailController.text.trim());
      await prefs.setString('savedPassword', _passwordController.text.trim());
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
      await prefs.setBool('rememberMe', false);
    }
  }

  Future<void> _loginAdmin() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Por favor complete todos los campos correctamente', AppColors.naranjaFuerte);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final adminQuery = await _firestore
          .collection('administradores')
          .where('correo', isEqualTo: _emailController.text.trim())
          .limit(1)
          .get();

      if (adminQuery.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'not-admin',
          message: 'No tienes permisos de administrador',
        );
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final adminDoc = adminQuery.docs.first;
      if (adminDoc['uid'] != userCredential.user!.uid) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'uid-mismatch',
          message: 'Error de coincidencia en los registros',
        );
      }

      if (adminDoc['rol']?.toString().toLowerCase() != 'admin') {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'invalid-role',
          message: 'No tienes el rol de administrador',
        );
      }

      await _saveCredentials();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => NotificacionesReservasScreen(
              adminId: userCredential.user!.uid,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      }

      _showSnackBar('✅ Sesión de administrador iniciada correctamente', AppColors.azulElectrico);
    } on FirebaseAuthException catch (e) {
      _handleLoginError(e);
    } catch (e) {
      _showSnackBar('Error inesperado: $e', AppColors.naranjaFuerte);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Ingrese su correo para recuperar contraseña', AppColors.naranjaFuerte);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      _showSnackBar('Correo de recuperación enviado', AppColors.azulElectrico);
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Error: ${e.message}', AppColors.naranjaFuerte);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleLoginError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'Usuario no encontrado';
        break;
      case 'wrong-password':
        errorMessage = 'Contraseña incorrecta';
        break;
      case 'invalid-email':
        errorMessage = 'Correo electrónico inválido';
        break;
      case 'user-disabled':
        errorMessage = 'Usuario deshabilitado';
        break;
      case 'not-admin':
        errorMessage = 'No tienes permisos de administrador';
        break;
      case 'invalid-role':
        errorMessage = 'No tienes el rol de administrador';
        break;
      case 'uid-mismatch':
        errorMessage = 'Error en los registros de usuario';
        break;
      case 'too-many-requests':
        errorMessage = 'Demasiados intentos. Intente más tarde';
        break;
      case 'network-request-failed':
        errorMessage = 'Error de conexión. Verifique su internet';
        break;
      default:
        errorMessage = 'Error al iniciar sesión: ${e.message}';
    }
    _showSnackBar(errorMessage, AppColors.naranjaFuerte);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administracion Futbol Pasión'),
        backgroundColor: AppColors.azulElectrico,
      ),
      body: Container(
        color: AppColors.grisClaro,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                Icon(Icons.admin_panel_settings, size: 80, color: AppColors.naranjaFuerte),
                const SizedBox(height: 20),
                Text(
                  'Panel de Administración',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulElectrico,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: AppColors.azulElectrico),
                    prefixIcon: Icon(Icons.email, color: AppColors.naranjaFuerte),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.naranjaFuerte, width: 2),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.blanco,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su correo';
                    }
                    if (!value.contains('@')) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: AppColors.azulElectrico),
                    prefixIcon: Icon(Icons.lock, color: AppColors.naranjaFuerte),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.azulElectrico,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.naranjaFuerte, width: 2),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.blanco,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    if (value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      activeColor: AppColors.naranjaFuerte,
                    ),
                    const Text('Recordarme'),
                    const Spacer(),
                    TextButton(
                      onPressed: _resetPassword,
                      child: Text(
                        '¿Olvidó su contraseña?',
                        style: TextStyle(color: AppColors.naranjaFuerte),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azulElectrico, // fondo azul
                    foregroundColor: Colors.white, // texto blanco
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('INICIAR SESIÓN'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿No tienes cuenta?"),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterAdminPage()),
                      ),
                      child: Text(
                        'Regístrate',
                        style: TextStyle(color: AppColors.naranjaFuerte),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
