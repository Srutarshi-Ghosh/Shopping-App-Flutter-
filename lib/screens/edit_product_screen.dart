import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';


class EditProductScreen extends StatefulWidget {
    static const routeName = '/edit-product';

    @override
    _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
    final _priceFocusNode = FocusNode();
    final _descriptionFocusNode = FocusNode();
    final _imageUrlFocusNode = FocusNode();
    final _imageUrlController = TextEditingController();
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _priceController = TextEditingController();
    final _form = GlobalKey<FormState>();
    var editedProduct = Product(id: null, title: null, description: null, imageUrl: null, price: null);
    var _isInit = true;
    var _containsId = false;
    var productId = '';
    var _isFav = false;
    var _isLoading = false;


    @override
    void initState() {
        _imageUrlFocusNode.addListener(_updateImageUrl);
        super.initState();
    }

    @override
    void didChangeDependencies() {
        if(_isInit){
            productId = ModalRoute.of(context).settings.arguments as String;
            if(productId != null){
                final editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
                _titleController.text = editedProduct.title;
                _priceController.text = editedProduct.price.toString();
                _descriptionController.text = editedProduct.description;
                _imageUrlController.text = editedProduct.imageUrl;
                _isFav = editedProduct.isFavourite;
                _containsId = true;
            }
        }
        _isInit = false;
        super.didChangeDependencies();
    }

    @override
    void dispose() {
        _imageUrlFocusNode.removeListener(_updateImageUrl);
        _priceFocusNode.dispose();
        _descriptionFocusNode.dispose();
        _imageUrlController.dispose();
        _imageUrlFocusNode.dispose();
        super.dispose();
    }

    void _updateImageUrl(){
        if(!_imageUrlFocusNode.hasFocus)
            setState(() { });
    }

    Future<void> _saveForm() async {
        final _isValid = _form.currentState.validate();
        if(!_isValid)
            return ;
        _form.currentState.save();
        setState(() {
            _isLoading = true;
        });
        if(_containsId){
            editedProduct = Product(
                id: productId,
                title: _titleController.text,
                description: _descriptionController.text,
                price: double.parse(_priceController.text),
                imageUrl: _imageUrlController.text,
                isFavourite: _isFav
            );
            await Provider.of<Products>(context, listen: false).updateProduct(editedProduct.id, editedProduct);
        }
        else {
            editedProduct = Product(
                id: DateTime.now().toString(),
                title: _titleController.text,
                description: _descriptionController.text,
                price: double.parse(_priceController.text),
                imageUrl: _imageUrlController.text,
            );
            try{
                await Provider.of<Products>(context, listen: false).addProduct(editedProduct);
            }
            catch (error) {
                await showDialog(
                    context: context,
                    builder: (ctx)=> AlertDialog(
                        title: Text("An Error Occured"),
                        content: Text(error.toString()),
                        actions: <Widget>[
                            FlatButton(
                                child: Text("Okay"),
                                onPressed: ()=> Navigator.of(context).pop(),
                            )
                        ],
                    )
                );
            }
        }
        setState(()=> _isLoading = false);
        Navigator.of(context).pop();
            
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Edit Product'),
                actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.save),
                        onPressed: _saveForm,
                    )
                ],
            ),
            body: _isLoading
                ? Center(child: CircularProgressIndicator())
            
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                        key: _form,
                        child: ListView(
                            children: <Widget>[

                                TextFormField(
                                    decoration: InputDecoration(labelText: 'Title'),
                                    textInputAction: TextInputAction.next,
                                    controller: _titleController,
                                    onFieldSubmitted: (_)=> FocusScope.of(context).requestFocus(_priceFocusNode),
                                    validator: (value)=> value.isEmpty ? 'Please Enter Title' : null,
                                ),

                                TextFormField(
                                    decoration: InputDecoration(labelText: 'Price'),
                                    textInputAction: TextInputAction.next,
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    focusNode: _priceFocusNode,
                                    onFieldSubmitted: (_)=> FocusScope.of(context).requestFocus(_descriptionFocusNode),
                                    validator: (value) {
                                        if(value.isEmpty)
                                            return 'Please enter a price!';
                                        if(double.tryParse(value) == null || double.parse(value) <= 0)
                                            return 'Please Enter a valid number!';
                                        
                                        return null;
                                    },
                                ),

                                TextFormField(
                                    decoration: InputDecoration(labelText: 'Description'),
                                    maxLines: 3,
                                    textInputAction: TextInputAction.next,
                                    controller: _descriptionController,
                                    keyboardType: TextInputType.multiline,
                                    focusNode: _descriptionFocusNode,
                                    validator: (value) {
                                        if(value.isEmpty) 
                                            return 'Please Enter a Description!';
                                        if(value.length < 10)
                                            return 'At Least 10 characters!'; 
                                        return null;
                                    }
                                ),

                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                        Container(
                                            width: 100,
                                            height: 100,
                                            margin: EdgeInsets.only(right: 10, top: 8),
                                            decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
                                            child: Container(
                                                child: _imageUrlController.text.isEmpty
                                                    ? Text("Enter Image URL")
                                                    : FittedBox(
                                                        child: Image.network(_imageUrlController.text, fit: BoxFit.cover),
                                                    )
                                            ),
                                        ),
                                        Expanded(
                                            child: TextFormField(
                                                decoration: InputDecoration(labelText: 'Image Url'),
                                                keyboardType: TextInputType.url,
                                                textInputAction: TextInputAction.done,
                                                controller: _imageUrlController,
                                                focusNode: _imageUrlFocusNode,
                                                onFieldSubmitted: (_)=> _saveForm(),
                                                validator: (value) {
                                                    if(value.isEmpty)
                                                        return 'Please Enter an Image URL';
                                                    var urlPattern = r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
                                                    var result = RegExp(urlPattern, caseSensitive: false).firstMatch(value);
                                                    if(result == null)
                                                        return 'Please Enter a vaid URL';
                                                    return null;
                                                },
                                            ),
                                        )
                                    ],
                                )

                            ],
                        ),
                    ),
                ),
        );
    }
}