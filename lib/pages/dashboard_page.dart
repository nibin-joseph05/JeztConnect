import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../components/header.dart';
import '../components/footer.dart';
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  final String accessToken;
  const DashboardPage({super.key, required this.accessToken});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<dynamic> _dashboardData = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    developer.log('Dashboard initialized with token: ${widget.accessToken.substring(0, 20)}...', name: 'DashboardPage');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      developer.log('Loading dashboard data...', name: 'DashboardPage');

      Map<String, dynamic> dashboard;
      try {
        dashboard = await ApiService.fetchDashboard(widget.accessToken);
      } catch (e) {
        developer.log('Bearer token failed, trying alternative...', name: 'DashboardPage');
        dashboard = await ApiService.fetchDashboardAlternative(widget.accessToken);
      }

      if (mounted) {
        List<dynamic> dataList = [];

        if (dashboard.containsKey('data')) {
          if (dashboard['data'] is List) {
            dataList = dashboard['data'] as List<dynamic>;
          } else {
            dataList = [dashboard['data']];
          }
        } else if (dashboard.containsKey('results')) {
          if (dashboard['results'] is List) {
            dataList = dashboard['results'] as List<dynamic>;
          } else {
            dataList = [dashboard['results']];
          }
        } else {
          dataList = [dashboard];
        }

        developer.log('Dashboard data processed: ${dataList.length} items', name: 'DashboardPage');

        setState(() {
          _dashboardData = dataList;
          _isLoading = false;
          _hasError = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      developer.log('Dashboard loading failed: $e', name: 'DashboardPage');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });

        if (e.toString().contains('Unauthorized')) {
          _showUnauthorizedDialog();
        }
      }
    }
  }

  void _showUnauthorizedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Logging out...'),
                    ],
                  ),
                ),
              );

              try {
                await ApiService.logout(widget.accessToken);
                developer.log('Logout successful', name: 'DashboardPage');
              } catch (e) {
                developer.log('Logout failed: $e', name: 'DashboardPage');
                if (mounted) {
                  Navigator.of(context).pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${e.toString()}'),
                      backgroundColor: Colors.orange,
                      action: SnackBarAction(
                        label: 'Continue',
                        onPressed: () {},
                      ),
                    ),
                  );
                }
              }

              if (mounted) {
                Navigator.of(context).pop();
                navigator.pushReplacementNamed('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildDataCard(int index, dynamic item) {
    final colorIndex = index % 4;
    final colors = [
      const Color(0xFF2E86AB),
      const Color(0xFF1B4965),
      const Color(0xFF62B6CB),
      const Color(0xFF7FB069),
    ];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(0.1 * index.clamp(0, 10), 1.0, curve: Curves.easeOut),
            )),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors[colorIndex].withOpacity(0.8),
              colors[colorIndex].withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: colors[colorIndex].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item is Map)
                ...item.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${entry.key}:',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value?.toString() ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
              else
                Text(
                  item?.toString() ?? 'No data',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E86AB),
              Color(0xFF1B4965),
              Color(0xFF62B6CB),
              Color(0xFF7FB069),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            AppHeader(
              title: 'Dashboard',
              showBackButton: false,
              actions: [
                IconButton(
                  onPressed: _logout,
                  icon: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Loading Dashboard...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              )
                  : _hasError
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.white,
                        size: 60.0,
                      ),
                      const SizedBox(height: 20.0),
                      const Text(
                        'Failed to load data',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        _errorMessage.isNotEmpty
                            ? _errorMessage
                            : 'Please check your connection and try again',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2E86AB),
                          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
                  : _dashboardData.isEmpty
                  ? const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      child: Text(
                        'Dashboard Data (${_dashboardData.length} items)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _dashboardData.length,
                        itemBuilder: (context, index) => _buildDataCard(index, _dashboardData[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}