import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../providers/orders.dart' as ord;

String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
}

class OrderItem extends StatefulWidget {
    final ord.OrderItem order;

    OrderItem(this.order);

    @override
    _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> with SingleTickerProviderStateMixin {
    var _expanded = false;
    
    
    @override
    Widget build(BuildContext context) {
        return Card(
            margin: const EdgeInsets.all(10),
            child: Column(
                children: <Widget>[
                    
                    ListTile(
                        title: Text('Rs ${format(widget.order.ammount)}'),
                        subtitle: Text(DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime)),
                        trailing: IconButton(
                            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                            onPressed: (){
                                setState(() {
                                    _expanded = !_expanded;
                                });
                            },
                        ),  
                    ),

                    AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        height: _expanded ? min(widget.order.products.length * 20.0 + 80, 80) : 0,
                        child: ListView(
                            children: widget.order.products.map((prod) {
                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                        Text(
                                            prod.title,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold
                                            ),
                                        ),
                                        Text(
                                            '${prod.quantity}x Rs ${prod.price}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey
                                            ),
                                        )
                                    ]
                                );
                            }).toList()
                        ),
                    )

                ],
            ),
        );
    }
}