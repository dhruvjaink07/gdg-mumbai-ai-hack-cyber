// filepath: e:\Hackathons\GDG Cloud Mumbai AI Hack\code\lib\features\alerts\pages\alert_filter_page.dart
import 'package:code/features/alerts/widgets/alert_helpers.dart';
import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../models/alert_filter.dart';
import '../services/alert_service.dart';

class FilterBottomSheet extends StatefulWidget {
  final AlertFilter initialFilter;
  final Function(AlertFilter) onFilterChanged;

  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onFilterChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet>
    with TickerProviderStateMixin {
  late List<AlertSeverity> selectedSeverities;
  late List<AlertStatus> selectedStatuses;
  late List<String> selectedCategories;
  late TextEditingController searchController;
  final alertService = AlertService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _tabController = TabController(length: 4, vsync: this);
  }

  void _initializeFilters() {
    selectedSeverities = List.from(widget.initialFilter.severities);
    selectedStatuses = List.from(widget.initialFilter.statuses);
    selectedCategories = List.from(widget.initialFilter.categories);
    searchController = TextEditingController(text: widget.initialFilter.searchQuery);
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHandleBar(),
          _buildHeader(),
          _buildTabBar(),
          _buildTabContent(),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            'Filter Alerts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Clear All'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Search'),
          Tab(text: 'Severity'),
          Tab(text: 'Status'),
          Tab(text: 'Category'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildSeverityTab(),
          _buildStatusTab(),
          _buildCategoryTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search in alerts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by title, description, IP, or user...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Search will look for matches in alert title, description, source IP, and affected user.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select severity levels',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...AlertSeverity.values.map((severity) {
            final isSelected = selectedSeverities.contains(severity);
            return _buildSelectableItem(
              isSelected: isSelected,
              color: AlertHelpers.getSeverityColor(severity),
              icon: AlertHelpers.getSeverityIcon(severity),
              title: AlertHelpers.getSeverityName(severity),
              onTap: () => _toggleSeverity(severity),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select alert status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...AlertStatus.values.map((status) {
            final isSelected = selectedStatuses.contains(status);
            return _buildSelectableItem(
              isSelected: isSelected,
              color: AlertHelpers.getStatusColor(status),
              icon: AlertHelpers.getStatusIcon(status),
              title: AlertHelpers.getStatusName(status),
              onTap: () => _toggleStatus(status),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: alertService.getAvailableCategories().map((category) {
                final isSelected = selectedCategories.contains(category);
                return _buildSelectableItem(
                  isSelected: isSelected,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  icon: AlertHelpers.getCategoryIcon(category),
                  title: category,
                  onTap: () => _toggleCategory(category),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableItem({
    required bool isSelected,
    required Color color,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? color : Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (isSelected) Icon(Icons.check_circle, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Apply Filters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _toggleSeverity(AlertSeverity severity) {
    setState(() {
      if (selectedSeverities.contains(severity)) {
        selectedSeverities.remove(severity);
      } else {
        selectedSeverities.add(severity);
      }
    });
  }

  void _toggleStatus(AlertStatus status) {
    setState(() {
      if (selectedStatuses.contains(status)) {
        selectedStatuses.remove(status);
      } else {
        selectedStatuses.add(status);
      }
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      selectedSeverities.clear();
      selectedStatuses.clear();
      selectedCategories.clear();
      searchController.clear();
    });
  }

  void _applyFilters() {
    final filter = AlertFilter(
      severities: selectedSeverities,
      statuses: selectedStatuses,
      categories: selectedCategories,
      searchQuery: searchController.text.trim().isEmpty 
          ? null 
          : searchController.text.trim(),
    );

    widget.onFilterChanged(filter);
    Navigator.of(context).pop();
  }
}