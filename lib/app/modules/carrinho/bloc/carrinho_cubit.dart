import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/carrinho_item.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../services/carrinho_service.dart';

abstract class CarrinhoState extends Equatable {
  const CarrinhoState();
  @override
  List<Object?> get props => [];
}

class CarrinhoInitial extends CarrinhoState {}

class CarrinhoLoading extends CarrinhoState {}

class CarrinhoLoaded extends CarrinhoState {
  final List<CarrinhoItem> itens;
  final int totalItens;
  final double subtotal;
  final String? lojaNome;
  final bool isUpdating;
  final int? updatingItemId;

  const CarrinhoLoaded({
    required this.itens,
    required this.totalItens,
    required this.subtotal,
    this.lojaNome,
    this.isUpdating = false,
    this.updatingItemId,
  });

  @override
  List<Object?> get props => [
    itens, totalItens, subtotal, lojaNome, 
    isUpdating, updatingItemId
  ];
}

class CarrinhoError extends CarrinhoState {
  final String message;
  const CarrinhoError(this.message);
  @override
  List<Object> get props => [message];
}

class CarrinhoConflitoLoja extends CarrinhoState {
  final int lojaAtualId;
  final String? lojaAtualNome;
  final int novaLojaId;
  final String mensagem;
  
  const CarrinhoConflitoLoja({
    required this.lojaAtualId,
    this.lojaAtualNome,
    required this.novaLojaId,
    required this.mensagem,
  });
  
  @override
  List<Object?> get props => [
    lojaAtualId, lojaAtualNome, novaLojaId, mensagem
  ];
}

class _PendingAdd {
  final int produtoId;
  final int quantidade;
  final List<int> opcoes;
  final String? observacao;

  _PendingAdd({
    required this.produtoId,
    required this.quantidade,
    this.opcoes = const [],
    this.observacao,
  });
}

class CarrinhoCubit extends Cubit<CarrinhoState> {
  final CarrinhoService _service;
  final AuthCubit _authCubit;
  StreamSubscription? _authSubscription;

  Map<int, CarrinhoItem> _itensMap = {};
  bool _isFetching = false;
  bool _isAdding = false;
  bool _isUpdating = false;

  Timer? _addDebounce;
  Timer? _updateDebounce;
  _PendingAdd? _pendingAdd;
  final Map<int, int> _pendingUpdates = {};

  CarrinhoCubit(this._service, this._authCubit) : super(CarrinhoInitial()) {
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        carregarCarrinho();
      } else if (authState is AuthUnauthenticated) {
        _limparEstado();
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _addDebounce?.cancel();
    _updateDebounce?.cancel();
    return super.close();
  }

  void _limparEstado() {
    _itensMap = {};
    _pendingUpdates.clear();
    _pendingAdd = null;
    _addDebounce?.cancel();
    _updateDebounce?.cancel();
    emit(const CarrinhoLoaded(itens: [], totalItens: 0, subtotal: 0));
  }

  Future<void> carregarCarrinho({bool forceRefresh = false}) async {
    if (_isFetching && !forceRefresh) return;
    if (_authCubit.state is! AuthAuthenticated) return;

    _isFetching = true;
    if (state is! CarrinhoLoaded || forceRefresh) emit(CarrinhoLoading());

    try {
      final response = await _service.carregarCarrinho();
      _itensMap = {for (var item in response.itens) item.id: item};
      _pendingUpdates.clear();
      _pendingAdd = null;
      
      emit(CarrinhoLoaded(
        itens: response.itens,
        totalItens: response.resumo.totalItens,
        subtotal: response.resumo.subtotal,
        lojaNome: response.resumo.lojaNome,
      ));
    } catch (e) {
      _limparEstado();
    } finally {
      _isFetching = false;
    }
  }

  Future<void> adicionarItem({
    required int produtoId,
    int quantidade = 1,
    List<int> opcoes = const [],
    String? observacao,
    bool applyDebounce = true,
  }) async {
    if (_authCubit.state is! AuthAuthenticated) throw Exception('Usuário não autenticado');
    if (_isAdding || _isUpdating) return;

    _isAdding = true;
    emit(CarrinhoLoading());

    _pendingAdd = _PendingAdd(
      produtoId: produtoId,
      quantidade: quantidade,
      opcoes: opcoes,
      observacao: observacao,
    );

    _addDebounce?.cancel();
    if(applyDebounce) {
      _addDebounce =
          Timer(const Duration(milliseconds: 1200), () => _executarAdicao());
    }else{
      _executarAdicao();
    }
  }

