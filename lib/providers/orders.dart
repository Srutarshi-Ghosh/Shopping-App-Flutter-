import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';


class OrderItem {
    final String id;
    final double ammount;
    final List<CartItem> products;
    final DateTime dateTime;

    OrderItem({
        @required this.id,        
        @required this.ammount,
        @required this.products,
        @required this.dateTime,
    });

}


class Orders with ChangeNotifier {

    final String authToken;
    List<OrderItem> _orders;
    final String userId;

    Orders(this.authToken, this._orders, this.userId);

    List<OrderItem> get orders {
        return [..._orders];
    }

    Future<void> fetchOrders() async {
        final url = 'https://shopping-app-dec54.firebaseio.com/orders/$userId.json?auth=$authToken';

        try {
            final response = await http.get(url);
            final extractedData = json.decode(response.body) as Map<String, dynamic>;
            final List<OrderItem> loadedOrders = [];
            if(extractedData == null){
                return null;
            }
            extractedData.forEach((orderId, order) {
                loadedOrders.add(OrderItem(
                    id: orderId,
                    ammount: order['ammount'],
                    products: (order['products'] as List<dynamic>).map((item)=> CartItem(
                        id: item['id'],
                        price: item['price'],
                        quantity: item['quantity'],
                        title: item['title']
                    )).toList(),
                    dateTime: DateTime.parse(order['dateTime'])
                ));
               
            });
            _orders = loadedOrders.reversed.toList();
            notifyListeners();

        }
        catch (error) {
            throw error;
        }
    }

    Future<void> addOrders(List<CartItem> cartProducts, double total) async {
        final url = 'https://shopping-app-dec54.firebaseio.com/orders/$userId.json?auth=$authToken';
        final timestamp = DateTime.now();
        
        try{
            final response = await http.post(url, body: json.encode({
                'ammount': total,
                'dateTime': timestamp.toIso8601String(),
                'products': cartProducts.map((prod)=> {
                    'id': prod.id,
                    'title': prod.title,
                    'quantity': prod.quantity,
                    'price': prod.price
                }).toList(),
                
            }));
            _orders.insert(0, OrderItem(
                id: json.decode(response.body)['name'], 
                ammount: total, 
                products: cartProducts,
                dateTime: DateTime.now()
            ));
            notifyListeners();
        }
        catch(error) {
            print(error.toString());
            throw error;
        }
        
    }

}