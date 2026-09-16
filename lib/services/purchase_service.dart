import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Compras do Smart Tools.
///
/// Três formas de virar Pro (todas concedem o mesmo entitlement `pro`):
///  • `pro_monthly`  — assinatura mensal (remove anúncios + ferramentas Pro)
///  • `pro_yearly`   — assinatura anual (mais barata no ano)
///  • `pro_lifetime` — compra única vitalícia (alto valor, sem renovar)
///
/// ChangeNotifier: a paywall atualiza os PREÇOS REAIS localizados da Play
/// (moeda de cada país) assim que a loja responde.
class PurchaseService extends ChangeNotifier {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  static const String monthlyId = 'pro_monthly';
  static const String yearlyId = 'pro_yearly';
  static const String lifetimeId = 'pro_lifetime';
  static const Set<String> proProducts = {monthlyId, yearlyId, lifetimeId};

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  void Function(String id)? _cb;
  final Map<String, ProductDetails> _products = {};

  bool get available => _products.isNotEmpty;
  ProductDetails? product(String id) => _products[id];

  /// Preço formatado (fallback caso a loja ainda não respondeu).
  String priceOf(String id) {
    final p = _products[id];
    if (p != null) return p.price;
    switch (id) {
      case monthlyId:
        return '\$1.99';
      case yearlyId:
        return '\$9.99';
      default:
        return '\$19.99';
    }
  }

  void onEntitlement(void Function(String id) cb) => _cb = cb;

  Future<void> init() async {
    if (!await _iap.isAvailable()) return;
    _sub = _iap.purchaseStream.listen(_onPurchases, onError: (_) {});
    final r = await _iap.queryProductDetails(proProducts);
    for (final p in r.productDetails) {
      _products[p.id] = p;
    }
    if (_products.isNotEmpty) notifyListeners(); // preços reais chegaram
    await _iap.restorePurchases();
  }

  Future<void> buy(String id) async {
    final p = _products[id];
    if (p == null) return;
    final param = PurchaseParam(productDetails: p);
    // Assinaturas e vitalício usam buyNonConsumable no plugin.
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() => _iap.restorePurchases();

  void _onPurchases(List<PurchaseDetails> list) {
    for (final p in list) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        _cb?.call(p.productID);
      }
      if (p.pendingCompletePurchase) _iap.completePurchase(p);
    }
  }
}