  Future<void> _executarAdicao() async {
    if (_pendingAdd == null) return;
    final add = _pendingAdd!;
    _pendingAdd = null;

    final result = await _service.atualizarItem(
      produtoId: add.produtoId,
      quantidade: add.quantidade,
      opcoes: add.opcoes,
      observacao: add.observacao,
    );

    _isAdding = false;

    if (result.success && result.data != null) {
      _itensMap = {for (var item in result.data!.itens) item.id: item};
      emit(CarrinhoLoaded(
        itens: result.data!.itens,
        totalItens: result.data!.resumo.totalItens,
        subtotal: result.data!.resumo.subtotal,
        lojaNome: result.data!.resumo.lojaNome,
      ));
    } else if (result.isConflito && result.conflito != null) {
      emit(CarrinhoConflitoLoja(
        lojaAtualId: result.conflito!.lojaAtual,
        lojaAtualNome: result.conflito!.lojaAtualNome,
        novaLojaId: result.conflito!.novaLoja,
        mensagem: result.conflito!.message,
      ));
    } else {
      emit(CarrinhoError(result.message ?? 'Erro ao adicionar item'));
      await carregarCarrinho();
    }
  }

  Future<void> atualizarQuantidade(int itemId, int quantidade) async {
    if (_isUpdating || _isAdding) return;

    if (quantidade == 0) {
      _itensMap.remove(itemId);
    } else if (_itensMap.containsKey(itemId)) {
      _itensMap[itemId] = _itensMap[itemId]!.copyWith(quantidade: quantidade);
    }
    
    _emitirEstadoAtualizado(isUpdating: true, updatingItemId: itemId);
    _pendingUpdates[itemId] = quantidade;

    _updateDebounce?.cancel();
    _updateDebounce = Timer(const Duration(milliseconds: 500), () => _executarAtualizacoes());
  }

  Future<void> _executarAtualizacoes() async {
    if (_pendingUpdates.isEmpty) return;
    _isUpdating = true;
    final updates = Map<int, int>.from(_pendingUpdates);
    _pendingUpdates.clear();

    try {
      for (var entry in updates.entries) {
        await _service.atualizarItem(itemId: entry.key, quantidade: entry.value);
      }
      final response = await _service.carregarCarrinho();
      _itensMap = {for (var item in response.itens) item.id: item};
    } catch (e) {
      await carregarCarrinho();
    } finally {
      _isUpdating = false;
      _emitirEstadoAtualizado();
    }
  }

  void _emitirEstadoAtualizado({bool isUpdating = false, int? updatingItemId}) {
    final itens = _itensMap.values.toList();
    final totalItens = itens.fold<int>(0, (sum, item) => sum + item.quantidade);
    final subtotal = itens.fold<double>(0, (sum, item) => sum + item.precoTotal);
    String? lojaNome = state is CarrinhoLoaded ? (state as CarrinhoLoaded).lojaNome : null;

    emit(CarrinhoLoaded(
      itens: itens,
      totalItens: totalItens,
      subtotal: subtotal,
      lojaNome: lojaNome,
      isUpdating: isUpdating,
      updatingItemId: updatingItemId,
    ));
  }

  Future<void> limparCarrinho() async {
    await _service.limparCarrinho();
    _limparEstado();
  }

  Future<void> limparEAdicionar({
    required int produtoId,
    required int quantidade,
    List<int> opcoes = const [],
    String? observacao,
  }) async {
    _isAdding = true;
    emit(CarrinhoLoading());
    try {
      await _service.limparCarrinho();
      final result = await _service.atualizarItem(
        produtoId: produtoId,
        quantidade: quantidade,
        opcoes: opcoes,
        observacao: observacao,
      );

      _isAdding = false;

      if (result.success && result.data != null) {
        _itensMap = {for (var item in result.data!.itens) item.id: item};
        emit(CarrinhoLoaded(
          itens: result.data!.itens,
          totalItens: result.data!.resumo.totalItens,
          subtotal: result.data!.resumo.subtotal,
          lojaNome: result.data!.resumo.lojaNome,
        ));
      } else {
        emit(CarrinhoError(result.message ?? 'Erro ao adicionar item após limpar'));
      }
    } catch (e) {
      _isAdding = false;
      emit(const CarrinhoError('Erro ao processar requisição'));
    }
  }

  /// Retorna o ID da loja atual do carrinho, ou null se vazio
  int? getLojaIdAtual() {
    final currentState = state;
    if (currentState is CarrinhoLoaded && currentState.itens.isNotEmpty) {
      return currentState.itens.first.lojaId;
    }
    return null;
  }

  /// Verifica se o carrinho tem itens de outra loja
  bool temConflitoComLoja(int novaLojaId) {
    final lojaAtual = getLojaIdAtual();
    return lojaAtual != null && lojaAtual != novaLojaId;
  }

  Future<bool> verificarConflitoLoja(int lojaId) async {
    try {
      final response = await _service.verificarLoja(lojaId);
      return response.carrinhoVazio || response.mesmaLoja;
    } catch (e) {
      return true;
    }
  }

  int getQuantidade(int produtoId) {
    return _itensMap.values
        .where((item) => item.produtoId == produtoId)
        .fold<int>(0, (sum, item) => sum + item.quantidade);
  }

  int? getItemId(int produtoId) {
    try {
      final item = _itensMap.values.firstWhere((item) => item.produtoId == produtoId);
      return item.id;
    } catch (_) {
      return null;
    }
  }
}
