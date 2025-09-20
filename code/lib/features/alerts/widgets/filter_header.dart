import 'package:flutter/material.dart';
import '../models/alert_filter.dart';

class FilterHeader extends StatelessWidget {
  final AlertFilter filter;
  final VoidCallback onClearFilters;
  final Animation<double> animation;

  const FilterHeader({
    super.key,
    required this.filter,
    required this.onClearFilters,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: filter.hasActiveFilters ? 60 : 0,
      child: filter.hasActiveFilters
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            'Active filters: ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          ..._buildActiveFilterChips(context),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  List<Widget> _buildActiveFilterChips(BuildContext context) {
    List<Widget> chips = [];
    
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      chips.add(_buildFilterChip(context, 'Search: "${filter.searchQuery}"'));
    }
    
    if (filter.severities.isNotEmpty) {
      chips.add(_buildFilterChip(context, '${filter.severities.length} Severity'));
    }
    
    if (filter.statuses.isNotEmpty) {
      chips.add(_buildFilterChip(context, '${filter.statuses.length} Status'));
    }
    
    if (filter.categories.isNotEmpty) {
      chips.add(_buildFilterChip(context, '${filter.categories.length} Category'));
    }
    
    return chips;
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}