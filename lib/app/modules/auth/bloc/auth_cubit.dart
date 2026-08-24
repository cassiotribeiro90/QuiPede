// lib/app/modules/auth/bloc/auth_cubit.dart

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../shared/api/api_client.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../models/auth_response_model.dart';
import '../models/usuario_model.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import '../../enderecos/models/endereco_model.dart';
import '../../../core/services/device_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;
  final LocalizacaoCubit _localizacaoCubit;
  final AuthService _authService;
  final EnderecoCubit _enderecoCubit;
  final SharedPreferences _prefs;
  final DeviceService _deviceService = DeviceService();
  bool _isProcessing = false;
  UsuarioModel? _usuario;

  static const String keyAccessToken = 'access_token';
  static const String keyGuestToken = 'guest_token';

  AuthCubit(
      this._apiClient,
      this._localizacaoCubit,
      this._enderecoCubit,
      this._prefs,
      )   : _authService = AuthService(_apiClient),
        super(AuthInitial());

  UsuarioModel? get usuario => _usuario;

  // ============ INICIALIZAÇÃO ============

  Future<void> inicializarApp() async {
    if (_isProcessing) return;
    _isProcessing = true;

    developer.log('🔐 [AuthCubit] 🔥 INICIALIZANDO APP...', name: 'AUTH');
    emit(AuthLoading());

    try {
      // ✅ 1. LOG DO TOKEN
      final token = _apiClient.tokenService.getAccessToken();
      final isGuest = _apiClient.tokenService.isGuest();
      developer.log('🔐 [AuthCubit] Token: ${token != null ? "SIM (${token.substring(0, token.length > 10 ? 10 : token.length)}...)" : "NÃO"}', name: 'AUTH');
      developer.log('🔐 [AuthCubit] isGuest: $isGuest', name: 'AUTH');

      // ✅ 2. LIMPA LOCALIZAÇÃO
      await _localizacaoCubit.limparLocalizacao();
      developer.log('🗑️ [AuthCubit] Localização limpa', name: 'AUTH');

      if (token != null && token.isNotEmpty) {
        // ✅ 3. BUSCA USUÁRIO NO BACKEND
        try {
          developer.log('📡 [AuthCubit] Buscando usuário no backend...', name: 'AUTH');
          final response = await _apiClient.get('app/auth/me', requiresAuth: true);

          if (response.statusCode == 200 && response.data['success'] == true) {
            final data = response.data['data'];
            developer.log('✅ [AuthCubit] Usuário encontrado no backend', name: 'AUTH');

            // ✅ 4. PROCESSA DADOS
            final authResponse = AuthResponse.fromJson(data);
            _usuario = authResponse.user;
            developer.log('👤 [AuthCubit] Usuário: ${_usuario?.nome}, status: ${_usuario?.status}', name: 'AUTH');

            if (_usuario != null) {
              await _apiClient.tokenService.saveUser(_usuario!.toJson());
              developer.log('💾 [AuthCubit] Usuário salvo no cache', name: 'AUTH');
            }

            final enderecosJson = data['enderecos'];
            final enderecoPrincipalJson = data['endereco'];
            await _sincronizarEnderecos(enderecosJson, enderecoPrincipalJson);

            if (isGuest) {
              emit(AuthGuest(accessToken: token, user: _usuario));
            } else {
              emit(AuthAuthenticated(accessToken: token, user: _usuario));
            }

            developer.log('✅ [AuthCubit] Autenticado com sucesso', name: 'AUTH');
            await carregarEnderecoUsuario();
            _isProcessing = false;
            return;
          }
        } catch (e) {
          developer.log('⚠️ [AuthCubit] Erro ao buscar /me, usando cache local: $e', name: 'AUTH');
        }

        // ✅ 5. FALLBACK PARA CACHE LOCAL
        developer.log('📦 [AuthCubit] Usando cache local...', name: 'AUTH');
        final userJson = _apiClient.tokenService.getUser();
        if (userJson != null) {
          _usuario = UsuarioModel.fromJson(userJson);
          developer.log('👤 [AuthCubit] Usuário do cache: ${_usuario?.nome}', name: 'AUTH');
        }

        if (isGuest) {
          emit(AuthGuest(accessToken: token, user: _usuario));
        } else {
          emit(AuthAuthenticated(accessToken: token, user: _usuario));
        }

        await carregarEnderecoUsuario();
        _isProcessing = false;
        return;
      }

      developer.log('🚫 [AuthCubit] Nenhum token encontrado', name: 'AUTH');
      emit(AuthUnauthenticated());
    } catch (e) {
      developer.log('❌ [AuthCubit] ERRO NA INICIALIZAÇÃO: $e', name: 'AUTH', error: e);
      emit(AuthUnauthenticated());
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> recarregarUsuario() async {
    try {
      final token = _apiClient.tokenService.getAccessToken();
      if (token == null || token.isEmpty) return;

      final isGuest = _apiClient.tokenService.isGuest();

      final response = await _apiClient.get('app/auth/me', requiresAuth: true);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final usuarioJson = data['usuario'] ?? data['user'];

        if (usuarioJson != null) {
          _usuario = UsuarioModel.fromJson(Map<String, dynamic>.from(usuarioJson));
          await _apiClient.tokenService.saveUser(_usuario!.toJson());

          if (isGuest) {
            emit(AuthGuest(accessToken: token, user: _usuario));
          } else {
            emit(AuthAuthenticated(accessToken: token, user: _usuario));
          }

          debugPrint('🔄 [AuthCubit] Usuário recarregado: ${_usuario?.nome} (isGuest: $isGuest)');
        }
      }
    } catch (e) {
      debugPrint('❌ [AuthCubit] Erro ao recarregar usuário: $e');
    }
  }

  // ============ MÉTODOS OTP (TELEFONE) ============

  Future<void> enviarTelefone(String telefone) async {
    debugPrint('🧭 [AuthCubit] ========================================');
    debugPrint('🧭 [AuthCubit] enviarTelefone chamado');
    debugPrint('🧭 [AuthCubit] 📞 Telefone recebido: "$telefone"');
    debugPrint('🧭 [AuthCubit] 📞 Telefone length: ${telefone.length}');

    // ✅ Verifica se o telefone está vazio
    if (telefone.trim().isEmpty) {
      debugPrint('❌ [AuthCubit] Telefone vazio!');
      emit(const AuthOtpErro('Telefone é obrigatório'));
      return;
    }

    // ✅ Remove caracteres não numéricos
    final cleanedPhone = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    debugPrint('🧭 [AuthCubit] 📞 Telefone limpo: "$cleanedPhone"');
    debugPrint('🧭 [AuthCubit] 📞 Telefone limpo length: ${cleanedPhone.length}');

    if (cleanedPhone.isEmpty) {
      debugPrint('❌ [AuthCubit] Telefone sem números válidos!');
      emit(const AuthOtpErro('Telefone inválido'));
      return;
    }

    if (cleanedPhone.length != 11) {
      debugPrint('❌ [AuthCubit] Telefone com tamanho incorreto: ${cleanedPhone.length} (esperado: 11)');
      emit(const AuthOtpErro('Telefone inválido. Use DDD + 9 dígitos'));
      return;
    }

    emit(AuthLoading());
    try {
      debugPrint('🧭 [AuthCubit] Chamando _authService.enviarTelefone com: "$cleanedPhone"');
      await _authService.enviarTelefone(cleanedPhone);
      debugPrint('🧭 [AuthCubit] ✅ Sucesso ao enviar telefone. Emitindo AuthPhoneEnviado.');
      emit(AuthPhoneEnviado(telefone: cleanedPhone));
    } catch (e) {
      debugPrint('🧭 [AuthCubit] ❌ Erro ao enviar telefone: $e');
      emit(const AuthOtpErro('Erro ao enviar código. Tente novamente.'));
    }
    debugPrint('🧭 [AuthCubit] ========================================');
  }

  Future<void> verificarOTP(String telefone, String codigo, {bool redirectToCheckout = false}) async {
    debugPrint('🧭 [AuthCubit] ========================================');
    debugPrint('[AUTH_CUBIT] 🔍 verificarOTP chamado');
    debugPrint('[AUTH_CUBIT] 📞 Phone: $telefone');
    debugPrint('[AUTH_CUBIT] 🔢 Code: $codigo');

    // ✅ Verifica se o telefone está vazio
    if (telefone.trim().isEmpty) {
      debugPrint('❌ [AuthCubit] Telefone vazio!');
      emit(const AuthOtpErro('Telefone é obrigatório'));
      return;
    }

    // ✅ Verifica se o código está vazio
    if (codigo.trim().isEmpty) {
      debugPrint('❌ [AuthCubit] Código vazio!');
      emit(const AuthOtpErro('Código é obrigatório'));
      return;
    }

    emit(AuthOtpVerificando(telefone: telefone));
    try {
      debugPrint('[AUTH_CUBIT] 📱 Obtendo FCM token...');
      String? fcmToken;

      // ✅ Proteção Robusta para Web e Windows
      if (kIsWeb) {
        try {
          // No Web, getToken pode exigir vapidKey ou falhar se não houver permissão
          fcmToken = await FirebaseMessaging.instance.getToken().timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              debugPrint('[AUTH_CUBIT] ⏰ FCM Token timeout no Web');
              return null;
            },
          );
        } catch (e) {
          debugPrint('[AUTH_CUBIT] ⚠️ Erro FCM Web: $e');
        }
      } else {
        // Mobile (Android/iOS)
        try {
          // Evita usar dart:io Platform diretamente sem check kIsWeb
          // Mas aqui já sabemos que não é Web
          bool isWindows = false;
          try {
            isWindows = Platform.isWindows;
          } catch (_) {}

          if (!isWindows) {
            fcmToken = await FirebaseMessaging.instance.getToken();
          }
        } catch (e) {
          debugPrint('[AUTH_CUBIT] ⚠️ Erro FCM Mobile: $e');
        }
      }

      if (fcmToken != null) {
        debugPrint('[AUTH_CUBIT] 📱 FCM Token obtido: ${fcmToken.substring(0, 15)}...');
      }

      debugPrint('[AUTH_CUBIT] 📤 Chamando service.verificarOTP...');
      final responseData = await _authService.verificarOTP(telefone, codigo, deviceToken: fcmToken);
      debugPrint('[AUTH_CUBIT] 📥 Resposta recebida: $responseData');

      final data = responseData['data'];

      debugPrint('🔍 [AuthCubit] verificarOTP - Dados recebidos:');
      debugPrint('🔍 [AuthCubit] usuario: ${data['usuario'] ?? data['user']}');
      debugPrint('🔍 [AuthCubit] endereco: ${data['endereco']}');
      debugPrint('🔍 [AuthCubit] enderecos: ${data['enderecos']}');

      // ✅ LIMPAR localização anterior ANTES de processar
      await _localizacaoCubit.limparLocalizacao();

      final accessToken = data['access_token'] ?? data['token'];
      final refreshToken = data['refresh_token']; // ✅ PEGA O REFRESH TOKEN
      final userJson = data['usuario'] ?? data['user'];
      final enderecoJson = data['endereco'];

      if (userJson != null) {
        final usuarioMap = Map<String, dynamic>.from(userJson);

        // ✅ Salva tokens IMEDIATAMENTE
        await _apiClient.tokenService.saveTokens(accessToken, refreshToken, isGuest: false);
        debugPrint('🔑 [AuthCubit] Access token salvo após OTP: ${accessToken.substring(0, 10)}...');
        debugPrint('🔑 [AuthCubit] Refresh token salvo após OTP: ${refreshToken != null ? refreshToken.substring(0, 10) + "..." : "NULO"}');

        var user = UsuarioModel.fromJson(usuarioMap);

        // 🔥 Se o status não veio do backend, defina com base nos dados disponíveis
        if (user.status == null) {
          final nome = user.nome;
          final telefone = user.telefone ?? '';

          if (nome.isNotEmpty) {
            user = user.copyWith(status: 'ativo');
          } else if (telefone.isNotEmpty) {
            user = user.copyWith(status: 'pendente');
          } else {
            user = user.copyWith(status: 'convidado');
          }
        }

        // ✅ Marca como telefone verificado localmente após sucesso no OTP
        user = user.copyWith(telefoneVerificado: true);

        _usuario = user;
        debugPrint('🔐 [AuthCubit] verificarOTP: _usuario definido: nome=${_usuario?.nome}, email=${_usuario?.email}, status=${_usuario?.status}, telefone=${_usuario?.telefone}');

        await _sincronizarEnderecos(
          data['enderecos'],
          data['endereco'],
        );

        // ✅ Salva cache local atualizado (inclui status forçado se necessário)
        await _apiClient.tokenService.saveUser(_usuario!.toJson());
        debugPrint('💾 [AuthCubit] verificarOTP: usuário salvo: ${_usuario?.nome}');

        debugPrint('🔐 [AuthCubit] Estado emitido: AuthAuthenticated');
        debugPrint('🔐 [AuthCubit] Dados do usuário: status=${_usuario!.status}, telefone=${_usuario!.telefone}, nome=${_usuario!.nome}');

        emit(AuthAuthenticated(accessToken: accessToken, user: _usuario));

        // ✅ Se TEM endereço, define; se NÃO tem, já foi limpo
        if (enderecoJson != null) {
          final endereco = EnderecoModel.fromJson(Map<String, dynamic>.from(enderecoJson));
          await _localizacaoCubit.definirEnderecoCompleto(endereco, origem: 'endereco_padrao');
        } else {
          // ✅ Garante que está limpo
          await _localizacaoCubit.limparLocalizacao();
        }

        await carregarEnderecoUsuario();

        // ✅ Não navega mais daqui — o AppRouter cuida do redirecionamento
      } else {
        debugPrint('❌ [AuthCubit] Usuário não encontrado na resposta');
        emit(const AuthOtpErro('Usuário não encontrado após verificação.'));
      }
    } catch (e) {
      debugPrint('[AUTH_CUBIT] ❌ Erro no verificarOTP: $e');
      emit(const AuthOtpErro('Código inválido. Tente novamente.'));
    }
    debugPrint('🧭 [AuthCubit] ========================================');
  }

  // ============ ATUALIZAÇÃO DE PERFIL ============

  Future<void> completarPerfil({
    required String nome,
    String? email,
  }) async => _salvarPerfil(nome: nome, email: email, isInitialCompletion: true);

  Future<void> atualizarPerfil({
    required String nome,
    String? email,
  }) async => _salvarPerfil(nome: nome, email: email, isInitialCompletion: false);

  Future<void> _salvarPerfil({
    required String nome,
    String? email,
    required bool isInitialCompletion,
  }) async {
    debugPrint('📝 [AuthCubit] Salvando perfil: nome=$nome, email=$email, inicial=$isInitialCompletion');
    emit(AuthLoading());

    try {
      final token = _apiClient.tokenService.getAccessToken();
      final response = await _authService.atualizarPerfil(nome: nome, email: email);

      final data = response['data'];
      final usuarioJson = data['usuario'] ?? data['user'];

      if (usuarioJson != null) {
        final usuarioMap = Map<String, dynamic>.from(usuarioJson);
        _usuario = UsuarioModel.fromJson(usuarioMap);
        await _apiClient.tokenService.saveUser(usuarioMap);
        debugPrint('💾 [AuthCubit] _salvarPerfil: usuário salvo: ${_usuario?.nome}');

        await _sincronizarEnderecos(data['enderecos'], data['endereco']);

        debugPrint('🔐 [AuthCubit] _salvarPerfil: _usuario definido: nome=${_usuario?.nome}, email=${_usuario?.email}, status=${_usuario?.status}');

        // ✅ SEMPRE emite AuthAuthenticated
        emit(AuthAuthenticated(accessToken: token ?? '', user: _usuario));
      } else {
        emit(const AuthError('Erro ao salvar perfil. Tente novamente.'));
      }
    } catch (e) {
      debugPrint('❌ [AuthCubit] Erro ao salvar perfil: $e');
      emit(const AuthError('Erro ao salvar perfil. Tente novamente.'));
    }
  }

  Future<void> iniciarAtualizacaoTelefone(String telefone) async {
    emit(AuthLoading());
    try {
      final response = await _authService.iniciarAtualizacaoTelefone(telefone);
      if (response['success'] == true) {
        // Emitimos um estado que indica que o código foi enviado para o NOVO telefone
        emit(AuthPhoneEnviado(telefone: telefone));
      } else {
        emit(AuthError(response['message'] ?? 'Erro ao iniciar atualização de telefone'));
      }
    } catch (e) {
      emit(const AuthError('Erro ao iniciar atualização de telefone'));
    }
  }

  Future<void> confirmarAtualizacaoTelefone({
    required String telefone,
    required String codigo,
  }) async {
    emit(AuthLoading());
    try {
      final response = await _authService.confirmarAtualizacaoTelefone(
        telefone: telefone,
        codigo: codigo,
      );

      final data = response['data'];
      final usuarioJson = data['usuario'] ?? data['user'];

      if (usuarioJson != null) {
        final usuarioMap = Map<String, dynamic>.from(usuarioJson);
        _usuario = UsuarioModel.fromJson(usuarioMap);
        await _apiClient.tokenService.saveUser(usuarioMap);

        await _sincronizarEnderecos(data['enderecos'], data['endereco']);

        emit(AuthAuthenticated(
          accessToken: _apiClient.tokenService.getAccessToken() ?? '',
          user: _usuario,
        ));
      } else {
        emit(const AuthError('Erro ao confirmar atualização de telefone'));
      }
    } catch (e) {
      emit(const AuthError('Erro ao confirmar atualização de telefone'));
    }
  }

  // ============ SINCRONIZAÇÃO DE ENDEREÇOS ============

  Future<void> _sincronizarEnderecos(dynamic enderecosJson, dynamic enderecoPrincipalJson) async {
    debugPrint('🔁 [AuthCubit] _sincronizarEnderecos chamado');
    debugPrint('🔁 [AuthCubit] Principal: $enderecoPrincipalJson');
    debugPrint('🔁 [AuthCubit] Lista: $enderecosJson');

    // ✅ Se NÃO tem endereço principal, LIMPA localização
    if (enderecoPrincipalJson == null) {
      debugPrint('🗑️ [AuthCubit] Sem endereço principal → limpando localização');
      await _localizacaoCubit.limparLocalizacao();
    }

    debugPrint('🔄 [AuthCubit] Sincronizando endereços...');

    // 1. Sincronizar o endereço principal no LocalizacaoCubit
    if (enderecoPrincipalJson != null) {
      final endereco = EnderecoModel.fromJson(Map<String, dynamic>.from(enderecoPrincipalJson));
      await _localizacaoCubit.definirEnderecoCompleto(endereco, origem: 'auth');
    }

    // 2. Sincronizar a lista completa de endereços no EnderecoCubit
    if (enderecosJson is List && enderecosJson.isNotEmpty) {
      final enderecos = enderecosJson
          .map((json) => EnderecoModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      _enderecoCubit.substituirEnderecos(enderecos);
    } else {
      // ✅ Lista vazia → substitui por lista vazia
      _enderecoCubit.substituirEnderecos([]);
    }
  }

  /// ✅ ATUALIZA OS ENDEREÇOS (usado pelo RefreshInterceptor)
  Future<void> atualizarEnderecos(dynamic enderecosJson, dynamic enderecoPrincipalJson) async {
    developer.log('🔄 [AuthCubit] atualizarEnderecos chamado', name: 'AUTH');
    developer.log('   - enderecos: $enderecosJson', name: 'AUTH');
    developer.log('   - principal: $enderecoPrincipalJson', name: 'AUTH');

    try {
      await _sincronizarEnderecos(enderecosJson, enderecoPrincipalJson);
      developer.log('✅ [AuthCubit] Endereços atualizados com sucesso', name: 'AUTH');
    } catch (e) {
      developer.log('❌ [AuthCubit] Erro ao atualizar endereços: $e', name: 'AUTH');
    }
  }

  // ============ MÉTODOS LEGADOS ============

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());
    try {
      emit(const AuthError('O login por senha foi desativado. Use o telefone.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> cadastrar(Map<String, dynamic> dados) async {
    emit(AuthLoading());
    try {
      emit(const AuthError('O cadastro direto foi desativado. Use o fluxo de telefone.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> socialLogin(String provider) async {
    emit(AuthLoading());
    try {
      emit(const AuthError('Login social temporariamente indisponível.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> completarCadastroConvidado({
    required String nome,
    required String email,
    String? senha,
    String? telefone,
  }) async {
    emit(AuthLoading());
    try {
      emit(const AuthError('Use o fluxo de completar perfil após o OTP.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ============ GESTÃO DE SESSÃO ============

  Future<void> checkAuthStatus() => inicializarApp();

  Future<void> setConvidado(String token, Map<String, dynamic> usuarioJson) async {
    debugPrint('🔐 [AuthCubit] Definindo sessão de Convidado');
    _usuario = UsuarioModel.fromJson(usuarioJson);

    await _apiClient.tokenService.saveTokens(token, null, isGuest: true);
    await _apiClient.tokenService.saveUser(usuarioJson);
    debugPrint('💾 [AuthCubit] setConvidado: usuário salvo: ${_usuario?.nome}');

    final enderecosJson = usuarioJson['enderecos'];
    final enderecoPrincipalJson = usuarioJson['endereco'];
    await _sincronizarEnderecos(enderecosJson, enderecoPrincipalJson);

    emit(AuthGuest(accessToken: token, user: _usuario));
    await carregarEnderecoUsuario();
  }

  Future<void> onEnderecoCriadoComToken(String token, Map<String, dynamic> usuarioJson) async {
    debugPrint('🔐 [AuthCubit] onEnderecoCriadoComToken chamado');
    await setConvidado(token, usuarioJson);
    debugPrint('🔐 [AuthCubit] AuthGuest deve ter sido emitido via setConvidado');
  }

  Future<void> carregarEnderecoUsuario() async {
    try {
      await _enderecoCubit.carregarEnderecos();
      final state = _enderecoCubit.state;

      if (state is EnderecoLoaded && state.enderecoPrincipal != null) {
        await _localizacaoCubit.definirEnderecoCompleto(state.enderecoPrincipal!, origem: 'endereco_padrao');
      }
    } catch (e) {
      debugPrint('⚠️ [AuthCubit] Erro ao carregar endereço: $e');
    }
  }

  Future<void> sairConvidado() async {
    debugPrint('🔐 [AuthCubit] Saindo do modo convidado...');

    // 1. Limpar sessão
    _usuario = null;
    await _apiClient.tokenService.clearTokens();
    await _localizacaoCubit.limparLocalizacao();
    await _deviceService.clearDeviceId();

    // 2. Remover preferências
    await _prefs.remove('guest_token');
    await _prefs.remove('is_guest');
    await _prefs.remove('refresh_token');
    await _prefs.remove('endereco_padrao_id');
    await _prefs.remove('endereco_padrao_json');
    await _prefs.remove('endereco_convidado_id');

    emit(AuthUnauthenticated());

    debugPrint('✅ [AuthCubit] Saída de convidado concluída');
  }

  Future<void> logout() async {
    debugPrint('🚪 [AuthCubit] Iniciando logout...');

    // 1. Invalida token no backend (apenas limpa device_id e device_token)
    try {
      await _apiClient.post('app/auth/logout', requiresAuth: true);
      debugPrint('✅ [AuthCubit] Logout na API realizado com sucesso');
    } catch (e) {
      debugPrint('⚠️ [AuthCubit] Erro no logout da API (ignorado): $e');
    }

    // 2. Limpar dados locais do usuário
    _usuario = null;
    await _apiClient.tokenService.clearTokens();
    await _localizacaoCubit.limparLocalizacao(); // Apenas limpa estado local
    await _deviceService.clearDeviceId();

    // 3. Remover preferências locais
    await _prefs.remove('guest_token');
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
    await _prefs.remove('is_guest');
    await _prefs.remove('endereco_convidado_id');
    await _prefs.remove('endereco_padrao_id');
    await _prefs.remove('endereco_padrao_json');

    // 4. Emitir estado não autenticado
    emit(AuthUnauthenticated());

    debugPrint('✅ [AuthCubit] Logout concluído com sucesso');
  }

  /// ✅ FORÇA LOGOUT (usado pelo RefreshInterceptor)
  Future<void> forceLogout() async {
    developer.log('🔐 [AuthCubit] 🚪 Forçando logout...', name: 'AUTH');

    // ✅ Limpa dados locais
    _usuario = null;
    await _apiClient.tokenService.clearTokens();
    await _localizacaoCubit.limparLocalizacao();
    await _deviceService.clearDeviceId();

    // ✅ Emite estado não autenticado
    emit(AuthUnauthenticated());

    developer.log('✅ [AuthCubit] Logout forçado concluído', name: 'AUTH');
  }

  void restaurarTelefone(String telefone) {
    if (state is! AuthPhoneEnviado) {
      emit(AuthPhoneEnviado(telefone: telefone));
    }
  }
}