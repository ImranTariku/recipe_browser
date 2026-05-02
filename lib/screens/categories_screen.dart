import 'dart:async';
import 'package:flutter/material.dart';
import '../models/meal_category.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';
import 'meals_screen.dart';
import 'meal_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final MealApiService _api = MealApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<MealCategory>> _categoriesFuture;
  List<Meal> _searchResults = [];
  bool _isSearching = false;
  bool _searchLoading = false;
  String? _searchError;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _api.fetchCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _searchError = null;
      });
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _isSearching = true;
      _searchLoading = true;
      _searchError = null;
    });
    try {
      final results = await _api.searchMeals(query);
      setState(() {
        _searchResults = results;
        _searchLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchError = e.toString();
        _searchLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        centerTitle: true,
        elevation: 2,
        title: const Text(
          'Recipe Browser',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          _SearchBar(controller: _searchController),
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : _buildCategoryGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
      );
    }
    if (_searchError != null) {
      return _ErrorView(
        message: _searchError!,
        onRetry: () => _runSearch(_searchController.text.trim()),
      );
    }
    if (_searchResults.isEmpty) {
      return const _EmptyView(message: 'No meals found.');
    }
    return _MealGrid(
      meals: _searchResults,
      onTap: (meal) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MealDetailScreen(mealId: meal.idMeal),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return FutureBuilder<List<MealCategory>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
          );
        }
        if (snapshot.hasError) {
          return _ErrorView(
            message: snapshot.error.toString(),
            onRetry: () =>
                setState(() => _categoriesFuture = _api.fetchCategories()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const _EmptyView(message: 'No categories found.');
        }
        final categories = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 180,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return _RecipeCard(
              imageUrl: cat.strCategoryThumb,
              title: cat.strCategory,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MealsScreen(category: cat.strCategory),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

String _betterImage(String url) => url.replaceAll('/preview', '');

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1B5E20),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            controller: controller,
            style: const TextStyle(fontSize: 15, color: Color(0xFF2C3E50)),
            decoration: InputDecoration(
              hintText: '🔍 Find a meal...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
              prefixIcon: const Icon(Icons.search,
                  color: Color(0xFF1B5E20), size: 22),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel,
                          color: Colors.grey, size: 20),
                      onPressed: controller.clear,
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;

  const _RecipeCard({
    required this.imageUrl,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image — fixed 120 px, never stretches
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 120,
                child: Image.network(
                  _betterImage(imageUrl),
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.broken_image,
                        size: 36, color: Colors.grey),
                  ),
                ),
              ),
            ),
            // Title — fixed 50 px
            SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealGrid extends StatelessWidget {
  final List<Meal> meals;
  final void Function(Meal) onTap;
  const _MealGrid({required this.meals, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 180,
      ),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return _RecipeCard(
          imageUrl: meal.strMealThumb,
          title: meal.strMeal,
          onTap: () => onTap(meal),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 54, color: Color(0xFFFF8C00)),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF2C3E50), height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 54, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}