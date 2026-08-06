import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:quipede/app/services/navigation_service.dart';
import '../../../routes/app_routes.dart';
import 'widgets/endereco_sugestao_tile.dart';

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
  bool _gpsAtivo = false;

  @override
  void initState() {
    super.initState();
    _checkGps();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkGps() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      _obterCoordenadas(silencioso: true);
    }
  }

  Future<void> _obterCoordenadas({bool silencioso = false}) async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLat = position.latitude;
          _userLng = position.longitude;
          _gpsAtivo = true;
        });
      }
    } catch (e) {
      if (!silencioso) {
        debugPrint('Erro ao obter coordenadas: $e');
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
          getIt<NavigationService>().goToHomeAndRemoveAll();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buscar endereço'),
          actions: [
            _buildGpsIcon(),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
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
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsIcon() {
    if (!_gpsAtivo) {
      return IconButton(
        icon: const Icon(Icons.gps_not_fixed),
        onPressed: () => _obterCoordenadas(),
      );
    }
    return IconButton(
      icon: const Icon(Icons.gps_fixed, color: Colors.green),
      onPressed: () => _obterCoordenadas(),
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
      itemCount: _sugestoes.length,
      itemBuilder: (context, index) {
        final item = _sugestoes[index];
        final authCubit = context.read<AuthCubit>();
        
        return EnderecoSugestaoTile(
          endereco: item,
          onTap: () {
            final isLogged = authCubit.state is AuthAuthenticated;
            if (isLogged) {
              context.read<EnderecoCubit>().criarEndereco(_toEnderecoModel(item));
            } else {
              getIt<NavigationService>().pushNamed(
                Routes.enderecoConfirmacao,
                arguments: {
                  'endereco': item.toMap(),
                  'latitude': item.latitude ?? 0,
                  'longitude': item.longitude ?? 0,
                },
              );
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
