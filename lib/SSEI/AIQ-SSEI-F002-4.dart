import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class BitacoraScreen extends StatefulWidget {
  @override
  State<BitacoraScreen> createState() => _BitacoraScreenState();
}

class _BitacoraScreenState extends State<BitacoraScreen> {
  final List<TimeOfDay?> horas = [null];
  final List<TextEditingController> descripciones = [TextEditingController()];
  final List<bool> errores = [false];

  Future<void> _seleccionarHora(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horas[index] ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        horas[index] = picked;
      });
    }
  }

  String _formatHora(TimeOfDay? hora) {
    if (hora == null) return "Hora";
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, hora.hour, hora.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  void _agregarActividad() {
    setState(() {
      horas.add(null);
      descripciones.add(TextEditingController());
      errores.add(false);
    });
  }

  void _guardar() {
    bool hayError = false;
    setState(() {
      for (int i = 0; i < descripciones.length; i++) {
        errores[i] = descripciones[i].text.trim().isEmpty;
        if (errores[i]) hayError = true;
      }
    });

    if (!hayError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Actividades registradas")),
      );

      _generarPdf(); // Generar y mostrar PDF
    }
  }

  Future<void> _generarPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Bitácora de Actividades', style: pw.TextStyle(fontSize: 24)),
          ),
          pw.Table.fromTextArray(
            headers: ['Hora', 'Descripción'],
            data: List.generate(horas.length, (i) {
              final hora = horas[i] != null
                  ? _formatHora(horas[i])
                  : 'Sin hora';
              final desc = descripciones[i].text.trim();
              return [hora, desc];
            }),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Widget _buildActividadItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Hora
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _seleccionarHora(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatHora(horas[index]),
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontSize: 14,
                        color: horas[index] == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const Icon(Icons.access_time, color: Color(0xFF598CBC)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Descripción
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(12),
                border: errores[index] ? Border.all(color: Colors.red) : null,
              ),
              child: TextField(
                controller: descripciones[index],
                decoration: InputDecoration(
                  hintText: "Descripción",
                  hintStyle: const TextStyle(fontFamily: 'Avenir'),
                  border: InputBorder.none,
                ),
              ),
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón de regresar
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF263A5B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 8),

                  // Título
                  Row(
                    children: const [
                      Icon(Icons.note_alt, size: 30, color: Color(0xFF598CBC)),
                      SizedBox(width: 8),
                      Text(
                        "Bitácora de Actividades",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Avenir',
                          color: Color(0xFF263A5B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Actividades
                  ...List.generate(horas.length, (index) => _buildActividadItem(index)),
                  const SizedBox(height: 16),

                  // Agregar actividad
                  TextButton.icon(
                    onPressed: _agregarActividad,
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF598CBC)),
                    label: const Text(
                      "Agregar otra actividad",
                      style: TextStyle(
                        color: Color(0xFF598CBC),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Avenir',
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón guardar
                  Center(
                    child: ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF598CBC),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "GUARDAR",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Avenir',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),

          // Logo
          Positioned(
            bottom: 16,
            right: 16,
            child: SizedBox(
              width: 150,
              height: 60,
              child: Image.asset(
                'assets/AIQ_LOGO_.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}