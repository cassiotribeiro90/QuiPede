import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../di/dependencies.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import '../../enderecos/models/endereco_model.dart';
import 'localizacao_state.dart';

class LocalizacaoCubit extends Cubit<LocalizacaoState> {
  StreamSubscription? _enderecoSubscription;

  LocalizacaoCubit() : super(LocalizacaoInitial()) {
    carregarLocalizacaoDoEnderecoPadrao();
    _ouvirEnderecos();
  }

  void _ouvirEnderecos() {
    final enderecoCubit = getIt<EnderecoCubit>();
    _enderecoSubscription = enderecoCubit.stream.listen((enderecoState) {
      if (enderecoState is EnderecoLoaded) {
        if (enderecoState.enderecos.isEmpty) {
          debugPrint('🔔 [LocalizacaoCubit] Lista de endereços vazia → emitindo LocalizacaoNaoEncontrada');
          if (!isClosed && state is! LocalizacaoNaoEncontrada) {
            emit(LocalizacaoNaoEncontrada());
          }
        } else if (state is LocalizacaoNaoEncontrada && enderecoState.enderecoPrincipal != null) {
          // ✅ Se encontrou endereço e estávamos em "Não Encontrada", define o principal
          definirEnderecoCompleto(enderecoState.enderecoPrincipal!, origem: 'endereco_padrao');
        }
      }
    });
  }

  /// Atualiza a posição atual (vinda do GPS)
  void atualizarPosicao(Position posicao, {String? enderecoFormatado}) {
    final endereco = EnderecoModel(
      cep: '',
      logradouro: enderecoFormatado ?? 'Localização atual',
      numero: 'S/N',
      bairro: '',
      cidade: '',
      uf: '',
      latitude: posicao.latitude,
      longitude: posicao.longitude,
    );

    emit(LocalizacaoCarregada(
      endereco: endereco,
      origem: 'gps',
    ));
  }

  /// Carrega localização a partir do endereço padrão do backend
  Future<void> carregarLocalizacaoDoEnderecoPadrao() async {
    debugPrint('🔍 [LocalizacaoCubit] Carregando endereço padrão do backend...');
    try {
      final enderecoCubit = getIt<EnderecoCubit>();
      await enderecoCubit.carregarEnderecos();
      final enderecoState = enderecoCubit.state;
      
      if (enderecoState is EnderecoLoaded && enderecoState.enderecoPrincipal != null) {
        definirEnderecoCompleto(enderecoState.enderecoPrincipal!, origem: 'endereco_padrao');
      } else {
        emit(LocalizacaoNaoEncontrada());
      }
    } catch (e) {
      debugPrint('❌ [LocalizacaoCubit] Erro ao carregar endereços: $e');
      emit(LocalizacaoNaoEncontrada());
    }
  }

  /// Define um endereço manual como localização atual
  void definirLocalizacaoManual({
    required double latitude,
    required double longitude,
    String? enderecoFormatado,
    String? referencia,
  }) {
    final endereco = EnderecoModel(
      cep: '',
      logradouro: enderecoFormatado ?? 'Endereço definido',
      numero: '',
      bairro: '',
      cidade: '',
      uf: '',
      referencia: referencia,
      latitude: latitude,
      longitude: longitude,
    );

    debugPrint('🔍 [LocalizacaoCubit] definirLocalizacaoManual: ${endereco.resumido}');

    emit(LocalizacaoCarregada(
      endereco: endereco,
      origem: 'manual',
    ));
    debugPrint('✅ [LocalizacaoCubit] Cubit atualizado em memória: ${endereco.resumido}');
  }

  /// Define a localização a partir de um modelo completo (após confirmação da API)
  void definirEnderecoCompleto(EnderecoModel endereco, {String origem = 'manual'}) {
    debugPrint('🔍 [LocalizacaoCubit] definirEnderecoCompleto: ${endereco.resumido}');
    emit(LocalizacaoCarregada(
      endereco: endereco,
      origem: origem,
    ));
    debugPrint('✅ [LocalizacaoCubit] Endereço completo definido em memória: ${endereco.resumido}');
  }

  Future<void> limparLocalizacao() async {
    debugPrint('🗑️ [LocalizacaoCubit] Limpando localização da memória');
    emit(LocalizacaoNaoEncontrada());
  }

  @override
  Future<void> close() {
    _enderecoSubscription?.cancel();
    return super.close();
  }
}
