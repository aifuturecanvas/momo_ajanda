import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/momo_hub/application/momo_hub_providers.dart';
import 'package:momo_ajanda/features/momo_hub/models/momo_suggestion.dart';

class MomoSuggestionsCard extends ConsumerWidget {
  final Function(MomoSuggestion)? onSuggestionAction;

  const MomoSuggestionsCard({
    super.key,
    this.onSuggestionAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubState = ref.watch(momoHubProvider);
    final suggestions =
        hubState.suggestions.where((s) => !s.isDismissed).toList();
    final theme = Theme.of(context);

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Momo\'nun Önerileri',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...suggestions.take(3).map((suggestion) => _SuggestionTile(
                  suggestion: suggestion,
                  onAction: () => onSuggestionAction?.call(suggestion),
                  onDismiss: () {
                    ref
                        .read(momoHubProvider.notifier)
                        .dismissSuggestion(suggestion.id);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final MomoSuggestion suggestion;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const _SuggestionTile({
    required this.suggestion,
    this.onAction,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: suggestion.displayColor.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: suggestion.displayColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: suggestion.displayColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              suggestion.displayIcon,
              color: suggestion.displayColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion.message,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (suggestion.actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                backgroundColor: suggestion.displayColor.withOpacity(0.2),
                foregroundColor: suggestion.displayColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
              ),
              child: Text(
                suggestion.actionLabel!,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
