// lib/features/health/recommendations_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/recommendation_card.dart';
import '../../data/models/recommendation.dart';
import '../../data/repositories/recommendation_repository.dart';
import '../dashboard/recommendation_detail_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> with SingleTickerProviderStateMixin {
  final RecommendationRepository _repository = RecommendationRepository();
  late TabController _tabController;
  
  late Future<List<Recommendation>> _recommendationsFuture;
  List<Recommendation> _allRecommendations = [];
  String _selectedFilter = 'all';
  
  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'label': 'All', 'icon': Icons.list},
    {'id': 'activity', 'label': 'Activity', 'icon': Icons.directions_run},
    {'id': 'health', 'label': 'Health', 'icon': Icons.health_and_safety},
    {'id': 'indoor', 'label': 'Indoor', 'icon': Icons.home},
    {'id': 'travel', 'label': 'Travel', 'icon': Icons.directions_car},
    {'id': 'environment', 'label': 'Environment', 'icon': Icons.eco},
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _recommendationsFuture = _repository.getRecommendations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Recommendation> _getFilteredRecommendations() {
    if (_selectedFilter == 'all') {
      return _allRecommendations;
    }
    return _allRecommendations.where((rec) => rec.type == _selectedFilter).toList();
  }

  List<Recommendation> _getCompletedRecommendations() {
    // In a real application, you would check against a database of completed recommendations
    // For demo purposes, we'll just return a subset of the recommendations
    return _allRecommendations.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Recommendations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.gray60,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: FutureBuilder<List<Recommendation>>(
        future: _recommendationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: AppColors.danger),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _recommendationsFuture = _repository.getRecommendations();
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No recommendations available'),
            );
          }
          
          _allRecommendations = snapshot.data!;
          
          return Column(
            children: [
              // Filters
              Container(
                height: 120,
                padding: EdgeInsets.all(AppDimensions.spacing3),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final bool isSelected = _selectedFilter == filter['id'];
                    
                    return Padding(
                      padding: EdgeInsets.only(right: AppDimensions.spacing2),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter['id'] as String;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                filter['icon'] as IconData,
                                color: isSelected ? Colors.white : AppColors.gray60,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              filter['label'] as String,
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.gray70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fade().slideY(begin: -0.3, end: 0),
              
              // Recommendation Lists
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Active Recommendations Tab
                    RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _recommendationsFuture = _repository.getRecommendations();
                        });
                      },
                      child: _buildRecommendationsList(_getFilteredRecommendations()),
                    ),
                    
                    // Completed Recommendations Tab
                    _buildRecommendationsList(_getCompletedRecommendations(), isCompleted: true),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecommendationsList(List<Recommendation> recommendations, {bool isCompleted = false}) {
    if (recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.filter_list,
              size: 60,
              color: AppColors.gray50,
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted
                  ? 'No completed recommendations yet'
                  : 'No recommendations match the filter',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.gray60,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppDimensions.spacing4),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];
        
        Widget card = RecommendationCard(
          title: recommendation.title,
          description: recommendation.description,
          icon: recommendation.iconData,
          severity: recommendation.severity,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecommendationDetailScreen(
                  recommendation: recommendation,
                ),
              ),
            );
          },
        );
        
        if (isCompleted) {
          card = Stack(
            children: [
              card,
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          );
        }
        
        return card.animate().fade().slideY(begin: 0.3, end: 0);
      },
    );
  }
}