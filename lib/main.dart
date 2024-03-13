import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = StringBuffer();
    final length = newValue.text.length;

    for (int i = 0; i < length; i++) {
      if (i == 2 || i == 4) {
        newText.write('.');
      }

      if(i > 7){
        break;
      }

      newText.write(newValue.text[i]);
    }

    return newValue.copyWith(text: newText.toString(), selection: TextSelection.collapsed(offset: newText.length));
  }
}
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STT Kontrol Uygulaması'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              ).then((value) {
                if (value != null) {
                  setState(() {
                    products.add(value);
                  });
                }
              });
            },
            child: Row(
              children: [
                Icon(Icons.add_a_photo),
                SizedBox(width: 8),
                Text('Ürün Ekle'),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: products[index]['imagePath'] != null
                        ? CircleAvatar(
                            backgroundImage: FileImage(File(products[index]['imagePath'])),
                          )
                        : null,
                    title: Text('Ürün: ${products[index]['productName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori: ${products[index]['category']}'),
                        Text('Son Kullanma Tarihi: ${products[index]['expirationDate']}'),
                        Text('Uyarı Günü: ${products[index]['warningDay']}'),
                        Text('Adet: ${products[index]['quantity']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editProduct(context, index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _confirmDelete(context, index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Emin misiniz?'),
          content: Text('Bu ürünü silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _removeProduct(index);
                Navigator.pop(context);
              },
              child: Text('Evet'),
            ),
          ],
        );
      },
    );
  }

  void _removeProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  void _editProduct(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProductPage(product: products[index])),
    ).then((editedProduct) {
      if (editedProduct != null) {
        setState(() {
          products[index] = editedProduct;
        });
      }
    });
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _warningDayController = TextEditingController();
  int _quantity = 1;
  String? _selectedCategory;
  String? _selectedImagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _pickImage();
              },
              child: Row(
                children: [
                  Icon(Icons.add_a_photo),
                  SizedBox(width: 8),
                  Text('Fotoğraf Ekle'),
                ],
              ),
            ),
            if (_selectedImagePath != null)
              Image.file(
                File(_selectedImagePath!),
                height: 100,
              ),
            SizedBox(height: 20),
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Ürün adını girin'),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedCategory ?? 'Genel', // Default olarak 'Genel' seçili
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: <String>[
                'Genel', 'Meyve', 'Sebze', 'Et Ürünleri', 'Balık Ürünleri', 'Hazır Gıdalar', 'Baharatlar', 'Konserve'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _expirationDateController,
              decoration: InputDecoration(labelText: 'Son kullanma tarihini girin (gg-aa-yyyy)'),
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
                _DateInputFormatter(),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _warningDayController,
              decoration: InputDecoration(labelText: 'Uyarı gününü girin'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_quantity > 1) {
                        _quantity--;
                      }
                    });
                  },
                  child: Icon(Icons.remove),
                ),
                Text(
                  'Adet: $_quantity',
                  style: TextStyle(fontSize: 30),
                  ), // Adet seçimi burada gösteriliyor
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String productName = _productNameController.text;
                String expirationDate = _expirationDateController.text;
                int warningDay = int.tryParse(_warningDayController.text) ?? 0;

                // Eğer _selectedCategory null ise, 'Genel' olarak ayarla
                String category = _selectedCategory ?? 'Genel';

                Navigator.pop(context, {
                  'productName': productName,
                  'imagePath': _selectedImagePath,
                  'category': category,
                  'expirationDate': expirationDate,
                  'warningDay': warningDay,
                  'quantity': _quantity,
                });
              },
              child: Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }
}

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  EditProductPage({required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _warningDayController = TextEditingController();
  int _quantity = 1;
  String? _selectedCategory;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _productNameController.text = widget.product['productName'];
    _expirationDateController.text = widget.product['expirationDate'];
    _warningDayController.text = widget.product['warningDay'].toString();
    _quantity = widget.product['quantity'];
    _selectedCategory = widget.product['category'];
    _selectedImagePath = widget.product['imagePath'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _pickImage();
              },
              child: Row(
                children: [
                  Icon(Icons.add_a_photo),
                  SizedBox(width: 8),
                  Text('Fotoğraf Ekle'),
                ],
              ),
            ),
            if (_selectedImagePath != null)
              Image.file(
                File(_selectedImagePath!),
                height: 100,
              ),
            SizedBox(height: 20),
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Ürün adını girin'),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: <String>['Genel', 'Meyve', 'Sebze', 'Et Ürünleri', 'Balık Ürünleri', 'Hazır Gıdalar', 'Baharatlar','Konserve']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _expirationDateController,
              decoration: InputDecoration(labelText: 'Son kullanma tarihini girin (gg-aa-yyyy)'),
              keyboardType: TextInputType.datetime,
              inputFormatters: [ 
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
                _DateInputFormatter(),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _warningDayController,
              decoration: InputDecoration(labelText: 'Uyarı gününü girin'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_quantity > 1) {
                        _quantity--;
                      }
                    });
                  },
                  child: Icon(Icons.remove),
                ),
                Text(
                  'Adet: $_quantity',
                  style: TextStyle(fontSize: 21),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String productName = _productNameController.text;
                String expirationDate = _expirationDateController.text;
                int warningDay = int.tryParse(_warningDayController.text) ?? 0;
                Navigator.pop(context, {
                  'productName': productName,
                  'imagePath': _selectedImagePath,
                  'category': _selectedCategory,
                  'expirationDate': expirationDate,
                  'warningDay': warningDay,
                  'quantity': _quantity,
                });
              },
              child: Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }
}