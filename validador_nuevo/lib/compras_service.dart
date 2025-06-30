import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:validador_nuevo/screens/confirmacion_compra_screen.dart';

class ComprasService {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static final List<String> _productIds = ['token_1', 'token_3', 'token_5'];

  static late StreamSubscription<List<PurchaseDetails>> _subscription;

  static List<ProductDetails> productosDisponibles = [];
  static late BuildContext _context;

  /// Inicializa el sistema de compras y escucha eventos de compra
  static Future<void> inicializar(BuildContext context) async {
    final disponible = await _inAppPurchase.isAvailable();
    if (!disponible) {
      debugPrint('Google Play Billing no disponible.');
      return;
    }

    _context = context;

    // Escuchar compras
    _subscription = _inAppPurchase.purchaseStream.listen((compras) {
      _procesarCompras(compras, context);
    });

    // Cargar productos desde Google Play
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_productIds.toSet());

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('No se encontraron estos productos: ${response.notFoundIDs}');
    }

    productosDisponibles = response.productDetails;
  }

  /// Obtener productos sin inicializar flujos (para mostrar al inicio)
  static Future<List<ProductDetails>> obtenerProductos() async {
    final disponible = await _inAppPurchase.isAvailable();
    if (!disponible) return [];

    final response =
        await _inAppPurchase.queryProductDetails(_productIds.toSet());
    return response.productDetails;
  }

  /// Inicia una compra de un producto
  static Future<void> comprarProducto(ProductDetails producto) async {
    final compra = PurchaseParam(productDetails: producto);
    await _inAppPurchase.buyConsumable(purchaseParam: compra);
  }

  /// Procesa las compras que llegan desde Google Play
  static Future<void> _procesarCompras(
    List<PurchaseDetails> compras,
    BuildContext context,
  ) async {
    for (final compra in compras) {
      if (compra.status == PurchaseStatus.purchased) {
        debugPrint('Compra confirmada: ${compra.productID}');

        // Confirmar la compra a Google Play
        if (compra.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(compra);
        }

        // Redirigir a pantalla de confirmación
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ConfirmacionCompraScreen(),
          ),
        );
      } else if (compra.status == PurchaseStatus.error) {
        debugPrint('Error en compra: ${compra.error}');
      }
    }
  }

  /// Liberar recursos cuando se cierre la app
  static void dispose() {
    _subscription.cancel();
  }
}
