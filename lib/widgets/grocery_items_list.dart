import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shopping_list_app/data/categories.dart';
import 'package:flutter_shopping_list_app/models/grocery_item.dart';
import 'package:flutter_shopping_list_app/widgets/grocery_item_tile.dart';
import 'package:flutter_shopping_list_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryItemsList extends StatefulWidget {
  const GroceryItemsList({super.key});

  @override
  State<GroceryItemsList> createState() => _GroceryItemsListState();
}

class _GroceryItemsListState extends State<GroceryItemsList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'flutter-shopping-list-fdb34-default-rtdb.europe-west1.firebasedatabase.app',
      'shopping-list.json',
    );
    try {
      final res = await http.get(url);
      if (res.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later';
        });
      }

      if (res.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> itemsData = json.decode(res.body);
      final List<GroceryItem> loadedItems = [];

      for (final item in itemsData.entries) {
        final category = categories.entries.firstWhere(
          (element) => element.value.name == item.value['category'],
        );
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category.value,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong!';
      });
      print(error);
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _deleteItem(GroceryItem item) async {
    final url = Uri.https(
      'flutter-shopping-list-fdb34-default-rtdb.europe-west1.firebasedatabase.app',
      'shopping-list/${item.id}.json',
    );
    final res = await http.delete(url);

    if (res.statusCode == 200) {
      setState(() {
        _groceryItems.remove(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addItem)],
      ),
      body:
          _error != null
              ? Center(child: Text(_error!))
              : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _groceryItems.isEmpty
              ? const Center(child: Text("Currently no grocery items here"))
              : ListView.builder(
                itemCount: _groceryItems.length,
                itemBuilder:
                    (context, index) => Dismissible(
                      key: ValueKey(_groceryItems[index].id),
                      onDismissed: (direction) {
                        _deleteItem(_groceryItems[index]);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GroceryItemTile(groceryItem: _groceryItems[index]),
                    ),
              ),
    );
  }
}
