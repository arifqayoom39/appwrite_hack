import 'package:flutter/material.dart';

class StorefrontScreen extends StatelessWidget {
  final String shopSlug;
  const StorefrontScreen({Key? key, required this.shopSlug}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shop: $shopSlug')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text('Welcome to $shopSlug!', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          Expanded(child: ProductList()),
        ],
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder products
    final products = [
      {'name': 'Tea', 'price': '10', 'desc': 'Best tea in town'},
      {'name': 'Coffee', 'price': '15', 'desc': 'Freshly brewed'},
    ];
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: ListTile(
            title: Text(product['name']!),
            subtitle: Text(product['desc']!),
            trailing: Text('	${product['price']}'),
          ),
        );
      },
    );
  }
}
