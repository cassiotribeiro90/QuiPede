import 'package:flutter/foundation.dart';

class PendingProductService {
  static final PendingProductService _instance = PendingProductService._internal();
  factory PendingProductService() => _instance;
  PendingProductService._internal();

  dynamic _produto;
  int? _lojaId;

  void setProduto(dynamic produto, int lojaId) {
    _produto = produto;
    _lojaId = lojaId;
    debugPrint('✅ [PendingProductService] Produto salvo: ${produto?.nome} - Loja: $lojaId');
  }

  dynamic getProduto() {
    return _produto;
  }

  int? getLojaId() {
    return _lojaId;
  }

  bool get hasPending => _produto != null && _lojaId != null;

  void clear() {
    debugPrint('✅ [PendingProductService] Limpando produto: ${_produto?.nome}');
    _produto = null;
    _lojaId = null;
  }
}
