import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ToDoListProvider with ChangeNotifier {
  final _baseUrl = 'https://todolist-prog4-b9e62-default-rtdb.firebaseio.com';

  final List<Item> _listItems = [];
  final List<String> _categoryList = [
    "Afazeres Domésticos",
    "Trabalho",
    "Escola",
    "Outros"
  ];

  String _selectedCategory = "Todos";

  List<Item> get listItems {
    if (_selectedCategory == "Todos") {
      return _listItems;
    } else {
      return _listItems
          .where((item) => item.category == _selectedCategory)
          .toList();
    }
  }

  List<String> get categoryItems => _categoryList;

  String get selectedCategory => _selectedCategory;

  Future<void> load() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/listItem.json'));
      final data = jsonDecode(response.body) as Map<String, dynamic>?;

      if (data != null) {
        _listItems.clear(); // Limpa os itens existentes para evitar duplicação
        
        data.forEach((key, value) {
          final jsonDecod = jsonDecode(value) as Map<String, dynamic>;
          final item = Item(
            id: key,
            title: jsonDecod['title'],
            description: jsonDecod['description'],
            date: jsonDecod['date'],
            category: jsonDecod['category'],
          );
          _listItems.add(item);
        });
      }
      notifyListeners(); // Notifica os ouvintes que os dados foram carregados
    } catch (error) {
    }
  }

  Future<void> save(Item item) async {
    if (item.id.isEmpty) {
      await insert(item);
    } else {
      await update(item);
    }
  }

  Future<void> insert(Item item) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/listItem.json'),
      body: jsonEncode(item.toJson()),
    );

    final body = jsonDecode(response.body);
    final newItem = item.copyWith(
      id: body['name'], // Firebase retorna o ID único sob 'name'
    );

    _listItems.add(newItem);
    notifyListeners();
  }

  Future<void> update(Item item) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/listItem/${item.id}.json'),
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 200) {
      final index = _listItems.indexWhere((elem) => elem.id == item.id);
      if (index >= 0) {
        _listItems[index] = item;
        notifyListeners();
      }
    } else {
      print('Falha ao atualizar item: ${response.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final url = Uri.parse('$_baseUrl/listItem/$id.json');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {

        _listItems.removeWhere((listItem) => listItem.id == id);
        notifyListeners(); // Notifica os ouvintes após a remoção
      } 
    } catch (error) {
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
