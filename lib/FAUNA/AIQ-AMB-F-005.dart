import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleAuthClient extends BaseClient {
  final Map<String, String> _headers;
  final Client _client = Client();
  GoogleAuthClient(this._headers);
  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
  @override
  void close() {
    _client.close();
  }
}

Future<String?> subirPDFaDriveEnCarpeta(File pdfFile, String folderId) async {
  final googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );
  final account = await googleSignIn.signIn();
  if (account == null) return null;
  final authHeaders = await account.authHeaders;
  final authenticateClient = GoogleAuthClient(authHeaders);
  final driveApi = drive.DriveApi(authenticateClient);
  final media = drive.Media(pdfFile.openRead(), pdfFile.lengthSync());
  final driveFile = drive.File();
  driveFile.name = pdfFile.path.split('/').last;
  driveFile.parents = [folderId];
  final uploaded = await driveApi.files.create(
    driveFile,
    uploadMedia: media,
  );
  await driveApi.permissions.create(
    drive.Permission()
      ..type = 'anyone'
      ..role = 'reader',
    uploaded.id!,
  );
  return 'https://drive.google.com/file/d/${uploaded.id}/view?usp=sharing';
}

class AIQAMBF005Screen extends StatefulWidget {
  const AIQAMBF005Screen({super.key});

  @override
  State<AIQAMBF005Screen> createState() => _AIQAMBF005ScreenState();
}

