import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';


enum filterOptions {
    favourites,
    all
}

class ProductOverviewScreen extends StatefulWidget {    
    
    @override
    _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
    var _showOnlyFavourites = false;
    var _isInit = true;
    var _isLoading = false;


    @override
    void didChangeDependencies() {
        if(_isInit){
            setState(() {
                _isLoading = true;
            });
            Provider.of<Products>(context).fetchAndSetProducts().then((_) {
                setState(() {
                    _isLoading = false;
                });
            });
        }
        _isInit = false;
        super.didChangeDependencies();
    }

    @override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                title: Text("My Shop"),
                actions: <Widget>[
                    PopupMenuButton(
                        onSelected: (filterOptions selectedValue){
                            setState(() {
                                if(selectedValue == filterOptions.favourites){
                                    _showOnlyFavourites = true;
                                }
                                else if(selectedValue == filterOptions.all){
                                    _showOnlyFavourites = false;
                                }
                            });
                        },
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (_)=> [
                            PopupMenuItem(
                                child: Text("Only Favourites"),
                                value: filterOptions.favourites,
                            ),
                            PopupMenuItem(
                                child: Text("All Items"),
                                value: filterOptions.all,
                            ),
                        ]
                    ),
                    Consumer<Cart>(
                        builder: (_, cartData, ch)=> Badge(
                            child: ch,
                            value: cartData.itemCount.toString(),
                        ),
                        child: IconButton(
                            icon: Icon(Icons.shopping_cart),
                            onPressed: ()=> Navigator.of(context).pushNamed(CartScreen.routeName),
                        ),
                    )
                ],
            ),
            drawer: AppDrawer(),
            body: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ProductsGrid(_showOnlyFavourites)
            //body: ProductsGrid(_showOnlyFavourites),
        
        );
    }
}
