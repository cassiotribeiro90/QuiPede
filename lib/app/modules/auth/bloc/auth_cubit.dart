// lib/app/modules/auth/bloc/auth_cubit.dart

import 'dart:async';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/api/api_client.dart';
import '../../../di/dependencies.dart';
import '../../../navigation/navigation_cubit.dart';
import '../../../services/push_service.dart';
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
      final token = _apiClient.tokenService.getAccessToken();
      final isGuest = _apiClient.tokenService.isGuest();
      developer.log('🔐 [AuthCubit] Token: ${token != null ? "SIM" : "NÃO"}, isGuest: $isGuest', name: 'AUTH');

      if (token == null || token.isEmpty) {
        developer.log('🚫 [AuthCubit] Nenhum token encontrado', name: 'AUTH');
        emit(AuthUnauthenticated());
        _isProcessing = false;
        return;
      }

      // ✅ LIMPA LOCALIZAÇÃO NO ARRANQUE (força recarregar endereço do usuário)
      await _localizacaoCubit.limparLocalizacao();

      try {
        developer.log('📡 [AuthCubit] Buscando usuário /me...', name: 'AUTH');
        final response = await _apiClient.get('app/auth/me', requiresAuth: true);

        if (response.statusCode == 200 && response.data['success'] == true) {
          final data = response.data['data'];
          final authResponse = AuthResponse.fromJson(data);
          _usuario = authResponse.user;

          if (_usuario != null) {
            await _apiClient.tokenService.saveUser(_usuario!.toJson());
          }

          await _sincronizarEnderecos(data['enderecos'], data['endereco']);

          if (isGuest) {
            emit(AuthGuest(accessToken: token, user: _usuario));
          } else {
            emit(AuthAuthenticated(accessToken: token, user: _usuario));
          }
          
          _onAuthenticated();

          developer.log('✅ [AuthCubit] Autenticado via API', name: 'AUTH');
          await carregarEnderecoUsuario();
          _isProcessing = false;
          return;
        }
      } catch (e) {
        developer.log('⚠️ [AuthCubit] Erro na API /me: $e', name: 'AUTH');
        
        // ✅ TENTA REFRESH SE FOR 401
        bool isUnauthorized = false;
        if (e is DioException) {
          isUnauthorized = e.response?.statusCode == 401;
        } else {
          isUnauthorized = e.toString().contains('401');
        }

        if (isUnauthorized) {
          developer.log('🔄 [AuthCubit] Token expirado, tentando refresh...', name: 'AUTH');
          
          final success = await _refreshToken();
          if (success) {
            try {
              final response = await _apiClient.get('app/auth/me', requiresAuth: true);
              if (response.statusCode == 200 && response.data['success'] == true) {
                final data = response.data['data'];
                final authResponse = AuthResponse.fromJson(data);
                _usuario = authResponse.user;
                if (_usuario != null) await _apiClient.tokenService.saveUser(_usuario!.toJson());
                await _sincronizarEnderecos(data['enderecos'], data['endereco']);
                
                final newToken = _apiClient.tokenService.getAccessToken() ?? '';
                emit(AuthAuthenticated(accessToken: newToken, user: _usuario));
                _onAuthenticated();
                await carregarEnderecoUsuario();
                _isProcessing = false;
                return;
              }
            } catch (e2) {
              developer.log('❌ [AuthCubit] Erro ao buscar /me após refresh: $e2', name: 'AUTH');
            }
          }
          
          developer.log('🚫 [AuthCubit] Falha no refresh ou token ainda inválido → Logout', name: 'AUTH');
          await logout();
          _isProcessing = false;
          return;
        }
      }

      // ✅ FALLBACK: Cache local (se a API falhar mas não for 401)
      developer.log('📦 [AuthCubit] Usando cache local...', name: 'AUTH');
      final userJson = _apiClient.tokenService.getUser();
      if (userJson != null) {
        _usuario = UsuarioModel.fromJson(userJson);
      }

      if (isGuest) {
        emit(AuthGuest(accessToken: token, user: _usuario));
      } else {
        emit(AuthAuthenticated(accessToken: token, user: _usuario));
      }
      
      _onAuthenticated();
      await carregarEnderecoUsuario();

    } catch (e) {
      developer.log('❌ [AuthCubit] ERRO CRÍTICO NA INICIALIZAÇÃO: $e', name: 'AUTH');
      emit(AuthUnauthenticated());
    } finally {
      _isProcessing = false;
    }
  }

  /// ✅ MÉTODO PRIVADO PARA REFRESH TOKEN (usado na inicialização)
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _apiClient.tokenService.getRefreshToken();
      if (refreshToken == null) {
        developer.log('🔐 [AuthCubit] ❌ Refresh token não encontrado', name: 'AUTH');
        return false;
      }

      developer.log('🔐 [AuthCubit] 🔄 Tentando refresh silencioso...', name: 'AUTH');

      final response = await _apiClient.post(
        'app/auth/refresh-token',
        data: {'refresh_token': refreshToken},
        requiresAuth: false,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];
        
        await _apiClient.tokenService.saveTokens(newAccessToken, newRefreshToken, isGuest: false);
        developer.log('✅ [AuthCubit] Refresh token bem-sucedido', name: 'AUTH');
        return true;
      }
      
      developer.log('❌ [AuthCubit] Refresh token falhou', name: 'AUTH');
      return false;
      
    } catch (e) {
      developer.log('❌ [AuthCubit] Erro no refresh: $e', name: 'AUTH');
      return false;
    }
  }

  void _onAuthenticated() {
    // Inicializa PushService e solicita permissões
    PushService().init().then((_) {
      if (_usuario != null) {
        PushService().requestPermissionAndGetToken();
      }
    });
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
      debugPrint('[AUTH_CUBIT] 📱 Obtendo Token para notificações...');
      
      // ✅ Usa o PushService para gerenciar a permissão e obter o token
      await PushService().requestPermissionAndGetToken();
      
      String? fcmToken = PushService().token;

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

        debugPrint('🔐 [AuthCubit] Estado emitido via onOtpVerified');
        onOtpVerified(_usuario!);

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

        // ✅ SEMPRE chama onPerfilCompleto
        onPerfilCompleto(_usuario!);
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
        
        _onAuthenticated();
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

  Future<void> setConvidado(UsuarioModel usuario, {EnderecoModel? enderecoPrincipal}) async {
    debugPrint('🔐 [AuthCubit] setConvidado chamado para: ${usuario.nome}');
    _usuario = usuario;

    // 🔥 SALVA USUÁRIO NO CACHE
    await _apiClient.tokenService.saveUser(usuario.toJson());
    debugPrint('💾 [AuthCubit] setConvidado: usuário salvo: ${_usuario?.nome}');

    // 🔥 SE TEM ENDEREÇO, DEFINE COMO PRINCIPAL ANTES DE EMITIR ESTADO
    if (enderecoPrincipal != null) {
      debugPrint('📍 [AuthCubit] setConvidado: definindo endereço principal: ${enderecoPrincipal.logradouro}');
      await _localizacaoCubit.definirEnderecoCompleto(enderecoPrincipal, origem: 'auth_guest');
    }

    final token = _apiClient.tokenService.getAccessToken();
    emit(AuthGuest(accessToken: token ?? '', user: _usuario));
    _onAuthenticated();
    
    // Se não tinha endereço passado mas o JSON tem, sincroniza (caso de recarregamento)
    if (enderecoPrincipal == null) {
       // O setConvidado original fazia isso, mas agora priorizamos o passado por parâmetro
       // para garantir sincronia imediata na criação.
    }
  }

  Future<void> onEnderecoCriadoComToken(String token, Map<String, dynamic> usuarioJson, {EnderecoModel? endereco}) async {
    debugPrint('🔐 [AuthCubit] onEnderecoCriadoComToken chamado');
    // Salva o token primeiro para que as chamadas subsequentes funcionem
    await _apiClient.tokenService.saveTokens(token, null, isGuest: true);
    await setConvidado(UsuarioModel.fromJson(usuarioJson), enderecoPrincipal: endereco);
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

  /// 🔥 Método chamado após OTP verificado com sucesso (Roadmap)
  void onOtpVerified(UsuarioModel usuario) {
    debugPrint('✅ [AuthCubit] OTP verificado para: ${usuario.nome}');
    _usuario = usuario;
    emit(AuthAuthenticated(accessToken: _apiClient.tokenService.getAccessToken() ?? '', user: _usuario));
  }

  /// 🔥 Método chamado após completar perfil com sucesso (Roadmap)
  void onPerfilCompleto(UsuarioModel usuario) {
    debugPrint('✅ [AuthCubit] Perfil completado para: ${usuario.nome}');
    _usuario = usuario;
    emit(AuthAuthenticated(accessToken: _apiClient.tokenService.getAccessToken() ?? '', user: _usuario));
  }

  /// 🔥 Verifica autenticação para o fluxo do carrinho (Roadmap)
  Future<void> verificarAutenticacaoParaCarrinho() async {
    final navigationCubit = getIt<NavigationCubit>();
    navigationCubit.navigateToCart();
  }
}
