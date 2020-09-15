import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../providers/product.dart';
import '../models/http_exception.dart';


class Products with ChangeNotifier {

    List<Product> _items;
    final String authToken;
    final String userId;
    Products(this.authToken, this.userId, this._items);



    List<Product> get items {
        return [..._items];
    }

    List<Product> get favouriteItems {
        return _items.where((item) => item.isFavourite).toList();
    }

    Product findById(String id) {
        return _items.firstWhere((product) => product.id == id);
    }

    Future<Map<String, dynamic>> getFavouriteData() async {
        var favouritesUrl = 'https://shopping-app-dec54.firebaseio.com/userFavourites/$userId.json?auth=$authToken';
        final favouriteResponse = await http.get(favouritesUrl);
        final favouriteData = json.decode(favouriteResponse.body) as Map<String, dynamic>;
        return favouriteData;
    }


    Future<void> fetchAndSetProducts([bool filterByUser=false]) async {

        String filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' :'';
        var url = 'https://shopping-app-dec54.firebaseio.com/products.json?auth=$authToken&$filterString';

        try{
            final response = await http.get(url);
            final extractedData = json.decode(response.body) as Map<String, dynamic>;
            final favouriteData = await getFavouriteData();
            
            final List<Product> loadedProducts = [];
            extractedData.forEach((prodId, prodData) {
                loadedProducts.add(Product(
                    id: prodId,
                    title: prodData['title'],
                    description: prodData['description'],
                    price: prodData['price'],
                    isFavourite: favouriteData == null ?false :favouriteData[prodId] ??false,
                    imageUrl: prodData['imageUrl']
                ));
            });
            _items = loadedProducts;
            notifyListeners();
        }
        catch (error) {
            throw error;
        }
        
    }

    Future<void> addProduct(Product product) async {
        final url = 'https://shopping-app-dec54.firebaseio.com/products.json?auth=$authToken';
        try {
            final response = await http.post(url, body: json.encode({
                'title': product.title,
                'description': product.description,
                'price': product.price,
                'imageUrl': product.imageUrl,
                'creatorId': userId,
            }));
            final newProduct = Product(
                title: product.title,
                description: product.description,
                price: product.price,
                imageUrl: product.imageUrl,
                id: json.decode(response.body)['name']
            );
            _items.add(newProduct);
            notifyListeners();
        }
        catch(error) {
            print(error.toString());
            throw error;
        }

    }


    Future<void> updateProduct(String id, Product newProduct) async {
        final prodIndex = _items.indexWhere((prod) => prod.id == id);
        if(prodIndex >= 0) {
            final url = 'https://shopping-app-dec54.firebaseio.com/products/$id.json?auth=$authToken';
            await http.patch(url, body: json.encode({
                'title': newProduct.title,
                'description': newProduct.description,
                'price': newProduct.price,
                'imageUrl': newProduct.imageUrl,
            }));
            _items[prodIndex] = newProduct;
            notifyListeners();
        }
        else {
            print('...');
        }
    }

    Future<void> deleteProduct(String id) async {
        final url = 'https://shopping-app-dec54.firebaseio.com/products/$id.json?auth=$authToken';

        final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
        var existingProduct = _items[existingProductIndex];
        _items.removeAt(existingProductIndex);
        notifyListeners();

        final response = await http.delete(url);

        if(response.statusCode >= 400){
            _items.insert(existingProductIndex, existingProduct);
            notifyListeners();
            throw HttpException('Could not Delete Product');
        }
        existingProduct = null;
    }


}