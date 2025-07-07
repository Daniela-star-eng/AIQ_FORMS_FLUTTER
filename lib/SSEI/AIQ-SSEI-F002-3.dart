import 'package:flutter/material.dart';
import 'package:interfaz_uno_aiq/SSEI/AIQ-SSEI-F002-4.dart';

class AIQSSEIF0023Screen extends StatefulWidget {
  @override
  State<AIQSSEIF0023Screen> createState() => _AIQSSEIF0023ScreenState();
}

class _AIQSSEIF0023ScreenState extends State<AIQSSEIF0023Screen> {
  final TextEditingController campo2Controller = TextEditingController();

  bool _errorCampo1 = false;

  String? _oficinaComandanciaSeleccion = '';
  String? _oficinaGuardiaSeleccion = '';
  String? _salaAcademiasSeleccion = '';
  String? _salaMaquinaSeleccion = '';
  String? _subEstacionElectricaSeleccion = '';
  String? _cocinaComedorSeleccion = '';
  String? _lavamanosSanitariosSeleccion = '';
  String? _sanitariosRegaderasSeleccion = '';
  String? _areaDescansoLockersSeleccion = '';
  String? _gimnasioSeleccion = '';
  String? _lockersSeleccion = '';
  String? _almacenesSeleccion = '';

  @override
  void dispose() {
    campo2Controller.dispose();
    super.dispose();
  }

  Widget _buildRadioBox({
  required String title,
  required String? groupValue,
  required Function(String?) onChanged,
  bool showError = false,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF263A5B),
            fontFamily: 'Avenir',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: ['OK', 'N/A'].map((option) {
            final bool isSelected = groupValue == option;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1F3A5F) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF598CBC) : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 4),
            child: Text(
              "Este campo es obligatorio",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF263A5B), size: 25),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                "REPORTE DE NOVEDADES",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Avenir',
                  color: Color(0xFF263A5B),
                ),
              ),
            ),
            const Text(
              "AIQ-SSEI-F002",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFF598CBC),
                fontFamily: 'Avenir',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Campos
            _buildRadioBox(
              title: "Oficina de Comandancia",
              groupValue: _oficinaComandanciaSeleccion,
              onChanged: (value) {
                setState(() {
                  _oficinaComandanciaSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),
            _buildRadioBox(
              title: "Oficina de Guardia",
              groupValue: _oficinaGuardiaSeleccion,
              onChanged: (value) {
                setState(() {
                  _oficinaGuardiaSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),
            _buildRadioBox(
              title: "Sala de Academias",
              groupValue: _salaAcademiasSeleccion,
              onChanged: (value) {
                setState(() {
                  _salaAcademiasSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),
            _buildRadioBox(
              title: "Sala de Máquina",
              groupValue: _salaMaquinaSeleccion,
              onChanged: (value) {
                setState(() {
                  _salaMaquinaSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),
            _buildRadioBox(
              title: "Sub-Estación Eléctrica",
              groupValue: _subEstacionElectricaSeleccion,
              onChanged: (value) {
                setState(() {
                  _subEstacionElectricaSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),
            _buildRadioBox(
              title: "Cocina / Comedor",
              groupValue: _cocinaComedorSeleccion,
              onChanged: (value) {
                setState(() {
                  _cocinaComedorSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),
            _buildRadioBox(
              title: "Lavamanos Sanitarios",
              groupValue: _lavamanosSanitariosSeleccion,
              onChanged: (value) {
                setState(() {
                  _lavamanosSanitariosSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),
            _buildRadioBox(
              title: "Sanitarios y Regaderas",
              groupValue: _sanitariosRegaderasSeleccion,
              onChanged: (value) {
                setState(() {
                  _sanitariosRegaderasSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),
            _buildRadioBox(
              title: "Área de Descanso y Lockers",
              groupValue: _areaDescansoLockersSeleccion,
              onChanged: (value) {
                setState(() {
                  _areaDescansoLockersSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),
            _buildRadioBox(
              title: "Gimnasio",
              groupValue: _gimnasioSeleccion,
              onChanged: (value) {
                setState(() {
                  _gimnasioSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),
            _buildRadioBox(
              title: "Lockers Exteriores",
              groupValue: _lockersSeleccion,
              onChanged: (value) {
                setState(() {
                  _lockersSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),
            _buildRadioBox(
              title: "Almacenes 1, 2, 3, 4",
              groupValue: _almacenesSeleccion,
              onChanged: (value) {
                setState(() {
                  _almacenesSeleccion = value;
                  _errorCampo1 = false;
                });
              },
              showError: _errorCampo1,
            ),

            const SizedBox(height: 24),
Center(
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BitacoraScreen(),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF598CBC),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: const Text(
      "SIGUIENTE",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Avenir',
        color: Colors.white,
      ),
    ),
  ),
),
const SizedBox(height: 24),

          ],
        ),
      ),
    );
  }
}