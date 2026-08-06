import 'package:flutter/material.dart';
import '../../../models/loja_resumo_model.dart';
import '../../../di/dependencies.dart';
import '../../../services/navigation_service.dart';

class LojaItemWidget extends StatelessWidget {
  final LojaResumo loja;

  const LojaItemWidget({super.key, required this.loja});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: () => getIt<NavigationService>().goToLojaHome(loja.id),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(loja.logo ?? ''),
        ),
        title: Text(loja.nome),
        subtitle: Text(loja.categoria),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            Text(loja.notaMedia.toString()),
          ],
        ),
      ),
    );
  }
}
