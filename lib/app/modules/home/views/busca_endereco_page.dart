import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quipede/shared/api/api_client.dart';
import 'package:quipede/app/di/dependencies.dart';
import '../models/endereco_sugestao.dart';
import '../services/localizacao_service.dart';
import 'endereco_confirmacao_page.dart';
import 'widgets/endereco_sugestao_tile.dart';

class BuscaEnderecoPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const BuscaEnderecoPage({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<BuscaEnderecoPage> createState() => _BuscaEnderecoPageState();
}

class _BuscaEnderecoPageState extends State<BuscaEnderecoPage> {
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
    
    // Tenta obter localização em segundo plano sem bloquear a UI
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

  Future<void> _ativarGpsManualmente() async {
    if (mounted) setState(() => _isLocating = true);
    
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      await _obterCoordenadas();
    } else {
      if (mounted) {
        setState(() {
          _gpsAtivo = false;
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _reativarGps() async {
    await _obterCoordenadas();
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
        
        // Se já há texto digitado, refaz a busca com as novas coordenadas
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
      if (mounted) {
        setState(() => _sugestoes = resultados);
      }
    } catch (e) {
      debugPrint('Erro na busca: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildGpsSuffix() {
    if (_isLocating) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    
    if (_gpsAtivo) {
      return IconButton(
        icon: const Icon(Icons.gps_fixed, color: Colors.green),
        onPressed: _reativarGps,
        tooltip: 'Localização ativa - toque para atualizar',
      );
    }
    
    return IconButton(
      icon: const Icon(Icons.gps_off, color: Colors.grey),
      onPressed: _ativarGpsManualmente,
      tooltip: 'Ativar localização para melhores resultados',
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_searchController.text.trim().length < 3) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Digite pelo menos 3 caracteres para buscar'),
          ],
        ),
      );
    }
    
    if (_sugestoes.isEmpty) {
      return const Center(
        child: Text('Nenhum endereço encontrado'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Endereço')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Digite rua, bairro ou cidade',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buildGpsSuffix(),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}
