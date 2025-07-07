import 'dart:io';
import 'package:flutter/material.dart';
import 'package:interfaz_uno_aiq/SSEI/AIQ-SSEI-F002-3.dart';
import 'package:signature/signature.dart';
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;

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

class AIQSSEIF0022Screen extends StatefulWidget {
  const AIQSSEIF0022Screen({super.key});

  @override
  State<AIQSSEIF0022Screen> createState() => _AIQSSEIF0022ScreenState();
}

class BomberoData {
  TextEditingController nombreController = TextEditingController();
  String? vehiculoSeleccionado;
  String? asignacionSeleccionada;
  String? radioSeleccionado;

  BomberoData();
}

class VehiculoData {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController numeroEcoController = TextEditingController();
  final TextEditingController combRecController = TextEditingController();
  final TextEditingController combEntrController = TextEditingController();
  final TextEditingController kmRecibController = TextEditingController();
  final TextEditingController kmEntrController = TextEditingController();
  final TextEditingController kmRecoController = TextEditingController();
}

class _AIQSSEIF0022ScreenState extends State<AIQSSEIF0022Screen> {
  int folio = 1;
  bool _isSaving = false;
  
  // NUEVO: controladores y variables para fecha y hora
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  bool _errorFecha = false;
  bool _errorHora = false;

  // Controladores de los campos actuales
  final TextEditingController VehiculoController = TextEditingController();
  final TextEditingController NumeroEcoController = TextEditingController();
  final TextEditingController CombRecController = TextEditingController();
  final TextEditingController CombEntrController = TextEditingController();
  final TextEditingController KmRecibController = TextEditingController();
  final TextEditingController KmEntrController = TextEditingController();
  final TextEditingController KmRecoController = TextEditingController();
  final TextEditingController EstadoUController = TextEditingController();

  final TextEditingController persona1NombreController = TextEditingController();


  // Errores de campos obligatorios
  bool _errorVehiculo2=false;
  bool _errorNumeroEco = false;
  bool _errorCombRec= false;
  bool _errorCombEntr = false;
  bool _errorKmRecib = false;
  bool _errorKmEntr = false;
  bool _errorKmReco = false;
  bool _errorEstadoU = false;

  int consecutivoMostrado = 1;
  String nombreDocumento = "AIQ-SSEI-F002";

  List<BomberoData> bomberos = [BomberoData()];

final List<String> opcionesNoEco = [
  'R-50',
  'E-1',
  'VE-003',
  'E-4',
  'E-5',
  'C-50',
  'UM-01',
  'UA-02',
  'UA-01',
];
String? vehiculoSeleccionado;

List<VehiculoData> vehiculos = [VehiculoData()];

  @override
  void initState() {
    super.initState();
    _cargarFolio();
  }