class _AIQAMBF005ScreenState extends State<AIQAMBF005Screen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController campo1Controller = TextEditingController();
  final TextEditingController campo2Controller = TextEditingController();
  final TextEditingController campo3Controller = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController horaController = TextEditingController();
  String? dropdownSeleccionado;
  String? jaulaSeleccionada;
  final SignatureController firmaController = SignatureController(penStrokeWidth: 2, penColor: const Color(0xFF263A5B));

  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  bool _errorFirma = false;
  String? resultadoSeleccionado;

  int folio = 1;
  int consecutivoMostrado = 1;
  
  String? metodoControlSeleccionado;
  
  var campoMetodoOtroController;
  
  get folioGenerado => null;

  @override
  void dispose() {
    campo1Controller.dispose();
    campo2Controller.dispose();
    campo3Controller.dispose();
    fechaController.dispose();
    horaController.dispose();
    firmaController.dispose();
    super.dispose();
  }

  void guardarFormulario() async {
    setState(() {
      _errorFirma = firmaController.isEmpty;
    });

    if (_formKey.currentState!.validate() && !_errorFirma) {
      final folioGenerado = await generarFolio();
      await FirebaseFirestore.instance
          .collection('AIQ-AMB-F-005')
          .doc(folioGenerado)
          .set({
        'folio': folioGenerado,
        'fecha': fechaController.text,
        'hora': horaController.text,
        'Zona': campo1Controller.text,
        'Fauna': jaulaSeleccionada,
        'especie': campo2Controller.text,
        'resultado': resultadoSeleccionado,
        'nombre_prestador': campo3Controller.text,
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      // Generar PDF y subir a Drive
      const folderId = '1scs6kGvNf9zaoTyvDu-UFi8zNELbBZ19'; // <-- Cambia esto por el ID de tu carpeta de Drive
      String? driveLink;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(driveLink != null
              ? 'Formulario guardado y subido a Drive'
              : 'Formulario guardado, pero no se pudo subir a Drive'),
          action: driveLink != null
              ? SnackBarAction(
                  label: 'Ver PDF',
                  onPressed: () async {
                    // ignore: deprecated_member_use
                    await launch(driveLink!);
                  },
                )
              : null,
        ),
      );

      await _incrementarFolio();
    } else if (_errorFirma) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La firma es obligatoria')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarFolio();
  }

  Future<void> _cargarFolio() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      folio = prefs.getInt('folio_f005') ?? 1;
    });
  }

  Future<void> _incrementarFolio() async {
    final prefs = await SharedPreferences.getInstance();
    folio++;
    await prefs.setInt('folio_f005', folio);
    setState(() {});
  }

  Future<void> _compartirFormulario() async {
    await Share.share('Folio del formulario: $folio');
  }

  Future<int> obtenerConsecutivoParaFecha(DateTime fecha) async {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    final fechaStr = "$dia/$mes/$anio";

    final snapshot = await FirebaseFirestore.instance
        .collection('AIQ-AMB-F-004')
        .where('fecha', isEqualTo: fechaStr)
        .get();

    return snapshot.docs.length + 1;
  }

  Future<String> generarFolio() async {
    if (fechaSeleccionada == null) return "";
    final dia = fechaSeleccionada!.day.toString().padLeft(2, '0');
    final mes = fechaSeleccionada!.month.toString().padLeft(2, '0');
    final anio = fechaSeleccionada!.year.toString();
    final consecutivo = consecutivoMostrado;
    return "AIQAMBF005-$dia-$mes-$anio-$consecutivo";
  }

  void limpiarCampos() {
    campo1Controller.clear();
    campo2Controller.clear();
    campo3Controller.clear();
    fechaController.clear();
    horaController.clear();
    jaulaSeleccionada = null;
    resultadoSeleccionado = null;
    firmaController.clear();
    fechaSeleccionada = null;
    horaSeleccionada = null;
    consecutivoMostrado = 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF2),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF263A5B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF263A5B)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "MONITOREO DE AERONAVE",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Avenir',
                            color: Color(0xFF263A5B),
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "AIQ-AMB-F-005",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Avenir',
                            color: Color(0xFF598CBC),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF598CBC)),
                    ),
                    child: Text(
                      "AIQAMBF005-${fechaSeleccionada != null
                          ? "${fechaSeleccionada!.day.toString().padLeft(2, '0')}-${fechaSeleccionada!.month.toString().padLeft(2, '0')}-${fechaSeleccionada!.year}"
                          : "--/--/----"}-$consecutivoMostrado",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263A5B),
                        fontSize: 14,
                        fontFamily: 'Avenir',
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2C8D9), // Fondo azul claro
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Fecha y hora",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF263A5B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: fechaController,
                                readOnly: true,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: "Selecciona la fecha",
                                  hintStyle: const TextStyle(color: Colors.black54),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFC2C8D9)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onTap: () async {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: fechaSeleccionada ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    final consecutivo = await obtenerConsecutivoParaFecha(picked);
                                    setState(() {
                                      fechaSeleccionada = picked;
                                      fechaController.text =
                                          "${picked.day.toString().padLeft(2, '0')}/"
                                          "${picked.month.toString().padLeft(2, '0')}/"
                                          "${picked.year}";
                                      consecutivoMostrado = consecutivo;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: horaController,
                                readOnly: true,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: "Selecciona la hora",
                                  hintStyle: const TextStyle(color: Colors.black54),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.access_time, color: Color(0xFFC2C8D9)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onTap: () async {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: horaSeleccionada ?? TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      horaSeleccionada = picked;
                                      horaController.text = picked.format(context);
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  // Campo de fecha y hora
                  
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2C8D9), // Fondo azul claro
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Zona", // agregar mapa pdf
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF263A5B),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.black,
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 4,
                                    child: Image.asset(
                                      'assets/plano.png', // Cambia por tu imagen
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/plano.png', // Cambia por tu imagen
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: campo1Controller,
                          decoration: InputDecoration(
                            hintText: "Escribe la ubicación...",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.location_on, color: Color(0xFFC2C8D9)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        // Imagen interactiva arriba del campo Zona
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2C8D9), // Fondo azul claro
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Fauna",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF263A5B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Especie",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.pets, color: Color(0xFFC2C8D9)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Número",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.confirmation_number, color: Color(0xFFC2C8D9)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2C8D9), // Fondo azul claro
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Método de Control",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF263A5B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: metodoControlSeleccionado,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.build, color: Color(0xFFC2C8D9)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            hintText: "Selecciona un método...",
                          ),
                          items: const [
                            DropdownMenuItem(value: "Perro", child: Text("Perro")),
                            DropdownMenuItem(value: "Ave", child: Text("Ave")),
                            DropdownMenuItem(value: "Cañón de gas", child: Text("Cañón de gas")),
                            DropdownMenuItem(value: "Rifle de Aire", child: Text("Rifle de Aire")),
                            DropdownMenuItem(value: "Vehículo", child: Text("Vehículo")),
                            DropdownMenuItem(value: "Artefacto Sonoro", child: Text("Artefacto Sonoro")),
                            DropdownMenuItem(value: "Otro", child: Text("Otro")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              metodoControlSeleccionado = value;
                            });
                          },
                        ),
                        // Si quieres dejar el TextField para "otro", puedes mostrarlo solo si selecciona "Otro":
                        if (metodoControlSeleccionado == "Otro") ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: campoMetodoOtroController,
                            decoration: InputDecoration(
                              hintText: "Especifica el método...",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.edit, color: Color(0xFFC2C8D9)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2C8D9), // Fondo azul claro
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Observaciones",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF263A5B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.comment, color: Color(0xFFC2C8D9)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            hintText: "Comentarios",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Firma
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2C8D9), // Fondo azul claro
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Firma prestador de Servicio",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF263A5B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: campo3Controller,
                          decoration: InputDecoration(
                            hintText: "Nombre del prestador",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.person, color: Color(0xFFC2C8D9)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Signature(
                            controller: firmaController,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () => firmaController.clear(),
                          child: const Text("Limpiar", style: TextStyle(fontSize: 12)),
                        ),
                        if (_errorFirma)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, top: 2.0),
                            child: Text(
                              'Firma obligatoria',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        guardarFormulario();   // Espera a que termine de guardar
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 1, 38, 73),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "GUARDAR",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),],
              ),
            ),
          ),
          //LOGO DEL AIQ
          Positioned(
            bottom: 16,
            right: 16,
            child: Opacity(
              opacity: 0.85,
              child: Image.asset(
                'assets/AIQ_LOGO_.png',
                width: 100,
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            child: FloatingActionButton(
              heroTag: 'share_formulario',
              backgroundColor: const Color(0xFF263A5B),
              onPressed: _compartirFormulario,
              child: const Icon(Icons.share, color: Colors.white),
              tooltip: 'Compartir',
            ),
          ),
        ],
      ),
    );
  }
}