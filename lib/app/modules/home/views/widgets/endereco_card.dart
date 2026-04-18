import 'package:flutter/material.dart';

class EnderecoCard extends StatelessWidget {
  final String logradouro;
  final String bairro;
  final String cidade;
  final String uf;
  final String cep;

  const EnderecoCard({
    super.key,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.cep,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    logradouro,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('$bairro, $cidade - $uf'),
            Text('CEP: $cep', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
