import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localizacao_state.dart';

class LocalizacaoCubit extends Cubit<LocalizacaoState> {
  final SharedPreferences _prefs;

  LocalizacaoCubit(this._prefs) : super(LocalizacaoInitial());

  /// Atualiza a posição atual (vinda do GPS)
  void atualizarPosicao(Position posicao, {String? enderecoFormatado}) {
    final estado = LocalizacaoCarregada(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
      enderecoFormatado: enderecoFormatado,
      origem: 'gps',
    );
    _salvarLocalizacao(estado);
    emit(estado);
  }

  /// Carrega localização a partir do endereço padrão salvo
  Future<void> carregarLocalizacaoDoEnderecoPadrao() async {
    final enderecoJson = _prefs.getString('endereco_padrao');
    
    if (enderecoJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(enderecoJson);
        emit(LocalizacaoCarregada(
          latitude: (data['latitude'] as num).toDouble(),
          longitude: (data['longitude'] as num).toDouble(),
          enderecoFormatado: data['enderecoFormatado'],
          origem: data['origem'] ?? 'endereco_padrao',
        ));
      } catch (e) {
        emit(LocalizacaoNaoEncontrada());
      }
    } else {
      emit(LocalizacaoNaoEncontrada());
    }
  }

  /// Define um endereço manual como localização atual
  void definirLocalizacaoManual({
    required double latitude,
    required double longitude,
    String? enderecoFormatado,
  }) {
    final estado = LocalizacaoCarregada(
      latitude: latitude,
      longitude: longitude,
      enderecoFormatado: enderecoFormatado,
      origem: 'manual',
    );
    _salvarLocalizacao(estado);
    emit(estado);
  }

  Future<void> _salvarLocalizacao(LocalizacaoCarregada estado) async {
    final data = {
      'latitude': estado.latitude,
      'longitude': estado.longitude,
      'enderecoFormatado': estado.enderecoFormatado,
      'origem': estado.origem,
    };
    await _prefs.setString('endereco_padrao', jsonEncode(data));
  }

  Future<void> limparLocalizacao() async {
    await _prefs.remove('endereco_padrao');
    emit(LocalizacaoNaoEncontrada());
  }
}
