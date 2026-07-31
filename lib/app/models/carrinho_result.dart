import 'package:quipede/app/models/carrinho_response.dart';

class CarrinhoResult {
  final bool success;
  final int? code;
  final String? message;
  final CarrinhoResponse? data;
  final CarrinhoConflito? conflito;

  CarrinhoResult.success(this.data)
      : success = true,
        code = 200,
        message = null,
        conflito = null;

  CarrinhoResult.conflito(this.conflito)
      : success = false,
        code = 409,
        message = conflito?.message,
        data = null;

  CarrinhoResult.error(this.message, {this.code = 500})
      : success = false,
        data = null,
        conflito = null;

  bool get isConflito => code == 409;
}

class CarrinhoConflito {
  final String acao;
  final int lojaAtual;
  final int novaLoja;
  final String? lojaAtualNome;
  final String message;

  CarrinhoConflito({
    required this.acao,
    required this.lojaAtual,
    required this.novaLoja,
    this.lojaAtualNome,
    required this.message,
  });

  factory CarrinhoConflito.fromJson(dynamic json) {
    final Map<String, dynamic> data = (json is Map) ? Map<String, dynamic>.from(json) : {};
    final status = data['status'] ?? data['data'] ?? data;

    return CarrinhoConflito(
      acao: status['acao'] ?? 'limpar_carrinho',
      lojaAtual: int.tryParse(status['loja_atual']?.toString() ?? '0') ?? 0,
      novaLoja: int.tryParse(status['nova_loja']?.toString() ?? '0') ?? 0,
      lojaAtualNome: status['loja_atual_nome'],
      message: data['message'] ?? 'Seu carrinho já tem itens de outra loja. Deseja limpar o carrinho e adicionar este item?',
    );
  }
}