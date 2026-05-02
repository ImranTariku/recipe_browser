// Recipe Browser API service using TheMealDB
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/meal_category.dart';
import '../models/meal.dart';
import 'api_exception.dart';

class MealApiService {
  static const String _baseUrl = 'www.themealdb.com';
  static const Duration _timeout = Duration(seconds: 10);

  http.Response _checkResponse(http.Response response) {
    if (response.statusCode == 200) return response;
    throw ApiException('Server error: ${response.statusCode}');
  }

  Future<List<MealCategory>> fetchCategories() async {
    try {
      final uri = Uri.https(_baseUrl, '/api/json/v1/1/categories.php');
      final response = await http.get(uri).timeout(_timeout);
      _checkResponse(response);
      final data = jsonDecode(response.body);
      final List list = data['categories'] ?? [];
      return list.map((e) => MealCategory.fromJson(e)).toList();
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Try again.');
    } on FormatException {
      throw const ApiException('Unexpected data format from server.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Something went wrong: $e');
    }
  }

  Future<List<Meal>> fetchMealsByCategory(String category) async {
    try {
      final uri = Uri.https(_baseUrl, '/api/json/v1/1/filter.php', {'c': category});
      final response = await http.get(uri).timeout(_timeout);
      _checkResponse(response);
      final data = jsonDecode(response.body);
      final List list = data['meals'] ?? [];
      return list.map((e) => Meal.fromJson(e)).toList();
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Try again.');
    } on FormatException {
      throw const ApiException('Unexpected data format from server.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Something went wrong: $e');
    }
  }

  Future<Meal> fetchMealById(String id) async {
    try {
      final uri = Uri.https(_baseUrl, '/api/json/v1/1/lookup.php', {'i': id});
      final response = await http.get(uri).timeout(_timeout);
      _checkResponse(response);
      final data = jsonDecode(response.body);
      final List list = data['meals'] ?? [];
      if (list.isEmpty) throw const ApiException('Meal not found.');
      return Meal.fromJson(list[0]);
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Try again.');
    } on FormatException {
      throw const ApiException('Unexpected data format from server.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Something went wrong: $e');
    }
  }

  Future<List<Meal>> searchMeals(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final uri = Uri.https(_baseUrl, '/api/json/v1/1/search.php', {'s': query});
      final response = await http.get(uri).timeout(_timeout);
      _checkResponse(response);
      final data = jsonDecode(response.body);
      final List list = data['meals'] ?? [];
      return list.map((e) => Meal.fromJson(e)).toList();
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Try again.');
    } on FormatException {
      throw const ApiException('Unexpected data format from server.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Something went wrong: $e');
    }
  }
}