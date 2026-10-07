import 'package:flutter/material.dart';
import '../models/turno.dart';

/// Pallino/etichetta colorata per il livello di un corso (Base,
/// Intermedio, Avanzato), pensata per essere riconoscibile a colpo
/// d'occhio nelle liste di turni e sostituzioni.
class LivelloBadge extends StatelessWidget {
  final LivelloCorso livello;

  const LivelloBadge({super.key, required this.livello});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: livello.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        livello.label,
        style: TextStyle(
          color: livello.color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
