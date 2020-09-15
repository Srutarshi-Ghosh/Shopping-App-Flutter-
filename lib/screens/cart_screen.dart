import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';


class CartScreen extends StatelessWidget {
    static const routeName = '/cart';

    @override
    Widget build(BuildContext context) {
        final cart = Provider.of<Cart>(context);

        return Scaffold(
            appBar: AppBar(
                title: Text("Your Cart"),
            ),
            body: Column(
                children: <Widget>[

                    Card(
                        margin: const EdgeInsets.all(15),
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[

                                    Text('Total:', style: TextStyle(fontSize: 20)),

                                    Spacer(),

                                    Chip(
                                        label: Text(
                                            'Rs. ${cart.totalAmmount}', 
                                            style: TextStyle(color: Theme.of(context).primaryTextTheme.subtitle1.color)
                                        ),
                                        backgroundColor: Theme.of(context).primaryColor,
                                    ),

                                    OrderButton(cart: cart)

                                ],
                                
                            ),
                        ),
                    ),

                    SizedBox(height: 10,),

                    Expanded(
                        child: ListView.builder(
                            itemBuilder: (ctx, i)=> CartItem(
                                id: cart.items.values.toList()[i].id,
                                price: cart.items.values.toList()[i].price, 
                                quantity: cart.items.values.toList()[i].quantity, 
                                title: cart.items.values.toList()[i].title,
                                productId: cart.items.keys.toList()[i],
                            ),
                            itemCount: cart.itemCount, 
                        )
                    )

                ],
            ),
        );
    }
}

class OrderButton extends StatefulWidget {
    const OrderButton({
        Key key,
        @required this.cart,
    }) : super(key: key);

    final Cart cart;

    @override
    _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
    var _isLoading = false;

    @override
    Widget build(BuildContext context) {
        return FlatButton(
            child: _isLoading 
                ? CircularProgressIndicator()
                : Text("ORDER NOW"),
            onPressed: (widget.cart.totalAmmount <= 0 || _isLoading)
                ? null 
                : () async {
                    setState(()=> _isLoading = true);
                    await Provider.of<Orders>(context, listen: false).addOrders(widget.cart.items.values.toList(), widget.cart.totalAmmount);
                    setState(()=> _isLoading = false);
                    widget.cart.clearCart();
                },
            textColor: Theme.of(context).primaryColor,
        );
    }
}