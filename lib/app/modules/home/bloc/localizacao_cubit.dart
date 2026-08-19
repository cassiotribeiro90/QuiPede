import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../di/dependencies.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import '../../enderecos/models/endereco_model.dart';
import 'localizacao_state.dart';

class LocalizacaoCubit extends Cubit<LocalizacaoState> {
  final SharedPreferences _prefs;
  StreamSubscription? _enderecoSubscription;

  LocalizacaoCubit(this._prefs) : super(LocalizacaoInitial());
  // ✅ SEM chamadas no construtor

  void iniciarListenerEnderecos() {
    _enderecoSubscription?.cancel();
    final enderecoCubit = getIt<EnderecoCubit>();
    _enderecoSubscription = enderecoCubit.stream.listen((enderecoState) {
      if (enderecoState is EnderecoLoaded) {
        if (enderecoState.enderecos.isEmpty) {
          debugPrint('🔔 [LocalizacaoCubit] Lista de endereços vazia → emitindo LocalizacaoNaoEncontrada');
          if (!isClosed && state is! LocalizacaoNaoEncontrada) {
            emit(LocalizacaoNaoEncontrada());
          }
        } else if (state is LocalizacaoNaoEncontrada && enderecoState.enderecoPrincipal != null) {
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
    debugPrint('📍 [LocalizacaoCubit] carregarLocalizacaoDoEnderecoPadrao chamado');

    try {
      final enderecoCubit = getIt<EnderecoCubit>();
      await enderecoCubit.carregarEnderecos();
      final enderecoState = enderecoCubit.state;

      if (enderecoState is EnderecoLoaded && enderecoState.enderecoPrincipal != null) {
        await definirEnderecoCompleto(enderecoState.enderecoPrincipal!, origem: 'endereco_padrao');
      } else {
        // Fallback para SharedPreferences
        final json = _prefs.getString('endereco_padrao_json');
        if (json != null) {
          final endereco = EnderecoModel.fromJson(jsonDecode(json));
          emit(LocalizacaoCarregada(endereco: endereco, origem: 'fallback_local'));
        } else {
          emit(LocalizacaoNaoEncontrada());
        }
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

    emit(LocalizacaoCarregada(
      endereco: endereco,
      origem: 'manual',
    ));
  }

  /// Define a localização a partir de um modelo completo
  Future<void> definirEnderecoCompleto(EnderecoModel endereco, {String origem = 'manual'}) async {
    debugPrint('🔍 [LocalizacaoCubit] definirEnderecoCompleto: ${endereco.resumido}');

    try {
      await _prefs.setInt('endereco_padrao_id', endereco.id ?? -1);
      await _prefs.setString('endereco_padrao_json', jsonEncode(endereco.toJson()));
    } catch (e) {
      debugPrint('⚠️ [LocalizacaoCubit] Erro ao persistir: $e');
    }

    emit(LocalizacaoCarregada(
      endereco: endereco,
      origem: origem,
    ));
  }

  Future<void> limparLocalizacao() async {
    await _prefs.remove('endereco_padrao_id');
    await _prefs.remove('endereco_padrao_json');
    emit(LocalizacaoNaoEncontrada());
  }

  @override
  Future<void> close() {
    _enderecoSubscription?.cancel();
    return super.close();
  }
}