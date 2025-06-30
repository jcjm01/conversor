import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmacionCompraScreen extends StatelessWidget {
  const ConfirmacionCompraScreen({super.key});

  Future<void> _enviarCorreo() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'conversor.oficial.1@gmail.com',
      query: 'subject=Comprobante de compra',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _abrirTelegram() async {
    final Uri telegramUri = Uri.parse('https://t.me/ConversorApp');
    if (await canLaunchUrl(telegramUri)) {
      await launchUrl(telegramUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compra Exitosa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ ¡Gracias por tu compra!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple, // <- Cambio leve
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Por favor, toma una captura del correo con el comprobante de Google Play. Asegúrate de que se vea claramente:\n\n'
              '- Número de pedido\n'
              '- Fecha y hora\n'
              '- Precio\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '📩 Luego envíalo a:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _enviarCorreo,
              child: const Text(
                '✉️ conversor.oficial.1@gmail.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _abrirTelegram,
              child: const Text(
                '📲 Telegram: @ConversorApp',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Image.asset('assets/images/ejemplo_recibo.png'),
            const SizedBox(height: 20),
            const Text(
              '🔁 Si quieres volver a obtener un beneficio digital más adelante, simplemente repite este proceso haciendo una nueva compra desde la app.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
