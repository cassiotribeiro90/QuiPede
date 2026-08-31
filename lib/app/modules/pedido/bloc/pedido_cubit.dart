import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/pedido_detalhe_model.dart';
import '../services/pedido_service.dart';

abstract class PedidoState extends Equatable {
  const PedidoState();
  @override
  List<Object?> get props => [];
}

class PedidoInitial extends PedidoState {}

class PedidoLoading extends PedidoState {}

class PedidoCriando extends PedidoState {}

class PedidoCriado extends PedidoState {
  final int pedidoId;
  const PedidoCriado(this.pedidoId);
  @override
  List<Object> get props => [pedidoId];
}

class PedidoDetalheCarregado extends PedidoState {
  final PedidoDetalheModel pedido;
  final List<PedidoDetalheModel> pedidos;
  const PedidoDetalheCarregado(this.pedido, {this.pedidos = const []});
  @override
  List<Object> get props => [pedido, pedidos];
}

class PedidoListaCarregada extends PedidoState {
  final List<PedidoDetalheModel> pedidos;
  const PedidoListaCarregada(this.pedidos);
  @override
  List<Object> get props => [pedidos];
}

class PedidoError extends PedidoState {
  final String message;
  const PedidoError(this.message);
  @override
  List<Object> get props => [message];
}

class PedidoCubit extends Cubit<PedidoState> {
  final PedidoService _service;
  List<PedidoDetalheModel> _lastPedidos = [];

  PedidoCubit(this._service) : super(PedidoInitial());

  PedidoService get service => _service;

  Future<void> criarPedido({
    required int enderecoId,
    required String formaPagamento,
    double? trocoPara,
    String? observacao,
  }) async {
    emit(PedidoCriando());
    try {
      final pedidoId = await _service.criarPedido(
        enderecoId: enderecoId,
        formaPagamento: formaPagamento,
        trocoPara: trocoPara,
        observacao: observacao,
      );
      emit(PedidoCriado(pedidoId));
    } catch (e) {
      emit(PedidoError(e.toString()));
    }
  }

  /// Carrega detalhes do pedido.
  /// Se [silencioso] for true, não emite PedidoLoading (apenas atualiza o estado).
  Future<void> carregarDetalhes(int pedidoId, {bool silencioso = false}) async {
    if (!silencioso) {
      emit(PedidoLoading());
    }
    try {
      final pedido = await _service.getPedidoDetalhe(pedidoId);
      emit(PedidoDetalheCarregado(pedido, pedidos: _lastPedidos));
    } catch (e) {
      if (!silencioso) {
        emit(PedidoError(e.toString()));
      }
    }
  }

  Future<void> carregarPedidos() async {
    emit(PedidoLoading());
    try {
      final pedidos = await _service.getPedidos();
      _lastPedidos = pedidos;
      emit(PedidoListaCarregada(pedidos));
    } catch (e) {
      emit(PedidoError(e.toString()));
    }
  }

  Future<void> cancelarPedido(int pedidoId) async {
    try {
      await _service.cancelarPedido(pedidoId);
      if (state is PedidoDetalheCarregado) {
        await carregarDetalhes(pedidoId);
      } else {
        await carregarPedidos();
      }
    } catch (e) {
      emit(PedidoError(e.toString()));
    }
  }

  Future<void> enviarAvaliacao({
    required int pedidoId,
    int? produtoId,
    int? lojaId,
    required int nota,
    String? comentario,
  }) async {
    try {
      await _service.enviarAvaliacao(
        pedidoId: pedidoId,
        produtoId: produtoId,
        lojaId: lojaId,
        nota: nota,
        comentario: comentario,
      );
      // Recarrega silenciosamente para não perder scroll nem mostrar loading
      await carregarDetalhes(pedidoId, silencioso: true);
    } catch (e) {
      emit(PedidoError(e.toString()));
      rethrow;
    }
  }

  Future<void> editarAvaliacao({
    required int avaliacaoId,
    required int nota,
    String? comentario,
  }) async {
    try {
      await _service.editarAvaliacao(
        avaliacaoId: avaliacaoId,
        nota: nota,
        comentario: comentario,
      );
      if (state is PedidoDetalheCarregado) {
        final pedidoId = (state as PedidoDetalheCarregado).pedido.id;
        await carregarDetalhes(pedidoId, silencioso: true);
      }
    } catch (e) {
      emit(PedidoError(e.toString()));
      rethrow;
    }
  }

  Future<void> excluirAvaliacao(int avaliacaoId) async {
    try {
      await _service.excluirAvaliacao(avaliacaoId);
      if (state is PedidoDetalheCarregado) {
        final pedidoId = (state as PedidoDetalheCarregado).pedido.id;
        await carregarDetalhes(pedidoId, silencioso: true);
      }
    } catch (e) {
      emit(PedidoError(e.toString()));
      rethrow;
    }
  }
}