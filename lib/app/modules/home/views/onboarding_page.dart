import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quipede/shared/api/api_client.dart';
import 'package:quipede/app/di/dependencies.dart';
import 'package:quipede/app/routes/app_routes.dart';
import 'package:quipede/app/core/utils/platform_utils.dart';
import '../services/localizacao_service.dart';
import 'busca_endereco_page.dart';
import 'cep_input_page.dart';
import 'localizacao_confirmacao_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _localizacaoService = LocalizacaoService(getIt<ApiClient>());
  bool _isLoading = false;

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  Future<void> _usarLocalizacaoAtual() async {
    if (!PlatformUtils.isMobile) return;

    _setLoading(true);
    try {
      final status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        final position = await Geolocator.getCurrentPosition();
        final response = await _localizacaoService.geocodificar(
          position.latitude,
          position.longitude,
        );

        if (response['success'] == true && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LocalizacaoConfirmacaoPage(
                endereco: response['data'],
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            ),
          );
        } else {
          _showError(response['message'] ?? 'Não foi possível identificar seu endereço.');
        }
      } else {
        _showError('Permissão de localização negada.');
      }
    } catch (e) {
      _showError('Erro ao obter localização.');
    } finally {
      _setLoading(false);
    }
  }

  void _irParaBuscaEndereco() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BuscaEnderecoPage(),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const Center(
                    child: Icon(Icons.storefront, size: 80, color: Color(0xFFF57C00)),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'QuiPede',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFF57C00)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Vamos encontrar lojas perto de você',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  _OptionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Informar CEP',
                    subtitle: 'Rápido e preciso',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CepInputPage()),
                    ),
                  ),
                  
                  if (PlatformUtils.isMobile)
                    _OptionCard(
                      icon: Icons.my_location,
                      title: 'Usar localização atual',
                      subtitle: 'Encontre lojas próximas',
                      onTap: _usarLocalizacaoAtual,
                    ),

                  _OptionCard(
                    icon: Icons.search,
                    title: 'Buscar endereço',
                    subtitle: 'Digite rua, bairro ou cidade',
                    onTap: _irParaBuscaEndereco,
                  ),
                  _OptionCard(
                    icon: Icons.person_outline,
                    title: 'Já tenho uma conta',
                    subtitle: 'Entrar com email ou redes sociais',
                    onTap: () => Navigator.pushNamed(context, Routes.login),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: const Color(0xFFF57C00), size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
