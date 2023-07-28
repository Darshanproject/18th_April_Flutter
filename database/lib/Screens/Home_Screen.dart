import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'databaseHelper.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  List<Map<String, dynamic>> mydata = [];
  final formkey = GlobalKey<FormState>();

  bool _isLoading = true;

  void _refereshData() async {
    final data = await DatabaseHelper.getItems();
    setState(() {
      mydata = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
    _refereshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void showMyForm(int? id) async {
    if (id != null) {
      final existingData = mydata.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descriptionController.text = existingData['description'];
    } else {
      _titleController.text = '';
      _descriptionController.text = '';
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isDismissible: false,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Form(
                  key: formkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        validator: formValidator,
                        decoration: InputDecoration(hintText: 'Title'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: formValidator,
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(hintText: 'Description'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Exit")),
                          ElevatedButton(
                            onPressed: () async {
                              if (formkey.currentState!.validate()) {
                                if (id == null) {
                                  await addItem();
                                }

                                if (id != null) {
                                  await updateItem(id);
                                }

                                // Clear the text fields
                                setState(() {
                                  _titleController.text = '';
                                  _descriptionController.text = '';
                                });

                                // Close the bottom sheet
                                Navigator.pop(context);
                              }
                              // Save new data
                            },
                            child: Text(id == null ? 'Create New' : 'Update'),
                          ),
                        ],
                      )
                    ],
                  )),
            ));
  }

  String? formValidator(String? value) {
    if (value!.isEmpty) return 'Filed is Required';
    return null;
  }

  Future<void> addItem() async {
    await DatabaseHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refereshData();
  }

  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refereshData();
  }

  void deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Succefully Delete data"),
      backgroundColor: Colors.blueGrey,
    ));
    _refereshData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "My Local DataBase",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        )),
      ),
      body: _isLoading
          ? const Center(
              child: Text("Please enter the data"),
            )
          : ListView.builder(
              itemCount: mydata.length,
              itemBuilder: (context, index) => Card(
                    color: index % 2 == 0 ? Colors.red : Colors.blueGrey[500],
                    margin: const EdgeInsets.all(15),
                    child: ListTile(
                      title: Text(mydata[index]['title']),
                      subtitle: Text(mydata[index]['description']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showMyForm(mydata[index]['id']),
                            ),
                            IconButton(
                                onPressed: () =>
                                    deleteItem(mydata[index]['id']),
                                icon: const Icon(Icons.delete))
                          ],
                        ),
                      ),
                    ),
                  )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showMyForm(null),
        child: Text(
          "+",
          style: TextStyle(fontSize: 45),
        ),
      ),
    );
  }
}
