import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quipede/app/modules/auth/bloc/auth_cubit.dart';
import 'package:quipede/app/modules/auth/bloc/auth_state.dart';
import 'package:quipede/app/modules/enderecos/bloc/endereco_cubit.dart';
import 'package:quipede/app/modules/enderecos/bloc/endereco_state.dart';
import 'package:quipede/app/modules/enderecos/models/endereco_model.dart';
import 'package:quipede/app/modules/home/models/endereco_sugestao.dart';
import 'package:quipede/app/modules/home/services/localizacao_service.dart';
import 'package:quipede/shared/api/api_client.dart';
import 'package:quipede/app/di/dependencies.dart';
import 'package:quipede/app/core/theme/app_text_styles.dart';
import 'package:quipede/app/core/utils/location_permission_service.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import 'widgets/endereco_sugestao_tile.dart';
import 'endereco_confirmacao_page.dart';

class BuscaEnderecoPage extends StatefulWidget {
  const BuscaEnderecoPage({super.key});

  @override
  State<BuscaEnderecoPage> createState() => _BuscaEnderecoPageState();
}

class _BuscaEnderecoPageState extends State<BuscaEnderecoPage> {
  final _searchController = TextEditingController();
  final _localizacaoService = LocalizacaoService(getIt<ApiClient>());
  List<EnderecoSugestao> _sugestoes = [];
  bool _isLoading = false;
  Timer? _debounce;
  double? _userLat;
  double? _userLng;
  bool _bloquearBusca = false;

  @override
  void initState() {
    super.initState();
    _verificarLocalizacao();
  }

  Future<void> _verificarLocalizacao() async {
    final temPermissao = await LocationPermissionService.hasPermission();
    if (!temPermissao) {
      final concedida = await LocationPermissionService.requestPermission();
      if (!concedida) {
        if (mounted) {
          setState(() {
            _bloquearBusca = true;
          });
          _mostrarDialogoPermissao();
        }
      } else {
        await _obterCoordenadas(silencioso: true);
        if (mounted) {
          setState(() => _bloquearBusca = false);
        }
      }
    } else {
      await _obterCoordenadas(silencioso: true);
    }
  }

  void _mostrarDialogoPermissao() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Precisamos da sua localização'),
        content: const Text(
          'Para buscar endereços próximos e garantir a entrega, permita o acesso à sua localização.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await LocationPermissionService.goToSettings();
            },
            child: const Text('Configurações'),
          ),
        ],
      ),
    );
  }

  Future<void> _obterCoordenadas({bool silencioso = false}) async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLat = position.latitude;
          _userLng = position.longitude;
          _bloquearBusca = false;
        });
      }
    } catch (e) {
      if (!silencioso) {
        debugPrint('Erro ao obter coordenadas: $e');
        if (mounted) {
          setState(() => _bloquearBusca = true);
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().length >= 3) {
        _buscar(query);
      } else {
        setState(() => _sugestoes = []);
      }
    });
  }

  Future<void> _buscar(String query) async {
    if (_bloquearBusca) {
      _mostrarDialogoPermissao();
      return;
    }
    debugPrint('🚨 [BuscaEnderecoPage] Buscando: $query');
    debugPrint('🔍 [BuscaEndereco] Buscando: $query');
    setState(() => _isLoading = true);
    try {
      final resultados = await _localizacaoService.buscarEndereco(
        query: query,
        latitude: _userLat,
        longitude: _userLng,
      );
      if (mounted) setState(() => _sugestoes = resultados);
    } catch (e) {
      debugPrint('Erro na busca: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnderecoCubit, EnderecoState>(
      listener: (context, state) {
        if (state is EnderecoCriado) {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context, true);
          }
        }
      },
      child: ResponsivePageScaffold(
        appBar: AppBar(
          title: const Text('Buscar endereço'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.white,
        body: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Digite rua, bairro ou cidade',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _sugestoes = []);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_searchController.text.trim().length < 3) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Color(0xFFE0E0E0)),
            SizedBox(height: 16),
            Text(
              'Digite pelo menos 3 caracteres para buscar',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      );
    }
    if (_sugestoes.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum endereço encontrado',
          style: AppTextStyles.bodyLarge,
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sugestoes.length,
      itemBuilder: (context, index) {
        final item = _sugestoes[index];
        final authCubit = context.read<AuthCubit>();

        return EnderecoSugestaoTile(
          endereco: item,
          onTap: () async {
            final isLogged = authCubit.state is AuthAuthenticated;
            if (isLogged) {
              context.read<EnderecoCubit>().criarEndereco(_toEnderecoModel(item));
            } else {
              final navigator = Navigator.of(context);
              final result = await navigator.push<bool>(
                MaterialPageRoute(
                  builder: (_) => EnderecoConfirmacaoPage(
                    endereco: item.toMap(),
                    latitude: item.latitude ?? 0,
                    longitude: item.longitude ?? 0,
                  ),
                ),
              );

              if (result == true && mounted) {
                if (navigator.canPop()) {
                  navigator.pop(true);
                }
              }
            }
          },
        );
      },
    );
  }

  EnderecoModel _toEnderecoModel(EnderecoSugestao item) {
    return EnderecoModel(
      cep: item.cep ?? '',
      logradouro: item.logradouro,
      numero: item.numero,
      bairro: item.bairro ?? '',
      cidade: item.cidade ?? '',
      uf: item.uf ?? '',
      latitude: item.latitude,
      longitude: item.longitude,
    );
  }
}
