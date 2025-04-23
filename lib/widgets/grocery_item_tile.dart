import 'package:flutter/material.dart';
import 'package:flutter_shopping_list_app/models/grocery_item.dart';

class GroceryItemTile extends StatelessWidget {
  const GroceryItemTile({super.key, required this.groceryItem});

  final GroceryItem groceryItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(groceryItem.name, style: const TextStyle(fontSize: 16)),
      leading: Container(
        width: 24,
        height: 24,
        color: groceryItem.category.color,
      ),
      trailing: Text(
        groceryItem.quantity.toString(),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
