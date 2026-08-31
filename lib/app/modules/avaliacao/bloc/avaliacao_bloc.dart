import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quipede/app/models/avaliacao_model.dart';
import 'package:quipede/app/models/resumo_avaliacao_model.dart';
import 'package:quipede/app/repositories/avaliacao_repository.dart';

part 'avaliacao_event.dart';
part 'avaliacao_state.dart';

class AvaliacaoBloc extends Bloc<AvaliacaoEvent, AvaliacaoState> {
  final AvaliacaoRepository _repository = AvaliacaoRepository();

  AvaliacaoBloc() : super(AvaliacaoInitial()) {
    on<CarregarMinhasAvaliacoes>(_onCarregarMinhasAvaliacoes);
    on<CarregarAvaliacaoLoja>(_onCarregarAvaliacaoLoja);
    on<CarregarAvaliacaoProduto>(_onCarregarAvaliacaoProduto);
    on<CriarAvaliacao>(_onCriarAvaliacao);
    on<AtualizarAvaliacao>(_onAtualizarAvaliacao);
    on<DeletarAvaliacao>(_onDeletarAvaliacao);
    on<CarregarAvaliacoesLojista>(_onCarregarAvaliacoesLojista);
    on<CarregarResumoAvaliacoesLojista>(_onCarregarResumoAvaliacoesLojista);
    on<ResponderAvaliacao>(_onResponderAvaliacao);
    on<AtualizarStatusAvaliacao>(_onAtualizarStatusAvaliacao);
    on<CarregarAvaliacaoPedido>(_onCarregarAvaliacaoPedido);
  }

  // ================================================================
  // 🔥 CLIENTE
  // ================================================================

  Future<void> _onCarregarMinhasAvaliacoes(
    CarregarMinhasAvaliacoes event,
    Emitter<AvaliacaoState> emit,
  ) async {
    emit(AvaliacaoLoading());
    try {
      final avaliacoes = await _repository.getMinhasAvaliacoes();
      emit(AvaliacaoLoaded(avaliacoes: avaliacoes));
    } catch (e) {
      emit(AvaliacaoError(message: e.toString()));
    }
  }

  Future<void> _onCarregarAvaliacaoLoja(
    CarregarAvaliacaoLoja event,
    Emitter<AvaliacaoState> emit,
  ) async {
    emit(AvaliacaoLoading());
    try {
      final data = await _repository.getAvaliacoesLoja(event.lojaId);
      emit(AvaliacaoLojaLoaded(
        media: data['media'] ?? 0.0,
        total: data['total'] ?? 0,
        distribuicao: Map<int, int>.from(data['distribuicao'] ?? {}),
        avaliacoes: (data['avaliacoes'] as List?)
            ?.map((item) => AvaliacaoModel.fromJson(item))
            .toList() ?? [],
      ));
    } catch (e) {
      emit(AvaliacaoError(message: e.toString()));
    }
  }

  Future<void> _onCarregarAvaliacaoProduto(
    CarregarAvaliacaoProduto event,
    Emitter<AvaliacaoState> emit,
  ) async {
    emit(AvaliacaoLoading());
    try {
      final data = await _repository.getAvaliacoesProduto(event.produtoId);
      emit(AvaliacaoProdutoLoaded(
        media: data['media'] ?? 0.0,
        total: data['total'] ?? 0,
        distribuicao: Map<int, int>.from(data['distribuicao'] ?? {}),
        avaliacoes: (data['avaliacoes'] as List?)
            ?.map((item) => AvaliacaoModel.fromJson(item))
            .toList() ?? [],
      ));
    } catch (e) {
      emit(AvaliacaoError(message: e.toString()));
    }
  }

  Future<void> _onCriarAvaliacao(
    CriarAvaliacao event,
    Emitter<AvaliacaoState> emit,
  ) async {
    emit(AvaliacaoLoading());
    try {
      final avaliacao = await _repository.criarAvaliacao(event.data);
      emit(AvaliacaoCreated(avaliacao: avaliacao));
      
      // Recarrega a lista
      add(CarregarMinhasAvaliacoes());
    } catch (e) {
      emit(AvaliacaoError(message: e.toString()));
    }
  }

