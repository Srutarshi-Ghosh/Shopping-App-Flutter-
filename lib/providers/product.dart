import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier{
    final String id;
    final String title;
    final String description;
    final double price;
    final String imageUrl;
    bool isFavourite;

    Product({
        @required this.id, 
        @required this.title, 
        @required this.description, 
        @required this.price, 
        @required this.imageUrl, 
        this.isFavourite = false
    });

    void _setFavVslue(bool oldStatus) {
        isFavourite = oldStatus;
        notifyListeners();
    }

    Future<void> toggleFavouriteStatus(String token, String userId) async{
        final oldStatus = isFavourite;
        isFavourite = !isFavourite;
        notifyListeners();

        final url = 'https://shopping-app-dec54.firebaseio.com/userFavourites/$userId/$id.json?auth=$token';
        try {
            final response = await http.put(url, body: json.encode(
                isFavourite
            ));
            if(response.statusCode >= 400){
                _setFavVslue(oldStatus);
            }

        }
        catch (error) {
            _setFavVslue(oldStatus);
        }

    }

}