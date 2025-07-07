// ignore: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'AIQ-SSEI-F002-2.dart';
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

class AIQSSEIF002Screen extends StatefulWidget {
  const AIQSSEIF002Screen({super.key});

  @override
  State<AIQSSEIF002Screen> createState() => _AIQSSEIF002ScreenState();
}

class BomberoData {
  TextEditingController nombreController = TextEditingController();
  String? vehiculoSeleccionado;
  String? asignacionSeleccionada;
  String? radioSeleccionado;

  BomberoData();
}


class _AIQSSEIF002ScreenState extends State<AIQSSEIF002Screen> {
  int folio = 1;
  bool _isSaving = false;
  
  // NUEVO: controladores y variables para fecha y hora
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  bool _errorFecha = false;
  bool _errorHora = false;

  // Controladores de los campos actuales
  final TextEditingController cargoController = TextEditingController();
  final TextEditingController RTController = TextEditingController();
  final TextEditingController bomberoController = TextEditingController();
  final TextEditingController comandanteController = TextEditingController();
  final TextEditingController vehiculoController = TextEditingController();
  final TextEditingController persona1NombreController = TextEditingController();


  // Errores de campos obligatorios
  bool _errorComandante=false;
  bool _errorUbicacion = false;
  bool _errorCargo= false;
  bool _errorAsignacion = false;
  bool _errorRadio = false;
  bool _errorRT = false;
  bool _errorVehiculo = false;
  bool _errorBombero = false;
  bool _errorNumero = false;
  bool _errorNombre = false;

  int consecutivoMostrado = 1;
  String nombreDocumento = "AIQ-SSEI-F002";

  List<BomberoData> bomberos = [BomberoData()];

  
  final List<String> opcionesRT = [
  'RT1',
  'RT2',
  'RT3',
  'RT4'
];
String? rtSeleccionado;

final List<String> opcionesVehiculo = [
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

final List<String> opcionesAsignacion = [
  'Operador',
  'Bombero',
  'Paramédico',
];
String? asignacionSeleccionado;

final List<String> radiosAsignacion = [
  'R1',
  'R2',
  'R3',
  'R4',
  'R5',
  'R6',
  'R7',
  'R8',
];
String? radiosSeleccionado;

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
    cargoController.dispose();
    bomberoController.dispose();
    persona1NombreController.dispose();
    super.dispose();
  }

  bool validarCampos() {
    setState(() {
      _errorCargo = cargoController.text.trim().isEmpty;
      _errorNumero = bomberoController.text.trim().isEmpty;
      _errorNombre = persona1NombreController.text.trim().isEmpty;
    });
    return !(_errorUbicacion ||
        _errorCargo ||
        _errorNumero ||
        _errorNombre);
  }

