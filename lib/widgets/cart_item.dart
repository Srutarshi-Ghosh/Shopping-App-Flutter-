import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';


class CartItem extends StatelessWidget {
    final String id;
    final double price;
    final int quantity;
    final String title;
    final String productId;

    CartItem({this.id, this.price, this.quantity, this.title, this.productId});

    @override
    Widget build(BuildContext context) {
        return Dismissible(
            key: ValueKey(id),
            background: Container(
                color: Theme.of(context).primaryColor,
                child: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 40,
                ),
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) {
                return showDialog(
                    context: context,
                    builder: (ctx)=> AlertDialog(
                        title: Text('Are you sure'),
                        content: Text('Do you want to remove the item from the cart?'),
                        actions: <Widget>[
                            FlatButton(
                                child: Text('NO'),
                                onPressed: ()=> Navigator.of(ctx).pop(false),
                            ),
                            FlatButton(
                                child: Text('YES'),
                                onPressed: ()=> Navigator.of(ctx).pop(true),
                            )
                        ],
                    )
                );
            },
            onDismissed: (direction) {
                Provider.of<Cart>(context, listen: false).removeItem(productId);
            },
            child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListTile(
                        leading: Padding(
                            padding: EdgeInsets.all(5),
                            child: CircleAvatar(
                                child: FittedBox(         
                                    child: Text('Rs. $price')
                                ),
                            ),
                        ),
                        title: Text(title),
                        subtitle: Text('Total: ${price * quantity}'),
                        trailing: Text('$quantity x'),
                    ),
                ),
            ),
        );
    }
}