  Future<void> _cargarFolio() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      folio = prefs.getInt('folio_f-001') ?? 1;
    });
  }

  Future<void> _incrementarFolio() async {
    final prefs = await SharedPreferences.getInstance();
    folio++;
    await prefs.setInt('folio_f-001', folio);
    setState(() {});
  }

  @override
  void dispose() {
    VehiculoController.dispose();
    NumeroEcoController.dispose();
    persona1NombreController.dispose();
    super.dispose();
  }

  bool validarCampos() {
    setState(() {
      _errorVehiculo2 = VehiculoController.text.trim().isEmpty;
      _errorNumeroEco = NumeroEcoController.text.trim().isEmpty;
      _errorKmEntr = KmEntrController.text.trim().isEmpty;
    });
    return !(_errorNumeroEco ||
        _errorVehiculo2 ||
        _errorNumeroEco ||
        _errorKmEntr);
  }

  Future<void> guardarEnFirestore(String fechaHoy, String folioGenerado) async {
    await FirebaseFirestore.instance
        .collection('AIQ-SSEI-F002')
        .doc(folioGenerado) // El ID será el folio generado
        .set({
      'folio': folioGenerado,
      'fecha': fechaHoy,
      'vehiculo': VehiculoController.text.trim(),
      'numero': NumeroEcoController.text.trim(),
      'fecha_seleccionada': _fechaSeleccionada != null
          ? "${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/${_fechaSeleccionada!.year}"
          : "",
      'hora_seleccionada': _horaSeleccionada != null
          ? "${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}"
          : "",
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void limpiarCampos() {
    KmEntrController.clear();
    NumeroEcoController.clear();
    persona1NombreController.clear();
    _fechaSeleccionada = null;
    _horaSeleccionada = null;
    consecutivoMostrado = 1;
    setState(() {});
  }

  // Permite cerrar sesión de Google para seleccionar otra cuenta antes de subir a Drive
  Future<void> logoutGoogle() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  // Sube PDF a Google Drive y retorna el enlace compartible
  Future<String?> subirPDFaDrive(File pdfFile) async {
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
    final uploaded = await driveApi.files.create(
      driveFile,
      uploadMedia: media,
    );
    // Hacer el archivo compartible
    await driveApi.permissions.create(
      drive.Permission()
        ..type = 'anyone'
        ..role = 'reader',
      uploaded.id!,
    );
    return 'https://drive.google.com/file/d/${uploaded.id}/view?usp=sharing';
  }

  // Sube PDF a Google Drive en una carpeta específica y retorna el enlace compartible
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
    driveFile.parents = [folderId]; // Usa el parámetro folderId correctamente
    final uploaded = await driveApi.files.create(
      driveFile,
      uploadMedia: media,
    );
    // Hacer el archivo compartible
    await driveApi.permissions.create(
      drive.Permission()
        ..type = 'anyone'
        ..role = 'reader',
      uploaded.id!,
    );
    return 'https://drive.google.com/file/d/${uploaded.id}/view?usp=sharing';
  }

  Future<String> generarFolio() async {
    if (_fechaSeleccionada == null) return "";
    final dia = _fechaSeleccionada!.day.toString().padLeft(2, '0');
    final mes = _fechaSeleccionada!.month.toString().padLeft(2, '0');
    final anio = _fechaSeleccionada!.year.toString();
    final fechaStr = "$dia/$mes/$anio";

    final snapshot = await FirebaseFirestore.instance
        .collection('AIQ-SSEI-F002')
        .where('fecha_seleccionada', isEqualTo: fechaStr)
        .get();

    final consecutivo = snapshot.docs.length + 1;
    return "AIQAMBF001-$dia-$mes-$anio-$consecutivo";
  }

  // MODIFICADO: Guardar, exportar PDF y subir a Drive con feedback
  void guardarYExportar() async {
    if (_isSaving) return;
    if (!validarCampos()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, completa todos los campos obligatorios y la firma')),
        );
      }
      return;
    }
    setState(() => _isSaving = true);
    final fechaHoy = "${DateTime.now().day.toString().padLeft(2, '0')}/"
        "${DateTime.now().month.toString().padLeft(2, '0')}/"
        "${DateTime.now().year}";
    const folderId = '10xo5X1yi4DZPb5s8w-sLHNs9w2EslxGp'; // ID carpeta de Drive
    try {
      final folioGenerado = await generarFolio();
      await guardarEnFirestore(fechaHoy, folioGenerado);
      await logoutGoogle(); // Permitir selección de cuenta
      await _incrementarFolio();
      limpiarCampos();
    } catch (e, stack) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error al guardar: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }
  
  Future<int> obtenerConsecutivoParaFecha(DateTime fecha) async {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    final fechaStr = "$dia/$mes/$anio";

    final snapshot = await FirebaseFirestore.instance
        .collection('AIQ-SSEI-F002')
        .where('fecha_seleccionada', isEqualTo: fechaStr)
        .get();

    return snapshot.docs.length + 1;
  }

  // NUEVO: Métodos para seleccionar fecha y hora
  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
            data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF598CBC),
            colorScheme: ColorScheme.light(primary: const Color(0xFF598CBC)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      final consecutivo = await obtenerConsecutivoParaFecha(fecha);
      setState(() {
        _fechaSeleccionada = fecha;
        consecutivoMostrado = consecutivo;
        _errorFecha = false;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF598CBC),
            colorScheme: ColorScheme.light(primary: const Color(0xFF598CBC)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
          child: child!,
        );
      },
    );

    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
        _errorHora = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF263A5B), size:25),
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

            // Selector de fecha y folio en la misma fila
            Row(
              children: [
                // Selector de fecha (izquierda)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Fecha del monitoreo",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF263A5B),
                        ),
                      ),
                      
                      InkWell(
                        onTap: _seleccionarFecha,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: _errorFecha ? Border.all(color: Colors.red) : null,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey[700]),
                              const SizedBox(width: 10),
                              Text(
                                _fechaSeleccionada != null
                                    ? "${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/${_fechaSeleccionada!.year}"
                                    : "Selecciona una fecha",
                                style: TextStyle(
                                  color: _fechaSeleccionada != null ? Colors.black : Colors.grey[500],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_errorFecha)
                        const Padding(
                          padding: EdgeInsets.only(top: 6, left: 8),
                          child: Text(
                            "La fecha es obligatoria",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Folio (derecha)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  margin: const EdgeInsets.only(top: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF598CBC)),
                  ),
                  child: Text(
                    "AIQSSEIF002-${_fechaSeleccionada != null
                        ? "${_fechaSeleccionada!.day.toString().padLeft(2, '0')}-${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-${_fechaSeleccionada!.year}"
                        : "--/--/----"}-$consecutivoMostrado",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263A5B),
                      fontSize: 14,
                      fontFamily: 'Avenir',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Selector de hora
            Text(
              "Hora del monitoreo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF263A5B),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _seleccionarHora,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: _errorHora ? Border.all(color: Colors.red) : null,
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey[700]),
                    const SizedBox(width: 10),
                    Text(
                      _horaSeleccionada != null
                          ? "${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}"
                          : "Selecciona una hora",
                      style: TextStyle(
                        color: _horaSeleccionada != null ? Colors.black : Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_errorHora)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 8),
                child: Text(
                  "La hora es obligatoria",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

              //Modelo Vehículo
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC2C8D9),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Modelo Vehículo",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir',
                      color: Color(0xFF263A5B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Nombre y No. Económico en la misma línea
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: VehiculoController,
                            decoration: const InputDecoration(
                              labelText: "Nombre",
                              labelStyle: TextStyle(color: Colors.grey),
                              icon: Icon(Icons.person_search_rounded, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: NumeroEcoController,
                            decoration: const InputDecoration(
                              labelText: "No. Económico",
                              labelStyle: TextStyle(color: Colors.grey),
                              icon: Icon(Icons.fire_truck_rounded, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Combustibles en la misma línea
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: TextField(
                                controller: CombRecController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Combustible Recibido",
                                  icon: Icon(Icons.local_gas_station, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: TextField(
                                controller: CombEntrController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Combustible Entregado",
                                  icon: Icon(Icons.local_gas_station_outlined, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Kilometrajes en la misma línea
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: TextField(
                                controller: KmRecibController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Km Recibido",
                                  icon: Icon(Icons.speed, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: TextField(
                                controller: KmEntrController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Km Entregado",
                                  icon: Icon(Icons.speed_outlined, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: TextField(
                                controller: KmRecoController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Km Recorrido",
                                  icon: Icon(Icons.directions_car, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Column(
                    children: [
                      for (int idx = 0; idx < vehiculos.length; idx++)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFC2C8D9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Modelo Vehículo",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Avenir',
                                  color: Color(0xFF263A5B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Nombre y No. Económico en la misma línea
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: vehiculos[idx].nombreController,
                                        decoration: const InputDecoration(
                                          labelText: "Nombre",
                                          labelStyle: TextStyle(color: Colors.grey),
                                          icon: Icon(Icons.person_search_rounded, color: Colors.grey),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: vehiculos[idx].numeroEcoController,
                                        decoration: const InputDecoration(
                                          labelText: "No. Económico",
                                          labelStyle: TextStyle(color: Colors.grey),
                                          icon: Icon(Icons.fire_truck_rounded, color: Colors.grey),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Combustibles en la misma línea
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: TextField(
                                            controller: vehiculos[idx].combRecController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: "Combustible Recibido",
                                              icon: Icon(Icons.local_gas_station, color: Colors.grey),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: TextField(
                                            controller: vehiculos[idx].combEntrController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: "Combustible Entregado",
                                              icon: Icon(Icons.local_gas_station_outlined, color: Colors.grey),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Kilometrajes en la misma línea
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: TextField(
                                            controller: vehiculos[idx].kmRecibController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: "Km Recibido",
                                              icon: Icon(Icons.speed, color: Colors.grey),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: TextField(
                                            controller: vehiculos[idx].kmEntrController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: "Km Entregado",
                                              icon: Icon(Icons.speed_outlined, color: Colors.grey),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: TextField(
                                            controller: vehiculos[idx].kmRecoController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: "Km Recorrido",
                                              icon: Icon(Icons.directions_car, color: Colors.grey),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  // Botón +
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add, color: Color(0xFF263A5B)),
                      label: const Text("Agregar otro vehículo"),
                      onPressed: () {
                        setState(() {
                          vehiculos.add(VehiculoData());
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AIQSSEIF0023Screen(), // <-- Cambia aquí el destino
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF598CBC),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "SIGUIENTE",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
                const SizedBox(height: 16),
                ],
              ),
            ),
    );
    }
}