  Future<void> guardarEnFirestore(String fechaHoy, String folioGenerado) async {
    await FirebaseFirestore.instance
        .collection('AIQ-SSEI-F002')
        .doc(folioGenerado) // El ID será el folio generado
        .set({
      'folio': folioGenerado,
      'fecha': fechaHoy,
      'ubicacion': cargoController.text.trim(),
      'numero': bomberoController.text.trim(),
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
    cargoController.clear();
    bomberoController.clear();
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
      backgroundColor: const Color(0xFFEAEFF8),
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

              //Comandante
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
                    "Comandante",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir',
                      color: Color(0xFF263A5B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: _errorComandante //Cambiar el de error especie y añadir error comandante
                          ? Border.all(color: Colors.red)
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: comandanteController, //Cambiar el cargoController a comandanteController
                      decoration: InputDecoration(
                        labelText: "Nombre",
                        labelStyle: const TextStyle(color: Colors.grey),
                        icon: const Icon(Icons.person_search_rounded, color: Colors.grey),
                        border: InputBorder.none,
                        errorText: _errorNombre ? "Este campo es obligatorio" : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  //Vehiculo Seleccionado
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: _errorNumero
                          ? Border.all(color: Colors.red)
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      value: vehiculoController.text.isNotEmpty ? vehiculoController.text : null,
                      decoration: InputDecoration(
                        labelText: "Vehículo Seleccionado",
                        icon: const Icon(Icons.fire_truck_rounded, color: Colors.grey),
                        border: InputBorder.none,
                        errorText: _errorNumero ? "Este campo es obligatorio" : null,
                      ),
                      items: opcionesVehiculo
                          .map((vehiculo) => DropdownMenuItem(
                                value: vehiculo,
                                child: Text(vehiculo),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          bomberoController.text = value ?? '';
                          _errorNumero = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  //Asignacion
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: _errorAsignacion
                          ? Border.all(color: Colors.red)
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      value: asignacionSeleccionado,
                      decoration: InputDecoration(
                        labelText: "Asignación",
                        icon: const Icon(Icons.groups, color: Colors.grey),
                        border: InputBorder.none,
                        errorText: _errorNumero ? "Este campo es obligatorio" : null,
                      ),
                      items: opcionesAsignacion
                          .map((asignacion) => DropdownMenuItem(
                                value: asignacion,
                                child: Text(asignacion),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          asignacionSeleccionado = value;
                          _errorAsignacion = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Radio Asignado
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: _errorRadio
                          ? Border.all(color: Colors.red)
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      value: radiosSeleccionado,
                      decoration: InputDecoration(
                        labelText: "Radio Asignado",
                        icon: const Icon(Icons.online_prediction_rounded, color: Colors.grey),
                        border: InputBorder.none,
                        errorText: _errorRadio ? "Este campo es obligatorio" : null,
                      ),
                      items: radiosAsignacion
                          .map((radios) => DropdownMenuItem(
                                value: radios,
                                child: Text(radios),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          radiosSeleccionado = value;
                          _errorRadio = false;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            

            // RT
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
                    "RT",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir',
                      color: Color(0xFF263A5B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: _errorRT
                          ? Border.all(color: Colors.red)
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: rtSeleccionado,
                          decoration: InputDecoration(
                            labelText: "RT",
                            labelStyle: const TextStyle(color: Colors.grey),
                            icon: const Icon(Icons.local_police_rounded, color: Colors.grey),
                            border: InputBorder.none,
                            errorText: _errorRT ? "Este campo es obligatorio" : null,
                          ),
                          items: opcionesRT
                              .map((rt) => DropdownMenuItem(
                                    value: rt,
                                    child: Text(rt),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              rtSeleccionado = value;
                              RTController.text = value ?? '';
                              _errorRT = false;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  if (_errorRT)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Este campo es obligatorio",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: _errorNumero
                          ? Border.all(color: Colors.red)
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      value: vehiculoSeleccionado,
                      decoration: InputDecoration(
                        labelText: "Vehículo Seleccionado",
                        icon: const Icon(Icons.fire_truck_rounded, color: Colors.grey),
                        border: InputBorder.none,
                        errorText: _errorVehiculo ? "Este campo es obligatorio" : null,
                      ),
                      items: opcionesVehiculo
                          .map((vehiculo) => DropdownMenuItem(
                                value: vehiculo,
                                child: Text(vehiculo),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          vehiculoSeleccionado = value;
                          _errorVehiculo = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: _errorNumero
                          ? Border.all(color: Colors.red)
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      value: asignacionSeleccionado,
                      decoration: InputDecoration(
                        labelText: "Asignación",
                        icon: const Icon(Icons.groups, color: Colors.grey),
                        border: InputBorder.none,
                        errorText: _errorAsignacion ? "Este campo es obligatorio" : null,
                      ),
                      items: opcionesAsignacion
                          .map((asignacion) => DropdownMenuItem(
                                value: asignacion,
                                child: Text(asignacion),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          asignacionSeleccionado = value;
                          _errorAsignacion = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: _errorNumero
                          ? Border.all(color: Colors.red)
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      value: radiosSeleccionado,
                      decoration: InputDecoration(
                        labelText: "Radio Asignado",
                        icon: const Icon(Icons.online_prediction_rounded, color: Colors.grey),
                        border: InputBorder.none,
                        errorText: _errorRadio ? "Este campo es obligatorio" : null,
                      ),
                      items: radiosAsignacion
                          .map((radios) => DropdownMenuItem(
                                value: radios,
                                child: Text(radios),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          radiosSeleccionado = value;
                          _errorRadio = false;
                        });
                      },
                    ),
                  ),
                  if (_errorNumero)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Este campo es obligatorio",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            
            

            // Bomberos
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
        "Bomberos",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Avenir',
          color: Color(0xFF263A5B),
        ),
      ),
      const SizedBox(height: 16),

      // 🔁 Aquí renderizamos cada bloque de bombero
      ...bomberos.asMap().entries.map((entry) {
        final index = entry.key;
        final bombero = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bombero ${index + 1}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF263A5B),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: bombero.nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  icon: Icon(Icons.local_police_rounded, color: Colors.grey),
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                value: bombero.vehiculoSeleccionado,
                decoration: const InputDecoration(
                  labelText: "Vehículo Seleccionado",
                  icon: Icon(Icons.fire_truck_rounded, color: Colors.grey),
                  border: InputBorder.none,
                ),
                items: opcionesVehiculo.map((vehiculo) {
                  return DropdownMenuItem(
                    value: vehiculo,
                    child: Text(vehiculo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    bombero.vehiculoSeleccionado = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                value: bombero.asignacionSeleccionada,
                decoration: const InputDecoration(
                  labelText: "Asignación",
                  icon: Icon(Icons.groups, color: Colors.grey),
                  border: InputBorder.none,
                ),
                items: opcionesAsignacion.map((asignacion) {
                  return DropdownMenuItem(
                    value: asignacion,
                    child: Text(asignacion),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    bombero.asignacionSeleccionada = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                value: bombero.radioSeleccionado,
                decoration: const InputDecoration(
                  labelText: "Radio Asignado",
                  icon: Icon(Icons.online_prediction_rounded, color: Colors.grey),
                  border: InputBorder.none,
                ),
                items: radiosAsignacion.map((radio) {
                  return DropdownMenuItem(
                    value: radio,
                    child: Text(radio),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    bombero.radioSeleccionado = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      }).toList(),

      // 🔘 Botón para agregar nuevo bombero completo
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.add, color: Color(0xFF263A5B)),
          label: const Text("Agregar a un bombero"),
          style:  TextButton.styleFrom(
            iconColor: const Color(0xFF263A5B),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            foregroundColor: const Color(0xFF263A5B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            setState(() {
              bomberos.add(BomberoData());
            });
          },
        ),
      ),
    ],
  ),
),
            
            
           //BOTONES
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AIQSSEIF0022Screen(),
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

List<TextEditingController> bomberoControllers = [TextEditingController()];