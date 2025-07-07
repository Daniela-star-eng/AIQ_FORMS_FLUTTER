import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:interfaz_uno_aiq/SSEI/AIQ-SSEI-F002.dart';

// Cambia los colores rojos por azules
// Puedes ajustar los tonos de azul según tu preferencia

// Ejemplo de azul principal
const azulPrincipal = Color(0xFF598CBC);
const azulOscuro = Color(0xFF263A5B);

class FormularioScreenSSEI extends StatefulWidget {
  const FormularioScreenSSEI({super.key});

  @override
  State<FormularioScreenSSEI> createState() => _FormularioScreenSSEIState();
}

class _FormularioScreenSSEIState extends State<FormularioScreenSSEI> {
  final List<Map<String, String>> formularios = const [
    {
      "titulo": "PARTE DE NOVEDADES - BITACORA - CAMBIO DE TURNO",
      "codigo": "AIQ-SSEI-F002",
      "imagen": "assets/AIQ-SSEI-F002-FORM-PREVIEW.jpg",
    },
    {
      "titulo": "FORM 8",
      "codigo": "AIQ-SSEI-F002-2",
      "imagen": "assets/AIQ-SSEI-F002-FORM-PREVIEW.jpg",
    },
     
  ];

  int _currentIndex = 0;
  int _selectedMenu = 0; // <-- Nuevo índice para el menú

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
                  color: azulPrincipal, // Cambiado a azul
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
                      color: azulOscuro, // Cambiado a azul oscuro
                    ),
                  ),
                  TextSpan(
                    text: "FORMULARIO\n",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir',
                      color: azulPrincipal, // Cambiado a azul principal
                    ),
                  ),
                  TextSpan(
                    text: "SSEI",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir',
                      color: azulOscuro, // Cambiado a azul oscuro
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
                const SizedBox(height: 100), // Espacio entre el título y el carrusel
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
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final form = formularios[index];
                    return GestureDetector(
                      onTap: () {
                        if (index == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AIQSSEIF002Screen()),
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
                            ? azulOscuro // Cambiado a azul oscuro
                            : Colors.grey[300],
                      ),
                    );
                  }),
                ),
                // Footer TBIB
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
        // Aquí puedes navegar a la pantalla de historial o mostrar un mensaje
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
        selectedItemColor: azulPrincipal, // Cambiado a azul principal
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}
