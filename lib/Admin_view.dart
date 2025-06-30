import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:interfaz_uno_aiq/main.dart';

void main() {
  runApp(const MaterialApp(
    home: MainMenu(),
    debugShowCheckedModeBanner: false,
  ));
}

// --- Pantalla Principal ---
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainApp();
  }
}

// --- Pantalla OPS ---
class OpsScreen extends StatelessWidget {
  const OpsScreen({super.key});

  void navigateToFauna(BuildContext context) {
    Navigator.of(context).push(_slidePageRoute(const FaunaBegining()));
  }

  @override
  Widget build(BuildContext context) {
    return _MainScreen(
      title: 'OPS',
      subtitle: 'OPERACIONES Y\nSERVICIOS',
      color: const Color(0xFF263A5B),
      titleStyle: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Color(0xFF263A5B),
        fontFamily: 'Avenir',
        height: 1.1,
        letterSpacing: 1.0,
      ),
      subtitleStyle: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w400,
        color: Color(0xFF598CBC),
        fontFamily: 'Avenir',
      ),
      icon: Transform.rotate(
        angle: math.pi / 2,
        child: const Icon(Icons.flight_rounded, size: 350, color: Colors.white),
      ), 
      onNext: () => navigateToFauna(context),
      circleColor: Color(0xFF263A5B), // Cambia el color del círculo aquí
      circleSize: 0.50,                // Cambia el tamaño del círculo aquí (0.7 = 70% del alto)
    );
  }
}

// --- Pantalla FAUNA ---
class FaunaBegining extends StatelessWidget {
  const FaunaBegining({super.key});

  void navigateToSSEI(BuildContext context) {
    Navigator.of(context).push(_slidePageRoute(const SseiBegining()));
  }

  @override
  Widget build(BuildContext context) {
    return _MainScreen(
      title: 'FAUNA',
      subtitle: 'CONTROL DE \nFAUNA',
      color: const Color(0xFF66CC32),
      titleStyle: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Color(0xFF66CC32), //botón
        fontFamily: 'Avenir',
        height: 1.1,
        letterSpacing: 1.0,
      ),
      subtitleStyle: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w400,
        color: Color(0xFF428520),
        fontFamily: 'Avenir',
      ),
      icon:  Icon(Icons.pest_control_rodent_rounded, size: 350, color: Colors.white),
      onNext: () => navigateToSSEI(context),
      circleColor: Color(0xFF66CC32), // Cambia el color del círculo aquí
      circleSize: 0.50,                // Cambia el tamaño del círculo aquí (0.7 = 70% del alto)
    );
  }
}

// --- Pantalla SSEI ---
class SseiBegining extends StatelessWidget {
  const SseiBegining({super.key});

  void navigateToOPS(BuildContext context) {
    Navigator.of(context).push(_slidePageRoute(const OpsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return _MainScreen(
      title: 'SSEI',
      subtitle: 'SERVICIO DE SALVAMENTO Y \nEXTINCIÓN DE INCENDIOS',
      color: const Color(0xFFC22727),
      titleStyle: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Color(0xFFC22727), //botón
        fontFamily: 'Avenir',
        height: 1.1,
        letterSpacing: 1.0,
      ),
      subtitleStyle: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w400,
        color: Color(0xFFFF1D1D),
        fontFamily: 'Avenir',
      ),
      icon:  Icon(Icons.local_fire_department_rounded, size: 350, color: Colors.white),
      onNext: () => navigateToOPS(context),
      circleColor: Color(0xFFC22727), // Cambia el color del círculo aquí
      circleSize: 0.50,                // Cambia el tamaño del círculo aquí (0.7 = 70% del alto)
    );
  }
}

// --- Pantalla Base Reutilizable ---
class _MainScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Widget icon;
  final VoidCallback onNext;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color? circleColor;      // Nuevo parámetro
  final double? circleSize;      // Nuevo parámetro (fracción del alto de pantalla)

  const _MainScreen({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onNext,
    this.titleStyle,
    this.subtitleStyle,
    this.circleColor,           // Nuevo
    this.circleSize,            // Nuevo
  });

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.height * (circleSize ?? 0.9);
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < -200) onNext();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE9EBF3),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 0), // Más separación de los bordes
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32), // Espacio superior para bajar la fila
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const MainMenu()),
                        (route) => false,
                      );
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 40,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12), // Espacio entre flecha y textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: titleStyle, textAlign: TextAlign.left),
                        const SizedBox(height: 8),
                        Text(subtitle, style: subtitleStyle, textAlign: TextAlign.left),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Stack(
                  children: [
                    Positioned(
                      left: -size * 0.33,
                      top: 42,
                      child: Container(
                        height: size,
                        width: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: circleColor ?? color,
                        ),
                        child: Center(child: icon),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: MediaQuery.of(context).size.height * 0.55 / 2 - 40, // Centra la flecha verticalmente (80/2=40)
                      child: GestureDetector(
                        onTap: onNext,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: color,
                          size: 80,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 90), // Espacio entre el icono y el botón
              Center(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir',
                    ),
                  ),
                  child: const Text('COMENZAR'),
                ),
              ),
              const SizedBox(height: 0), // Puedes ajustar el valor (ej: 60, 80, etc.)
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Transición sólo Slide ---
PageRouteBuilder _slidePageRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
      return SlideTransition(position: slide, child: child);
    },
  );
}
//bajar el texto y ubicarlo debajo del icono de flecha
//despegar el texto de los bordes de la pantalla