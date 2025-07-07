import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interfaz_uno_aiq/coleccion.dart';
import 'package:interfaz_uno_aiq/forms_select_ssei.dart';
import 'package:interfaz_uno_aiq/forms_select_fauna.dart';
import 'package:interfaz_uno_aiq/forms_select_ops.dart';
import 'package:interfaz_uno_aiq/coleccion.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class LoginDepartmentPage extends StatefulWidget {
  const LoginDepartmentPage({Key? key}) : super(key: key);

  @override
  State<LoginDepartmentPage> createState() => _LoginDepartmentPageState();
}

class _LoginDepartmentPageState extends State<LoginDepartmentPage> {
  final TextEditingController _controller = TextEditingController();
  

  // Configuración dinámica por ID
  final Map<String, Map<String, dynamic>> _config = {
    'COOKIES': {
      'saludo': '¡HOLA ADMINISTRADOR!',
      'icon': Icons.admin_panel_settings,
      'color': const Color(0xFF101A33),
      'hint': 'COOKIES',
      'departamento': 'JEFATURA DE DEPARTAMENTO\n DE OPERACIONES\nY SERVICIOS',
      'departamentoColor': Color(0xFF63708B),
      'departamentoFontSize': 27.0,
      'saludoFontSize': 37.0, // <--- tamaño estándar
    },
    'AIQ-OPS-AIR380': {
      'saludo': '¡HOLA OFICIAL DE OPERACIONES!',
      'icon': Icons.airplanemode_active,
      'color': const Color(0xFF263A5B),
      'hint': 'AIQ-OPS-AIR380',
      'departamento': 'OPERACIONES Y \nSERVICIOS',
      'departamentoColor': Color(0xFF598CBC),
      'departamentoFontSize': 28.0,
      'saludoFontSize': 37.0, // <--- tamaño estándar
    },
    'AIQ-AMB-KARELY': {
      'saludo': '¡HOLA CONTROLADOR DE FAUNA!',
      'icon': Icons.pest_control_rodent_sharp,
      'color': const Color(0xFF65CC32),
      'hint': 'AIQ-AMB-KARELY',
      'departamento': 'CONTROL DE \nFAUNA',
      'departamentoColor': Color(0xFF428520),
      'departamentoFontSize': 32.0,
      'saludoFontSize': 37.0, // <--- tamaño estándar
    },
    'AIQ-SSEI-OSHKOSH': {
      'saludo': '¡HOLA BOMBERO!',
      'icon': Icons.fire_truck_sharp,
      'color': const Color(0xFFC22727),
      'hint': 'AIQ-SSEI-OSHKOSH',
      'departamento': 'SERVICIO DE SALVAMENTO \n Y EXTINCIÓN DE \nINCENDIOS',
      'departamentoColor': Color(0xFFFF1D1D),
      'departamentoFontSize': 23.0,
      'saludoFontSize': 44.0, // <--- tamaño más grande para SSEI
    },
  };

  String? _currentId;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        // Normaliza el ID a mayúsculas y sin espacios extra
        _currentId = _controller.text.trim().toUpperCase();
      });
    });
  }

  void _onComenzar() {
    final id = _currentId?.trim().toUpperCase();
    switch (id) {
      case 'COOKIES':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ColeccionesScreen()),
        );
        break;
      case 'AIQ-OPS-AIR380':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormularioScreenOPS()),
        );
        break;
      case 'AIQ-AMB-KARELY':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormularioScreenFauna()),
        );
        break;
      case 'AIQ-SSEI-OSHKOSH':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormularioScreenSSEI()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID de departamento inválido')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config[_currentId] ?? {
      'saludo': '¡BIENVENIDO A\nAIQ FORMS,\nIDENTIFICATE!',
      'icon': Icons.apartment,
      'color': const Color(0xFF6B97C7),
      'hint': 'Departamento ID',
      'departamento': 'DEPARTAMENTO DE\nOPERACIONES Y\nSERVICIOS',
      'departamentoColor': const Color(0xFF2D3A4A),
      'departamentoFontSize': 24.0,
      'saludoFontSize': 37.0, // tamaño por defecto
    };

    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF1),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
             const SizedBox(width: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 32, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero, 
                    constraints: const BoxConstraints(), 
                  ),
                     Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                      config['saludo'],
                      style: TextStyle(
                        color: config['color'],
                        fontWeight: FontWeight.bold,
                        fontSize: config['saludoFontSize'],
                        height: 1,
                      ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                      config['departamento'],
                      style: TextStyle(
                        color: config['departamentoColor'],
                        fontWeight: FontWeight.bold,
                        fontSize: config['departamentoFontSize'],
                        height: 1.1,
                        letterSpacing: 0.5,
                      ),
                      ),
                    ],
                    ),
                  ),
                  ],
                ),
                const SizedBox(height: 70),
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: config['color'],
                    child: Icon(config['icon'], size: 60, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 36),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _controller,
                        inputFormatters: [UpperCaseTextFormatter()],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: const Icon(Icons.person, color: Colors.grey),
                          hintText: config['hint'],
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: config['color'],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    ),
                    onPressed: _onComenzar,
                    child: const Text(
                      'COMENZAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 27,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}