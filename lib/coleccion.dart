import 'package:flutter/material.dart';
import 'package:interfaz_uno_aiq/forms_select_fauna.dart';
import 'package:interfaz_uno_aiq/forms_select_ops.dart';
import 'package:interfaz_uno_aiq/forms_select_ssei.dart';
import 'package:slide_to_act/slide_to_act.dart';

class ColeccionesScreen extends StatelessWidget {
  const ColeccionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1934),
      body: Stack(
        children: [
          // Imagen en posición absoluta
          Positioned(
            top: 650,
            right: 185,
            child: Image.asset(
              'assets/FLYS.png', // Asegúrate de que la ruta sea correcta y esté en pubspec.yaml
              height: 200,
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COLECCIONES',
                            style: TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontFamily: 'Avenir',
                              height: 1.1,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const Text(
                            'DEPARTAMENTO\nDE OPS',
                            style: TextStyle(
                              fontSize: 35,
                              color: Color(0xFFB3DAFF),
                              fontFamily: 'Avenir',
                              height: 1.1,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 90),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      SlideAction(
                        height: 95,
                        text: 'OPS',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          fontFamily: 'Avenir',
                        ),
                        outerColor: const Color(0xFF96BFE6),
                        innerColor: const Color(0xFF1C2B52),
                        sliderButtonIcon:
                            const Icon(Icons.flight, color: Colors.white, size: 50),
                        elevation: 1,
                        onSubmit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FormularioScreenOPS(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      SlideAction(
                        height: 95,
                        text: 'AMB',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          fontFamily: 'Avenir',
                        ),
                        outerColor: const Color(0xFF598CBC),
                        innerColor: const Color(0xFF1C2B52),
                        sliderButtonIcon: const Icon(Icons.pest_control_rodent_rounded,
                            color: Colors.white, size: 50),
                        elevation: 1,
                        onSubmit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FormularioScreenFauna(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      SlideAction(
                        height: 95,
                        text: 'SSEI',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          fontFamily: 'Avenir',
                        ),
                        outerColor: const Color(0xFF3D6591),
                        innerColor: const Color(0xFF1C2B52),
                        sliderButtonIcon: const Icon(Icons.local_fire_department,
                            color: Colors.white, size: 50),
                        elevation: 1,
                        onSubmit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FormularioScreenSSEI(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
