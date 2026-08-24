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

  Future<void> carregarDetalhes(int pedidoId) async {
    // 🔥 Mantemos a lista anterior no estado de loading se possível
    emit(PedidoLoading());
    try {
      final pedido = await _service.getPedidoDetalhe(pedidoId);
      emit(PedidoDetalheCarregado(pedido, pedidos: _lastPedidos));
    } catch (e) {
      emit(PedidoError(e.toString()));
    }
  }

  Future<void> carregarPedidos() async {
    emit(PedidoLoading());
    try {
      final pedidos = await _service.getPedidos();
      _lastPedidos = pedidos; // 🔥 Cache da lista
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
}
