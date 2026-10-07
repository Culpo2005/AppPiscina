import 'package:flutter/material.dart';
import '../models/sostituzione.dart';

/// Etichetta colorata per lo stato di una sostituzione (Confermata,
/// In attesa, Rifiutata).
class StatoBadge extends StatelessWidget {
  final StatoSostituzione stato;

  const StatoBadge({super.key, required this.stato});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: stato.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        stato.label,
        style: TextStyle(
          color: stato.color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
