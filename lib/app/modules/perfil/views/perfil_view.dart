import 'package:flutter/material.dart';


class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Meus Endereços'),
            // onTap: () => Navigator.pushNamed(context, Routes.ENDERECOS),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Meus Pedidos'),
            // onTap: () => Navigator.pushNamed(context, Routes.PEDIDOS),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              // TODO: Implementar logout
            },
          ),
        ],
      ),
    );
  }
}
