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
      backgroundColor: const Color(0xFFE9EBF3),
      body: Stack(
        children: [
          // Contenido principal
          SafeArea(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding solo para el encabezado
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_back_ios, size: 30),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'COLECCIONES',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C2B52),
                              fontFamily: 'Avenir',
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'DEPARTAMENTO\nDE OPS',
                            style: TextStyle(
                              fontSize: 25,
                              color: Color(0xFF5C7CA5),
                              fontFamily: 'Avenir',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Padding solo para los botones
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Column(
                    children: [
                      SlideAction(
                        height: 90,
                        text: 'OPS',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          fontFamily: 'Avenir',
                        ),
                        outerColor: const Color(0xFF5181B9),
                        innerColor: const Color(0xFF1C2B52),
                        sliderButtonIcon: const Icon(Icons.flight, color: Colors.white, size: 48),
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
                      const SizedBox(height: 20),
                      SlideAction(
                        height: 90,
                        text: 'FAUNA',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          fontFamily: 'Avenir',
                        ),
                        outerColor: const Color(0xFFFFA726),
                        innerColor: const Color(0xFF5D3B1E),
                        sliderButtonIcon: const Icon(Icons.pest_control_rodent_rounded, color: Colors.white, size: 48),
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
                      const SizedBox(height: 20),
                      SlideAction(
                        height: 90,
                        text: 'SSEI',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          fontFamily: 'Avenir',
                        ),
                        outerColor: const Color(0xFFF44336),
                        innerColor: const Color(0xFF651919),
                        sliderButtonIcon: const Icon(Icons.local_fire_department, color: Colors.white, size: 48),
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
