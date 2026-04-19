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
  final bool isRequesting;
  final int? requestingItemId;
  final bool isDebouncing;

  const CarrinhoLoaded({
    required this.itens,
    required this.totalItens,
    required this.subtotal,
    this.lojaNome,
    this.isRequesting = false,
    this.requestingItemId,
    this.isDebouncing = false,
  });

  @override
  List<Object?> get props => [
    itens, totalItens, subtotal, lojaNome, 
    isRequesting, requestingItemId, isDebouncing
  ];

  CarrinhoLoaded copyWith({
    List<CarrinhoItem>? itens,
    int? totalItens,
    double? subtotal,
    String? lojaNome,
    bool? isRequesting,
    int? requestingItemId,
    bool? isDebouncing,
  }) {
    return CarrinhoLoaded(
      itens: itens ?? this.itens,
      totalItens: totalItens ?? this.totalItens,
      subtotal: subtotal ?? this.subtotal,
      lojaNome: lojaNome ?? this.lojaNome,
      isRequesting: isRequesting ?? this.isRequesting,
      requestingItemId: requestingItemId ?? this.requestingItemId,
      isDebouncing: isDebouncing ?? this.isDebouncing,
    );
  }
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
    
    if (state is! CarrinhoLoaded) {
      emit(CarrinhoLoading());
    }

    try {
      final response = await _service.carregarCarrinho();
      _itensMap = {for (var item in response.itens) item.id: item};
      _pendingUpdates.clear();
      _pendingAdd = null;
      
      emit(CarrinhoLoaded(
        itens: _getSortedItens(),
        totalItens: response.resumo.totalItens,
        subtotal: response.resumo.subtotal,
        lojaNome: response.resumo.lojaNome,
        isRequesting: false,
        requestingItemId: null,
        isDebouncing: false,
      ));
    } catch (e) {
      if (state is! CarrinhoLoaded) {
        _limparEstado();
      } else {
        _emitirEstadoAtualizado(isDebouncing: false);
      }
    } finally {
      _isFetching = false;
    }
  }

  List<CarrinhoItem> _getSortedItens() {
    final list = _itensMap.values.toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  Future<void> adicionarItem({
    required int produtoId,
    int quantidade = 1,
    List<int> opcoes = const [],
    String? observacao,
    bool applyDebounce = true,
  }) async {
    if (_authCubit.state is! AuthAuthenticated) throw Exception('Usuário não autenticado');
    if (_isAdding) return;

    _isAdding = true;
    
    if (state is CarrinhoLoaded) {
      emit((state as CarrinhoLoaded).copyWith(isDebouncing: true));
    } else {
      emit(CarrinhoLoading());
    }

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
        itens: _getSortedItens(),
        totalItens: result.data!.resumo.totalItens,
        subtotal: result.data!.resumo.subtotal,
        lojaNome: result.data!.resumo.lojaNome,
        isDebouncing: false,
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

  void atualizarQuantidade(int itemId, int novaQuantidade) {
    final currentState = state;
    if (currentState is! CarrinhoLoaded) return;

    // Garante que o estado isDebouncing seja ativado apenas no primeiro clique
    if (!currentState.isDebouncing) {
      emit(currentState.copyWith(isDebouncing: true));
    }
    
    _pendingUpdates[itemId] = novaQuantidade;
    _updateDebounce?.cancel();
    _updateDebounce = Timer(const Duration(milliseconds: 1500), () => _executarAtualizacoes());
  }

  Future<void> _executarAtualizacoes() async {
    if (_pendingUpdates.isEmpty) {
       _emitirEstadoAtualizado(isDebouncing: false);
       return;
    }
    
    final updates = Map<int, int>.from(_pendingUpdates);
    _pendingUpdates.clear();

    for (var entry in updates.entries) {
      await _enviarAtualizacaoParaAPI(entry.key, entry.value);
    }
    
    await carregarCarrinho(forceRefresh: true);
  }

  Future<void> _enviarAtualizacaoParaAPI(int itemId, int quantidade) async {
    final currentState = state;
    if (currentState is! CarrinhoLoaded) return;

    emit(currentState.copyWith(
      isDebouncing: false,
      isRequesting: true,
      requestingItemId: itemId,
    ));

    try {
      await _service.atualizarItem(itemId: itemId, quantidade: quantidade);
    } catch (e) {
      // carregarCarrinho resolverá
    }
  }

  void _emitirEstadoAtualizado({bool isRequesting = false, int? requestingItemId, bool isDebouncing = false}) {
    final itens = _getSortedItens();
    final totalItens = itens.fold<int>(0, (sum, item) => sum + item.quantidade);
    final subtotal = itens.fold<double>(0, (sum, item) => sum + item.precoTotal);
    String? lojaNome = state is CarrinhoLoaded ? (state as CarrinhoLoaded).lojaNome : null;

    emit(CarrinhoLoaded(
      itens: itens,
      totalItens: totalItens,
      subtotal: subtotal,
      lojaNome: lojaNome,
      isRequesting: isRequesting,
      requestingItemId: requestingItemId,
      isDebouncing: isDebouncing,
    ));
  }

  Future<void> limparCarrinho() async {
    emit(CarrinhoLoading());
    try {
      await _service.limparCarrinho();
      _limparEstado();
    } catch (e) {
      emit(CarrinhoError('Erro ao limpar carrinho'));
      await carregarCarrinho();
    }
  }

  Future<void> removerItem(int itemId) async {
    atualizarQuantidade(itemId, 0);
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
          itens: _getSortedItens(),
          totalItens: result.data!.resumo.totalItens,
          subtotal: result.data!.resumo.subtotal,
          lojaNome: result.data!.resumo.lojaNome,
          isDebouncing: false,
        ));
      } else {
        emit(CarrinhoError(result.message ?? 'Erro ao adicionar item após limpar'));
      }
    } catch (e) {
      _isAdding = false;
      emit(const CarrinhoError('Erro ao processar requisição'));
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
