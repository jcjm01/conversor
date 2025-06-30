import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:validador_nuevo/compras_service.dart';
import 'package:validador_nuevo/token_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:validador_nuevo/screens/confirmacion_compra_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final estadoApp = await obtenerEstadoApp();
  final bool activo = estadoApp['activo'];
  final String mensaje = estadoApp['mensaje'];

  runApp(MyApp(activo: activo, mensaje: mensaje));
}

Future<Map<String, dynamic>> obtenerEstadoApp() async {
  const url =
      'https://raw.githubusercontent.com/jcjm01/conversor/main/estado_app.json';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
      'Expires': '0',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {'activo': true, 'mensaje': ''};
  }
}

class InstruccionesEnvioScreen extends StatefulWidget {
  const InstruccionesEnvioScreen({super.key});

  @override
  State<InstruccionesEnvioScreen> createState() =>
      _InstruccionesEnvioScreenState();
}

class _InstruccionesEnvioScreenState extends State<InstruccionesEnvioScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];
  final Set<String> _ids = {'token_1'};

  bool _botonPresionado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ComprasService.inicializar(context);
    });
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final disponible = await _inAppPurchase.isAvailable();
    if (!disponible) return;

    final response = await _inAppPurchase.queryProductDetails(_ids);
    if (response.notFoundIDs.isNotEmpty) {
      print('Producto no encontrado: ${response.notFoundIDs}');
    }

    setState(() {
      _available = disponible;
      _products = response.productDetails;
    });
  }

  Future<void> _abrirTelegram() async {
    setState(() {
      _botonPresionado = true;
    });

    final url = Uri.parse('https://t.me/ConversorApp');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      setState(() {
        _botonPresionado = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Telegram.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cómo enviar tu información')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Por favor envía esta información por mensaje a Telegram:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '🧾 Comprobante de compra (captura o foto)\n✍️ CLABE o número de tarjeta escrita (no imagen)\n📅 Fecha y hora exacta de compra\n🆔 ID de transacción (si lo tienes)',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _botonPresionado ? null : _abrirTelegram,
              icon: const Icon(Icons.telegram),
              label: const Text('Enviar por Telegram'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 20),
            if (_products.isNotEmpty)
              ..._products
                  .map((producto) => ElevatedButton(
                        onPressed: () =>
                            ComprasService.comprarProducto(producto),
                        child: Text('${producto.title} — ${producto.price}'),
                      ))
                  .toList()
            else if (!_available)
              const Text('Compras no disponibles en este dispositivo')
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool activo;
  final String mensaje;

  const MyApp({super.key, required this.activo, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversión de Créditos',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        primarySwatch: Colors.deepPurple,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEDEDED),
          foregroundColor: Colors.black,
        ),
      ),
      home: activo
          ? const ConversionInfoScreen()
          : Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    mensaje.isNotEmpty
                        ? mensaje
                        : 'La aplicación no está disponible en este momento. Vuelve más tarde.',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
    );
  }
}

class ConversionInfoScreen extends StatefulWidget {
  const ConversionInfoScreen({super.key});

  @override
  State<ConversionInfoScreen> createState() => _ConversionInfoScreenState();
}

class _ConversionInfoScreenState extends State<ConversionInfoScreen> {
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ComprasService.inicializar(context);
    });
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final productos = await ComprasService.obtenerProductos();
    setState(() {
      _products = productos;
    });
  }

  @override
  void dispose() {
    ComprasService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar procedimiento')),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cómo utilizar tu saldo digital?\n\n'
              '1. Realiza una compra dentro de la aplicación utilizando tu saldo digital disponible.\n'
              '2. Guarda el comprobante de la transacción (captura de pantalla o foto).\n'
              '3. Envíanos por Telegram:\n'
              '- El comprobante de compra\n'
              '- La cuenta donde deseas recibir tu beneficio digital\n'
              '- La fecha y hora exacta de la transacción\n\n'
              '4. En un plazo máximo de 24 horas, recibirás la compensación correspondiente.\n',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final Uri url =
                    Uri.parse('https://www.youtube.com/watch?v=RMxWryHjoIw');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text(
                'ℹ️ Si no sabes cómo usar tu saldo digital, puedes ver este tutorial como guía (tócalo aquí)',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final producto = _products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () =>
                                ComprasService.comprarProducto(producto),
                            child:
                                Text('${producto.title} — ${producto.price}'),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConfirmacionCompraScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Ver cómo enviar comprobante'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
