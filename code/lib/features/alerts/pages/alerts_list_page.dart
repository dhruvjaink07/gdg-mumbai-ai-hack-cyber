import 'package:code/features/alerts/widgets/alert_filter.dart';
import 'package:code/features/alerts/widgets/user_menu.dart';
import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../models/alert_filter.dart';
import '../services/alert_service.dart';
import '../widgets/alert_card.dart';
import '../widgets/filter_header.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/login_page.dart';

class AlertsListPage extends StatefulWidget {
  const AlertsListPage({super.key});

  @override
  State<AlertsListPage> createState() => _AlertsListPageState();
}

class _AlertsListPageState extends State<AlertsListPage> 
    with TickerProviderStateMixin {
  final AlertService alertService = AlertService();
  final AuthService authService = AuthService();
  AlertFilter currentFilter = const AlertFilter();
  Future<List<AlertModel>>? alertsFuture;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAlerts();
  }

  void _initializeAnimations() {
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _loadAlerts() {
    setState(() {
      alertsFuture = alertService.fetchAlerts(filter: currentFilter);
    });
  }

  Future<void> _refreshAlerts() async {
    _loadAlerts();
    await alertsFuture;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialFilter: currentFilter,
        onFilterChanged: _handleFilterChanged,
      ),
    );
  }

  void _handleFilterChanged(AlertFilter filter) {
    setState(() {
      currentFilter = filter;
    });
    _loadAlerts();
    
    if (filter.hasActiveFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _clearFilters() {
    setState(() {
      currentFilter = const AlertFilter();
    });
    _loadAlerts();
    _filterAnimationController.reverse();
  }

  // Add logout method
  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await authService.signOut();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to logout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          FilterHeader(
            filter: currentFilter,
            onClearFilters: _clearFilters,
            animation: _filterAnimation,
          ),
          Expanded(child: _buildAlertsContent()),
        ],
      ),
      // floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('SOC Security Alerts'),
      actions: [
        _buildFilterButton(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuSelection,
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'user_info',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  authService.userEmail ?? 'No email',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: const Text('Current User'),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'user_info':
        // Do nothing or show user profile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile feature coming soon')),
        );
        break;
      case 'logout':
        _handleLogout();
        break;
    }
  }

  Widget _buildFilterButton() {
    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color: currentFilter.hasActiveFilters
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: _showFilterBottomSheet,
            ),
            if (currentFilter.hasActiveFilters)
              Positioned(
                right: 8,
                top: 8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 12 + (_filterAnimation.value * 4),
                  height: 12 + (_filterAnimation.value * 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 4 + (_filterAnimation.value * 2),
                        spreadRadius: _filterAnimation.value * 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAlertsContent() {
    return FutureBuilder<List<AlertModel>>(
      future: alertsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final alerts = snapshot.data ?? [];
        
        if (alerts.isEmpty) {
          return _buildEmptyState();
        }

        return _buildAlertsList(alerts);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading security alerts...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading alerts',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadAlerts,
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull down to refresh',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currentFilter.hasActiveFilters
                      ? Icons.search_off
                      : Icons.security,
                  size: 64,
                  color: currentFilter.hasActiveFilters
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  currentFilter.hasActiveFilters
                      ? 'No alerts match your filters'
                      : 'No security alerts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentFilter.hasActiveFilters
                      ? 'Try adjusting your filter criteria'
                      : 'All systems are secure',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull down to refresh',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (currentFilter.hasActiveFilters) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsList(List<AlertModel> alerts) {
    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return AlertCard(alert: alert);
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Navigate to add alert or settings
      },
      child: const Icon(Icons.add_alert),
    );
  }
}
