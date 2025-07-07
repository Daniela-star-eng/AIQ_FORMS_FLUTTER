import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:interfaz_uno_aiq/FAUNA/AIQ-AMB-F-003.dart';
import 'package:interfaz_uno_aiq/FAUNA/AIQ-AMB-F-005.dart';
import 'package:interfaz_uno_aiq/FAUNA/AIQ-AMB-F-004.dart';
import 'package:interfaz_uno_aiq/FAUNA/AIQ-AMB-F-001.dart';
import 'package:interfaz_uno_aiq/FAUNA/AIQ-AMB-F-002.dart';

const azulPrincipal = Color(0xFF598CBC);
const azulOscuro = Color(0xFF263A5B);

class FormularioScreenFauna extends StatefulWidget {
  const FormularioScreenFauna({super.key});

  @override
  State<FormularioScreenFauna> createState() => _FormularioScreenFaunaState();
}

class _FormularioScreenFaunaState extends State<FormularioScreenFauna> {
final List<Map<String, String>> formularios = const [
    {
      "titulo": "MONITOREO DE RESTOS DE FAUNA EN AREAS OPERATIVAS",
      "codigo": "AIQ-AMB-F-003",
      "imagen": "assets/AIQ-AMB-F-003-FORM-PREVIEW.jpg",
    },
    {
      "titulo": "NUEVO FORMULARIO",
      "codigo": "AIQ-AMB-F-004",
      "imagen": "assets/AIQ-AMB-F-004-FORM-PREVIEW.jpg",
    },
    {
      "titulo": "Formulario Fauna",
      "codigo": "AIQ-AMB-F-001",
      "imagen": "assets/AIQ-AMB-F-001-FORM-PREVIEW.jpg",
    },
    {
      "titulo": "FORMULARIO DE FAUNA Y HABITAD",
      "codigo": "AIQ-AMB-F-002",
      "imagen": "assets/AIQ-AMB-F-002-FORM-PREVIEW.jpg",
    },
    {
      "titulo": "MONITOREO DE AERONAVES",
      "codigo": "AIQ-AMB-F-005",
      "imagen": "assets/AIQ-AMB-F-005-FORM-PREVIEW.jpg",
    }
  ];


  int _currentIndex = 0;
  int _selectedMenu = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [

          // Botón de retroceso
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: azulPrincipal,
                ),
              ),
            ),
          ),

          // Título
          Positioned(
            top: 50,
            left: 60,
            right: 0,
            child: RichText(
              textAlign: TextAlign.left,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "ESCOGE UN\n",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir',
                      color: azulOscuro,
                    ),
                  ),
                  TextSpan(
                    text: "FORMULARIO\n",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir',
                      color: azulPrincipal,
                    ),
                  ),
                  TextSpan(
                    text: "AMB",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir',
                      color: azulOscuro,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Carrusel
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                CarouselSlider.builder(
                  itemCount: formularios.length,
                  options: CarouselOptions(
                    height: 580,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    viewportFraction: 0.8,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ), itemBuilder: (context, index, realIndex) {
                    final form = formularios[index];
                    return GestureDetector(
                      onTap: () {
                        if (index == 0) {
                          Navigator.push(
                            context,
                          MaterialPageRoute(builder: (context) => const AIQAMBF003Screen()),
                          );
                        } else if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AIQAMBF004Screen()),
                          );
                        } else if (index == 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AIQAMBF001Screen()),
                          );
                        } else if (index == 3) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AIQAMBF002Screen()),
                          );
                        } else if (index == 4) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AIQAMBF005Screen()),
                          );
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          form["imagen"]!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 260, // Ajusta la altura si lo deseas
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Indicadores
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(formularios.length, (index) {
                    return Container(
                      width: 10,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? azulOscuro
                            : Colors.grey[300],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedMenu,
        onTap: (index) {
          setState(() {
            _selectedMenu = index;
          });
          if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Historial de registros')),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
        selectedItemColor: azulPrincipal,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}