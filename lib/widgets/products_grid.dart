import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/product_item.dart';
import '../providers/products.dart';


class ProductsGrid extends StatelessWidget {
    final bool showfavs;

    ProductsGrid(this.showfavs);

    @override
    Widget build(BuildContext context) {
        final productData = Provider.of<Products>(context);
        final products = showfavs ? productData.favouriteItems : productData.items;

        return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemBuilder: (ctx, i)=> ChangeNotifierProvider.value(
                value: products[i],
                child: ProductItem(),
            ),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10
            ),

        );
    }
}