import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';

class PedidoStatusTimeline extends StatelessWidget {
  final String status;
  final Map<String, DateTime?> timestamps;

  const PedidoStatusTimeline({
    super.key,
    required this.status,
    required this.timestamps,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _getSteps();
    final currentStepIndex = _getCurrentStepIndex(steps);

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        
        // Lógica de conclusão baseada no índice e no status entregue
        final bool isEntregue = status.toLowerCase() == 'entregue';
        final bool isCancelado = status.toLowerCase() == 'cancelado';
        
        final bool isCompleted = isEntregue || (index < currentStepIndex && !isCancelado);
        final bool isCurrent = index == currentStepIndex && !isEntregue && !isCancelado;
        final bool isFuture = index > currentStepIndex && !isEntregue && !isCancelado;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _buildCircle(context, step, isCompleted, isCurrent, isFuture),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isCompleted ? Colors.green : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: context.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isFuture ? context.textSecondary : context.textPrimary,
                        ),
                      ),
                      if (step.timestamp != null)
                        Text(
                          _formatTimestamp(step.timestamp!),
                          style: context.bodySmall.copyWith(color: context.textSecondary),
                        )
                      else if (isFuture)
                        Text(
                          'Pendente',
                          style: context.bodySmall.copyWith(color: context.textHint),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCircle(BuildContext context, _StepData step, bool isCompleted, bool isCurrent, bool isFuture) {
    Color color = Colors.grey.shade300;
    IconData icon = step.icon;
    
    if (isCompleted) {
      color = Colors.green;
    } else if (isCurrent) {
      color = context.primaryColor;
    }

    if (status.toLowerCase() == 'cancelado' && step.key == 'cancelado') {
        color = Colors.red;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: isCurrent ? [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ] : null,
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }

  int _getCurrentStepIndex(List<_StepData> steps) {
    final s = status.toLowerCase();
    if (s == 'cancelado') return steps.length - 1;
    
    final statusMap = {
      'novo': 0,
      'pendente': 0,
      'confirmado': 1,
      'em_preparo': 2,
      'saiu_entrega': 3,
      'entregue': 4,
    };
    
    return statusMap[s] ?? 0;
  }

  List<_StepData> _getSteps() {
    final List<_StepData> steps = [
      _StepData(
        key: 'pendente',
        title: 'Pedido Realizado',
        icon: Icons.assignment_outlined,
        timestamp: timestamps['criado_at'],
      ),
      _StepData(
        key: 'confirmado',
        title: 'Pedido Confirmado',
        icon: Icons.check_circle_outline,
        timestamp: timestamps['confirmado_at'],
      ),
      _StepData(
        key: 'em_preparo',
        title: 'Em Preparo',
        icon: Icons.restaurant,
        timestamp: timestamps['em_preparo_at'],
      ),
      _StepData(
        key: 'saiu_entrega',
        title: 'Saiu para Entrega',
        icon: Icons.delivery_dining,
        timestamp: timestamps['saiu_entrega_at'],
      ),
      _StepData(
        key: 'entregue',
        title: 'Pedido Entregue',
        icon: Icons.verified,
        timestamp: timestamps['entregue_at'],
      ),
    ];

    if (status.toLowerCase() == 'cancelado') {
      steps.add(_StepData(
        key: 'cancelado',
        title: 'Cancelado',
        icon: Icons.cancel,
        timestamp: timestamps['cancelado_at'],
      ));
    }

    return steps;
  }

  String _formatTimestamp(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m $h:$min';
  }
}

class _StepData {
  final String key;
  final String title;
  final IconData icon;
  final DateTime? timestamp;

  _StepData({
    required this.key,
    required this.title,
    required this.icon,
    this.timestamp,
  });
}
