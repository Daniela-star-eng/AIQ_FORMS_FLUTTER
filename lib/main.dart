import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'login-department.dart';
import 'internet_check_stub.dart'
  if (dart.library.html) 'internet_check_web.dart'
  if (dart.library.io) 'internet_check_mobile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <-- Importa tus opciones aquí

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animación Lottie',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform, // <-- Usa las opciones aquí
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra animación de carga mientras se inicializa Firebase
            return Scaffold(
backgroundColor: const Color(0xFFE8EAF2),
              body: Center(
                child: Lottie.asset('assets/avion.json', width: 300, fit: BoxFit.contain),
              ),
            );
          } else if (snapshot.hasError) {
            // Muestra error si falla la inicialización
            return Scaffold(
              body: Center(child: Text('Error al inicializar Firebase: ${snapshot.error}')),
            );
          }
          // Cuando Firebase está listo, muestra tu pantalla normal
          return const AnimationScreen();
        },
      ),
    );
  }
}

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> {
  String? error;

  @override
  void initState() {
    super.initState();
    _checkConnectionAndNavigate();
  }

  Future<void> _checkConnectionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 4));

    bool connected = false;

    try {
      connected = await hasInternetConnection() == true;
    } catch (e) {
      debugPrint('Error checking internet: $e');
      connected = false;
    }

    if (!mounted) return;

    if (connected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginDepartmentPage()),
      );
    } else {
      setState(() {
        error = "No tienes conexión a Internet.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E4E0),
      body: Center(
        child: error == null
            ? Lottie.asset('assets/avion.json', width: 300, fit: BoxFit.contain)
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(error!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => error = null);
                      _checkConnectionAndNavigate();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
      ),
    );
  }
}