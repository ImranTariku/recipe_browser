import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';

String _betterImage(String url) => url.replaceAll('/preview', '');

class MealDetailScreen extends StatefulWidget {
  final String mealId;
  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealApiService _api = MealApiService();
  late Future<Meal> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchMealById(widget.mealId);
  }

  Future<void> _openYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open YouTube link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9E6),
      body: FutureBuilder<Meal>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
            );
          }

          if (snapshot.hasError) {
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
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => setState(
                          () => _future = _api.fetchMealById(widget.mealId)),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Meal not found.'));
          }

          final meal = snapshot.data!;
          return CustomScrollView(
            slivers: [
              // ── Hero image app bar ──────────────────────────────────────
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF1B5E20),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.fromLTRB(56, 0, 16, 14),
                  title: Text(
                    meal.strMeal,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 1))
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _betterImage(meal.strMealThumb),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image,
                              size: 60, color: Colors.grey),
                        ),
                      ),
                      // Gradient overlay so title is always readable
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0xCC1B5E20),
                            ],
                            stops: [0.55, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Chips ─────────────────────────────────────────
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (meal.strCategory.isNotEmpty)
                            _InfoChip(
                              label: meal.strCategory,
                              icon: Icons.category_outlined,
                              color: const Color(0xFF1B5E20),
                            ),
                          if (meal.strArea.isNotEmpty)
                            _InfoChip(
                              label: meal.strArea,
                              icon: Icons.public,
                              color: const Color(0xFFFF8C00),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── YouTube button ────────────────────────────────
                      if (meal.strYoutube.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openYoutube(meal.strYoutube),
                            icon: const Icon(Icons.play_circle_fill,
                                size: 22),
                            label: const Text(
                              'Watch on YouTube',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8C00),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                            ),
                          ),
                        ),
                      const SizedBox(height: 26),

                      // ── Ingredients ───────────────────────────────────
                      _SectionTitle(title: 'Ingredients'),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: meal.ingredients.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, indent: 42, endIndent: 16),
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 11),
                              child: Row(
                                children: [
                                  const Icon(Icons.fiber_manual_record,
                                      size: 10,
                                      color: Color(0xFFFF8C00)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      meal.ingredients[i],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2C3E50),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 26),

                      // ── Instructions ──────────────────────────────────
                      _SectionTitle(title: 'Instructions'),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          meal.strInstructions,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2C3E50),
                            height: 1.75,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _InfoChip(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}