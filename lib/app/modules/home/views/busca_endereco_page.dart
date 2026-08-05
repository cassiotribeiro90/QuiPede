import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quipede/shared/api/api_client.dart';
import 'package:quipede/app/di/dependencies.dart';
import 'package:quipede/app/core/theme/app_text_styles.dart'; // 🔥 ADICIONADO
import '../models/endereco_sugestao.dart';
import '../services/localizacao_service.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import 'endereco_confirmacao_page.dart';
import 'widgets/endereco_sugestao_tile.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../core/theme/input_styles.dart';

class BuscaEnderecoPage extends StatelessWidget {
  final double? initialLat;
  final double? initialLng;

  const BuscaEnderecoPage({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<EnderecoCubit>(),
      child: _BuscaEnderecoBody(
        initialLat: initialLat,
        initialLng: initialLng,
      ),
    );
  }
}

class _BuscaEnderecoBody extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const _BuscaEnderecoBody({
    this.initialLat,
    this.initialLng,
  });

  @override
  State<_BuscaEnderecoBody> createState() => _BuscaEnderecoBodyState();
}

class _BuscaEnderecoBodyState extends State<_BuscaEnderecoBody> {
  final _searchController = TextEditingController();
  final _localizacaoService = LocalizacaoService(getIt<ApiClient>());

  List<EnderecoSugestao> _sugestoes = [];
  bool _isLoading = false;
  bool _isLocating = false;
  bool _gpsAtivo = false;
  double? _userLat;
  double? _userLng;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _userLat = widget.initialLat;
    _userLng = widget.initialLng;
    _gpsAtivo = _userLat != null;
    _solicitarLocalizacaoOpcional();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _solicitarLocalizacaoOpcional() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      await _obterCoordenadas(silencioso: true);
    }
  }

  Future<void> _obterCoordenadas({bool silencioso = false}) async {
    if (mounted && !silencioso) setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _gpsAtivo = false);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
      if (mounted) {
        setState(() {
          _userLat = position.latitude;
          _userLng = position.longitude;
          _gpsAtivo = true;
        });
        if (_searchController.text.trim().length >= 3) {
          _buscar(_searchController.text);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _gpsAtivo = false);
    } finally {
      if (mounted) setState(() => _isLocating = false);
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Endereço adicionado com sucesso!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      },
      child: ResponsivePageScaffold(
        appBar: AppBar(
          title: const Text('Buscar Endereço'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 🔥 Título "Buscar Endereço"
              Text(
                'Buscar Endereço',
                style: AppTextStyles.titleMedium.copyWith( // 24px
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 🔥 Subtítulo
              Text(
                'Digite rua, bairro ou cidade para encontrar o local.',
                style: AppTextStyles.bodyMedium.copyWith( // 18px
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputStyles.decoration(
                  label: 'Endereço',
                  hint: 'Ex: Avenida Paulista, São Paulo',
                  prefixIcon: Icons.search,
                  suffixIcon: _buildGpsSuffix(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGpsSuffix() {
    if (_isLocating) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return IconButton(
      icon: Icon(Icons.gps_fixed, color: _gpsAtivo ? Colors.green : Colors.grey),
      onPressed: () => _obterCoordenadas(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_searchController.text.trim().length < 3) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            // 🔥 Texto "Digite pelo menos 3 caracteres..."
            Text(
              'Digite pelo menos 3 caracteres para buscar',
              style: AppTextStyles.bodyLarge, // 20px
            ),
          ],
        ),
      );
    }
    if (_sugestoes.isEmpty) {
      return Center(
        child: Text(
          'Nenhum endereço encontrado',
          style: AppTextStyles.bodyLarge, // 20px
        ),
      );
    }
    return ListView.builder(
      itemCount: _sugestoes.length,
      itemBuilder: (context, index) {
        final item = _sugestoes[index];
        return EnderecoSugestaoTile(
          endereco: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EnderecoConfirmacaoPage(
                  endereco: item.toMap(),
                  latitude: item.latitude ?? 0.0,
                  longitude: item.longitude ?? 0.0,
                ),
              ),
            ).then((result) {
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            });
          },
        );
      },
    );
  }
}