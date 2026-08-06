import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../enderecos/models/endereco_model.dart';
import 'localizacao_state.dart';

class LocalizacaoCubit extends Cubit<LocalizacaoState> {
  final SharedPreferences _prefs;

  LocalizacaoCubit(this._prefs) : super(LocalizacaoInitial()) {
    carregarLocalizacaoDoEnderecoPadrao(); // ✅ Carregar ao iniciar
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

    final estado = LocalizacaoCarregada(
      endereco: endereco,
      origem: 'gps',
    );
    _salvarLocalizacao(estado);
    emit(estado);
  }

  /// Carrega localização a partir do endereço padrão salvo
  Future<void> carregarLocalizacaoDoEnderecoPadrao() async {
    final enderecoJson = _prefs.getString('endereco_padrao');
    debugPrint('🔍 [LocalizacaoCubit] Carregando endereço salvo: $enderecoJson');
    
    if (enderecoJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(enderecoJson);
        final endereco = EnderecoModel.fromJson(data);
        debugPrint('🔍 [LocalizacaoCubit] Endereço carregado: ${endereco.resumido}');
        
        // Sincronizar ID separado se existir no modelo
        if (endereco.id != null) {
          await _prefs.setInt('endereco_padrao_id', endereco.id!);
        }

        emit(LocalizacaoCarregada(
          endereco: endereco,
          origem: data['origem'] ?? 'endereco_padrao',
        ));
      } catch (e) {
        debugPrint('❌ [LocalizacaoCubit] Erro ao decodificar endereço: $e');
        emit(LocalizacaoNaoEncontrada());
      }
    } else {
      debugPrint('🔍 [LocalizacaoCubit] Nenhum endereço salvo encontrado');
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

    final estado = LocalizacaoCarregada(
      endereco: endereco,
      origem: 'manual',
    );
    
    _salvarLocalizacao(estado);
    emit(estado);
    debugPrint('✅ [LocalizacaoCubit] Cubit atualizado e salvo: ${endereco.resumido}');
  }

  /// Define a localização a partir de um modelo completo (após confirmação da API)
  void definirEnderecoCompleto(EnderecoModel endereco, {String origem = 'manual'}) {
    debugPrint('🔍 [LocalizacaoCubit] definirEnderecoCompleto: ${endereco.resumido}');
    final estado = LocalizacaoCarregada(
      endereco: endereco,
      origem: origem,
    );
    _salvarLocalizacao(estado);
    emit(estado);
    debugPrint('✅ [LocalizacaoCubit] Endereço completo definido e salvo: ${endereco.resumido}');
  }

  Future<void> _salvarLocalizacao(LocalizacaoCarregada estado) async {
    try {
      final data = estado.endereco.toJson();
      data['origem'] = estado.origem;
      final json = jsonEncode(data);
      await _prefs.setString('endereco_padrao', json);
      
      if (estado.endereco.id != null) {
        await _prefs.setInt('endereco_padrao_id', estado.endereco.id!);
        debugPrint('✅ [LocalizacaoCubit] ID do endereço salvo: ${estado.endereco.id}');
      } else {
        await _prefs.remove('endereco_padrao_id');
      }

      debugPrint('✅ [LocalizacaoCubit] Dados persistidos no SharedPreferences: $json');
    } catch (e) {
      debugPrint('❌ [LocalizacaoCubit] Erro ao persistir endereço: $e');
    }
  }

  Future<void> limparLocalizacao() async {
    await _prefs.remove('endereco_padrao');
    await _prefs.remove('endereco_padrao_id');
    debugPrint('🗑️ [LocalizacaoCubit] Endereço removido do SharedPreferences');
    emit(LocalizacaoNaoEncontrada());
  }
}
