import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../shared/api/api_client.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
import '../models/auth_response_model.dart';
import '../models/usuario_model.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import '../../enderecos/models/endereco_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/device_service.dart';
import '../../../core/services/fcm_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;
  final LocalizacaoCubit _localizacaoCubit;
  final AuthService _authService;
  final EnderecoCubit _enderecoCubit;
  final SharedPreferences _prefs;
  final DeviceService _deviceService = DeviceService();
  final FcmService _fcmService = FcmService();
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

    debugPrint('🔐 [AuthCubit] 🔥 INICIALIZANDO APP...');
    emit(AuthLoading());

    try {
      // ✅ LIMPAR localização anterior ANTES de processar
      await _localizacaoCubit.limparLocalizacao();

      final token = _apiClient.tokenService.getAccessToken();
      final isGuest = _apiClient.tokenService.isGuest();

      if (token != null && token.isNotEmpty) {
        try {
          final response = await _apiClient.get('app/auth/me', requiresAuth: true);
          if (response.statusCode == 200 && response.data['success'] == true) {
            final data = response.data['data'];
            
            debugPrint('🔍 [AuthCubit] inicializarApp - Dados recebidos:');
            debugPrint('🔍 [AuthCubit] usuario: ${data['usuario'] ?? data['user']}');
            debugPrint('🔍 [AuthCubit] endereco: ${data['endereco']}');
            debugPrint('🔍 [AuthCubit] enderecos: ${data['enderecos']}');

            final authResponse = AuthResponse.fromJson(data);
            _usuario = authResponse.user;

            debugPrint('🔐 [AuthCubit] inicializarApp: _usuario definido: nome=${_usuario?.nome}, email=${_usuario?.email}, status=${_usuario?.status}, telefone=${_usuario?.telefone}');

            // ✅ Sincroniza cache local
            if (_usuario != null) {
              await _apiClient.tokenService.saveUser(_usuario!.toJson());
              debugPrint('💾 [AuthCubit] inicializarApp: usuário salvo: ${_usuario?.nome}');
            }

            final enderecosJson = data['enderecos'];
            final enderecoPrincipalJson = data['endereco'];
            await _sincronizarEnderecos(enderecosJson, enderecoPrincipalJson);

            if (isGuest) {
              emit(AuthGuest(accessToken: token, user: _usuario));
            } else {
              emit(AuthAuthenticated(accessToken: token, user: _usuario));
            }

            await carregarEnderecoUsuario();
            _isProcessing = false;
            return;
          }
        } catch (e) {
          debugPrint('❌ [AuthCubit] Erro ao buscar /me, usando cache local: $e');
        }

        // ✅ Fallback para cache local
        final userJson = _apiClient.tokenService.getUser();
        if (userJson != null) {
          _usuario = UsuarioModel.fromJson(userJson);
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

      emit(AuthUnauthenticated());
    } catch (e) {
      debugPrint('❌ [AuthCubit] ERRO NA INICIALIZAÇÃO: $e');
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
    debugPrint('🧭 [AuthCubit] enviarTelefone: $telefone');
    emit(AuthLoading()); // ✅ Garante mudança de estado para resetar listeners
    try {
      await _authService.enviarTelefone(telefone);
      debugPrint('🧭 [AuthCubit] Sucesso ao enviar telefone. Emitindo AuthPhoneEnviado.');
      emit(AuthPhoneEnviado(telefone: telefone));
    } catch (e) {
      debugPrint('🧭 [AuthCubit] Erro ao enviar telefone: $e');
      emit(const AuthOtpErro('Erro ao enviar código. Tente novamente.'));
    }
  }

  Future<void> verificarOTP(String telefone, String codigo, {bool redirectToCheckout = false}) async {
    debugPrint('[AUTH_CUBIT] 🔍 verificarOTP chamado');
    debugPrint('[AUTH_CUBIT] 📞 Phone: $telefone');
    debugPrint('[AUTH_CUBIT] 🔢 Code: $codigo');
    emit(AuthOtpVerificando(telefone: telefone));
    try {
      debugPrint('[AUTH_CUBIT] 📱 Obtendo FCM token...');
      String? fcmToken;
      if (!Platform.isWindows) {
        try {
          fcmToken = await FirebaseMessaging.instance.getToken();
          debugPrint('[AUTH_CUBIT] 📱 FCM Token obtido: $fcmToken');
        } catch (fcmError) {
          debugPrint('[AUTH_CUBIT] ⚠️ Erro ao obter FCM Token (prosseguindo sem ele): $fcmError');
        }
      } else {
        debugPrint('[AUTH_CUBIT] ⏳ Windows detectado: ignorando FCM Token');
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
      final userJson = data['usuario'] ?? data['user'];
      final enderecoJson = data['endereco'];

      if (userJson != null) {
        final usuarioMap = Map<String, dynamic>.from(userJson);
        
        // ✅ Salva tokens IMEDIATAMENTE
        await _apiClient.tokenService.saveTokens(accessToken, null, isGuest: false);
        debugPrint('🔑 [AuthCubit] Access token salvo após OTP: ${accessToken.substring(0, 10)}...');

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
        emit(const AuthOtpErro('Usuário não encontrado após verificação.'));
      }
    } catch (e) {
      debugPrint('[AUTH_CUBIT] ❌ Erro no verificarOTP: $e');
      emit(const AuthOtpErro('Código inválido. Tente novamente.'));
    }
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ApiClient.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.onboarding,
        (route) => false,
      );
    });

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

    // 5. Navegar para onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ApiClient.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.onboarding,
        (route) => false,
      );
    });

    debugPrint('✅ [AuthCubit] Logout concluído com sucesso');
  }
}