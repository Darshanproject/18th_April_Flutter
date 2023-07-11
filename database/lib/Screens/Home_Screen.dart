// ignore_for_file: camel_case_types
import 'package:database/Screens/databaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

// ignore: use_key_in_widget_constructors, must_be_immutable
class Home_Page extends StatefulWidget {
  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  List<Map<String, dynamic>> mydata = [];
  final forkey = GlobalKey<FormState>();
  bool _isloading = true;
  void _refreshData() async {
    final data = await DatabaseHelper.getItems();
    setState(() {
      mydata = data;
      _isloading = false;
    });
  }

  @override
  void intState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
    _refreshData();
  }

  final TextEditingController _titeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  void showMyForm(int? id) async {
    if (id != null) {
      final existingData = mydata.firstWhere((element) => element[id] == id);
      _titeController.text = existingData['title'];
      _descriptionController.text = existingData['description'];
    } else {
      _titeController.text = "";
      _descriptionController.text = "";
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isDismissible: false,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  top: 12,
                  right: 12,
                  left: 12,
                  bottom:
                      MediaQuery.of(context as BuildContext).viewInsets.bottom +
                          120),
              child: Form(
                  key: forkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextFormField(
                        controller: _titeController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            labelText: "Title",
                            hintText: "Title"),
                      ),
                      TextFormField(
                        validator: formvalidator,
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: "Description",
                          labelText: "Description",
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context as BuildContext);
                              },
                              child: Text("Exit")),
                          ElevatedButton(
                              onPressed: () async {
                                if (forkey.currentState!.validate()) {
                                  if (id == null) {
                                    await addItem();
                                  }
                                  if (id != null) {
                                    await updateItem(id);
                                  }

                                  setState(() {
                                    _titeController.text = "";
                                    _descriptionController.text = "";
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              child:
                                  Text(id == null ? 'Cretae new ' : 'Update '))
                        ],
                      )
                    ],
                  )),
            ));
    String? formvalidator(String? value) {
      if (value!.isEmpty) return 'Field Required';
      return null;
    }

    Future<void> addItem() async {
      await DatabaseHelper.createItem(
          _titeController.text, _descriptionController.text);
      _refreshData();
    }

    Future<void> updateItem(int id) async {
      await DatabaseHelper.updateItem(
          id, _titeController.text, _descriptionController.text);
      _refreshData();
    }

    void deleteItem(int id) async {
      await DatabaseHelper.deletItems(id);
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text("Delted"),
          backgroundColor: Colors.black,
        ),
      );
      _refreshData();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("DataBase Crud "),
          ),
        ),
        body: _isloading
            ? Center(
                child: Text("Please enter come content"),
              )
            : ListView.builder(
                itemCount: mydata.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: index % 2 == 0 ? Colors.red : Colors.blueGrey[500],
                    margin: EdgeInsets.all(15),
                    child: ListTile(
                      title: Text(mydata[index]['title']),
                      subtitle: Text(mydata[index]['description']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () =>
                                    showMyForm(mydata[index]['id']),
                                icon: Icon(Icons.edit)),
                            IconButton(
                                onPressed: () =>
                                    deleteItem(mydata[index]['id']),
                                icon: Icon(Icons.delete))
                          ],
                        ),
                      ),
                    ),
                  );
                }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showMyForm(null),
          child: Text(
            "New",
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
