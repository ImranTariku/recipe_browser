import 'dart:async';
import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';
import 'meal_detail_screen.dart';

String _betterImage(String url) => url.replaceAll('/preview', '');

class MealsScreen extends StatefulWidget {
  final String category;
  const MealsScreen({super.key, required this.category});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final MealApiService _api = MealApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Meal> _allMeals = [];
  List<Meal> _filtered = [];
  bool _isLoading = true;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final meals = await _api.fetchMealsByCategory(widget.category);
      setState(() { _allMeals = meals; _filtered = meals; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = _searchController.text.toLowerCase().trim();
      setState(() {
        _filtered = q.isEmpty
            ? _allMeals
            : _allMeals
                .where((m) => m.strMeal.toLowerCase().contains(q))
                .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        centerTitle: true,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.category,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: const Color(0xFF1B5E20),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                return TextField(
                  controller: _searchController,
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF2C3E50)),
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.category} meals...',
                    hintStyle:
                        TextStyle(color: Colors.grey[400], fontSize: 15),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF1B5E20), size: 22),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel,
                                color: Colors.grey, size: 20),
                            onPressed: _searchController.clear,
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1B5E20)))
                : _error != null
                    ? _ErrorView(
                        message: _error!, onRetry: _loadMeals)
                    : _filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded,
                                    size: 54, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'No meals found.',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                14, 14, 14, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 180,
                            ),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final meal = _filtered[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MealDetailScreen(
                                        mealId: meal.idMeal),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top:
                                                    Radius.circular(16)),
                                        child: SizedBox(
                                          height: 120,
                                          child: Image.network(
                                            _betterImage(
                                                meal.strMealThumb),
                                            fit: BoxFit.cover,
                                            loadingBuilder: (_,
                                                    child, progress) =>
                                                progress == null
                                                    ? child
                                                    : Container(
                                                        color: Colors
                                                            .grey[100],
                                                        child:
                                                            const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth:
                                                                2,
                                                            color: Color(
                                                                0xFF1B5E20),
                                                          ),
                                                        ),
                                                      ),
                                            errorBuilder:
                                                (_, __, ___) =>
                                                    Container(
                                              color: Colors.grey[100],
                                              child: const Icon(
                                                  Icons.broken_image,
                                                  size: 36,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 50,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8),
                                          child: Center(
                                            child: Text(
                                              meal.strMeal,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis,
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
                            },
                          ),
          ),
        ],
      ),
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
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2C3E50),
                    height: 1.4)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
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