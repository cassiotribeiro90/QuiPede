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

        final isCancelado = status.toLowerCase() == 'cancelado';
        final isRecusado = status.toLowerCase() == 'recusado';
        final isEntregue = status.toLowerCase() == 'entregue';

        final isCompleted =
            isEntregue || (!isCancelado && !isRecusado && index < currentStepIndex);
        final isCurrent =
            index == currentStepIndex && !isEntregue && !isCancelado && !isRecusado;
        final isFuture =
            index > currentStepIndex && !isEntregue && !isCancelado && !isRecusado;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _buildCircle(
                    context,
                    step,
                    isCompleted,
                    isCurrent,
                    isFuture,
                    isCancelado: isCancelado,
                    isRecusado: isRecusado,
                    isEntregue: isEntregue,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: _getLineColor(
                          isCompleted: isCompleted,
                          isCancelled: isCancelado || isRecusado,
                          isFuture: isFuture,
                        ),
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
                          color: isFuture
                              ? context.textSecondary
                              : context.textPrimary,
                        ),
                      ),
                      if (step.timestamp != null)
                        Text(
                          _formatTimestamp(step.timestamp!),
                          style: context.bodySmall.copyWith(
                            color: context.textSecondary,
                          ),
                        )
                      else if (isFuture)
                        Text(
                          'Pendente',
                          style: context.bodySmall.copyWith(
                            color: context.textHint,
                          ),
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

  Color _getLineColor({
    required bool isCompleted,
    required bool isCancelled,
    required bool isFuture,
  }) {
    if (isCancelled) {
      return const Color(0xFFEF9A9A); // vermelho suave
    }
    if (isCompleted) {
      return const Color(0xFF81C784); // verde suave
    }
    return const Color(0xFFEEEEEE); // cinza bem claro
  }

  Widget _buildCircle(
      BuildContext context,
      _StepData step,
      bool isCompleted,
      bool isCurrent,
      bool isFuture, {
        bool isCancelado = false,
        bool isRecusado = false,
        bool isEntregue = false,
      }) {
    Color color = const Color(0xFFE0E0E0); // cinza claro base

    if (isEntregue) {
      color = const Color(0xFF81C784); // verde suave
    } else if ((isCancelado || isRecusado) && step.key == 'cancelado') {
      color = const Color(0xFFEF9A9A); // vermelho suave
    } else if (isCompleted) {
      color = const Color(0xFF81C784); // verde suave
    } else if (isCurrent) {
      color = context.primaryColor.withValues(alpha: 0.9);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: isCurrent
            ? [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: Icon(step.icon, size: 18, color: Colors.white),
    );
  }

  int _getCurrentStepIndex(List<_StepData> steps) {
    final s = status.toLowerCase();

    if (s == 'cancelado' || s == 'recusado') {
      return steps.length - 1;
    }

    switch (s) {
      case 'novo':
      case 'aguardando':
      case 'pendente':
        return 0;
      case 'confirmado':
        return 1;
      case 'preparando':
      case 'em_preparo':
        return 2;
      case 'pronto':
        return 3;
      case 'saiu':
      case 'saiu_entrega':
        return 4;
      case 'entregue':
        return 5;
      default:
        return 0;
    }
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
        key: 'pronto',
        title: 'Pedido Pronto',
        icon: Icons.room_service,
        timestamp: timestamps['pronto_at'],
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

    final s = status.toLowerCase();
    if (s == 'cancelado' || s == 'recusado') {
      steps.add(
        _StepData(
          key: 'cancelado',
          title: s == 'recusado' ? 'Pedido Recusado' : 'Pedido Cancelado',
          icon: Icons.cancel,
          timestamp: timestamps['cancelado_at'] ?? timestamps['recusado_at'],
        ),
      );
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