  Future<void> _onAtualizarAvaliacao(
    AtualizarAvaliacao event,
    Emitter<AvaliacaoState> emit,
  ) async {
    emit(AvaliacaoLoading());
    try {
      final avaliacao = await _repository.atualizarAvaliacao(event.id, event.data);
      emit(AvaliacaoUpdated(avaliacao: avaliacao));
      
      // Recarrega a lista
      add(CarregarMinhasAvaliacoes());
    } catch (e) {
      emit(AvaliacaoError(message: e.toString()));
    }
  }

  Future<void> _onDeletarAvaliacao(
    DeletarAvaliacao event,
    Emitter<AvaliacaoState> emit,
  ) async {
    emit(AvaliacaoLoading());
    try {
      await _repository.deletarAvaliacao(event.id);
      emit(AvaliacaoDeleted());
      
      // Recarrega a lista
      add(CarregarMinhasAvaliacoes());
    } catch (e) {
      emit(AvaliacaoError(message: e.toString()));
    }
  }

  Future<void> _onCarregarAvaliacaoPedido(
    CarregarAvaliacaoPedido event,
    Emitter<AvaliacaoState> emit,
  ) async {
    try {
      final avaliacao = await _repository.getAvaliacaoPedido(event.pedidoId);
      if (avaliacao != null) {
        emit(AvaliacaoPedidoLoaded(avaliacao: avaliacao));
      } else {
        emit(AvaliacaoPedidoVazio());
      }
    } catch (e) {
      emit(AvaliacaoPedidoVazio());
    }
  }

  // ================================================================
  // 🔥 LOJISTA
  // ================================================================

  Future<void> _onCarregarAvaliacoesLojista(
    CarregarAvaliacoesLojista event,
    Emitter<AvaliacaoState> emit,
  ) async {
    emit(AvaliacaoLoading());
    try {
      final avaliacoes = await _repository.getAvaliacoesLojista();
      emit(AvaliacaoLojistaLoaded(avaliacoes: avaliacoes));
    } catch (e) {
      emit(AvaliacaoError(message: e.toString()));
    }
  }

  Future<void> _onCarregarResumoAvaliacoesLojista(
    CarregarResumoAvaliacoesLojista event,
    Emitter<AvaliacaoState> emit,
  ) async {
    emit(AvaliacaoLoading());
    try {
      final resumo = await _repository.getResumoAvaliacoesLojista();
      emit(AvaliacaoResumoLoaded(resumo: resumo));
    } catch (e) {
      emit(AvaliacaoError(message: e.toString()));
    }
  }

  Future<void> _onResponderAvaliacao(
    ResponderAvaliacao event,
    Emitter<AvaliacaoState> emit,
  ) async {
    emit(AvaliacaoLoading());
    try {
      final avaliacao = await _repository.responderAvaliacao(event.id, event.resposta);
      emit(AvaliacaoRespondida(avaliacao: avaliacao));
      
      // Recarrega a lista do lojista
      add(CarregarAvaliacoesLojista());
      add(CarregarResumoAvaliacoesLojista());
    } catch (e) {
      emit(AvaliacaoError(message: e.toString()));
    }
  }

  Future<void> _onAtualizarStatusAvaliacao(
    AtualizarStatusAvaliacao event,
    Emitter<AvaliacaoState> emit,
  ) async {
    emit(AvaliacaoLoading());
    try {
      final avaliacao = await _repository.atualizarStatusAvaliacao(event.id, event.status);
      emit(AvaliacaoStatusUpdated(avaliacao: avaliacao));
      
      // Recarrega a lista do lojista
      add(CarregarAvaliacoesLojista());
      add(CarregarResumoAvaliacoesLojista());
    } catch (e) {
      emit(AvaliacaoError(message: e.toString()));
    }
  }
}
