import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import 'configuration_screen.dart';
import 'history_screen.dart';

/// Écran d'accueil : présentation + accès rapides.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ciini Kaarey'),
            Text('خواتم — Carrés magiques soufis',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Thème',
            icon: const Icon(Icons.brightness_6),
            onPressed: () => context.read<SettingsProvider>().cycleTheme(),
          ),
          IconButton(
            tooltip: 'Historique',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: theme.colorScheme.primary.withOpacity(0.08),
            child: Column(
              children: [
                Icon(Icons.grid_4x4,
                    size: 48, color: theme.colorScheme.secondary),
                const SizedBox(height: 12),
                Text('Générateur de Khatim',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Choisissez une dimension, une méthode et un Poids Mystique '
                  '(nombre ou texte arabe) pour créer votre carré magique.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(
                  context,
                  icon: Icons.add_circle_outline,
                  title: 'Nouveau Khatim',
                  subtitle: 'Configurer et générer un carré magique',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ConfigurationScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  context,
                  icon: Icons.history,
                  title: 'Historique',
                  subtitle: 'Consulter vos Khatim précédents',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  context,
                  icon: Icons.menu_book,
                  title: 'À propos des Khatim',
                  subtitle: 'Comprendre les principes et l\'usage',
                  onTap: () => _showGuide(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
          child: Icon(icon, color: theme.colorScheme.secondary),
        ),
        title: Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Text('À propos des Khatim',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            const Text(
              'Les Khatim (خواتم) sont des carrés magiques utilisés dans la '
              'tradition soufie. Chaque dimension (3×3 à 9×9) est associée à une '
              'planète et à des usages spécifiques.\n\n'
              'Le Poids Mystique (PM) provient d\'un nombre ou du calcul Abjad '
              'd\'un texte arabe. La « Technique de configuration » soustrait une '
              'constante, divise par la dimension, puis répartit le reste.\n\n'
              'Chaque Khatim possède une Clé, un Verrou, une Médiane, un WAFQ, '
              'une Aire, une Force et un But, d\'où l\'on extrait les noms des '
              'esprits-servants (célestes et terrestres).\n\n'
              'Outil éducatif : respectez le cadre éthique et spirituel associé '
              'à ces pratiques.',
            ),
          ],
        ),
      ),
    );
  }
}
