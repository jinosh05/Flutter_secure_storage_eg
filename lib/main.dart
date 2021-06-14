import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    home: Myapp(),
  ));
}

class Myapp extends StatefulWidget {
  const Myapp({Key? key}) : super(key: key);

  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  final _storage = FlutterSecureStorage();
  final _textController = TextEditingController();
  int i = 0;

  List<_Sectem> _list = [];

  @override
  void initState() {
    super.initState();
    _readAll();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  IOSOptions _getIOSOptions() => IOSOptions(
        accountName: _getAccountName(),
      );

  String? _getAccountName() =>
      _textController.text.isEmpty ? null : _textController.text;

  _readAll() async {
    final all = await _storage.readAll(
      iOptions: _getIOSOptions(),
    );
    setState(() {
      _list = all.entries.map((e) => _Sectem(e.key, e.value)).toList();
    });
  }

  _saveValue(String? value, int index) async {
    final String key = index.toString() + _randomValue();
    await _storage.write(
      key: key,
      value: value,
      iOptions: _getIOSOptions(),
    );

    _readAll();
    _textController.clear();
  }

  String _randomValue() {
    final rand = Random();
    final codeUnits = List.generate(20, (index) {
      return rand.nextInt(26) + 65;
    });

    return String.fromCharCodes(codeUnits);
  }

  _deleteAll() async {
    await _storage.deleteAll(
      iOptions: _getIOSOptions(),
    );
    _readAll();
  }

  _deleteItem(String key) async {
    await _storage.delete(
      key: key,
      iOptions: _getIOSOptions(),
    );
    _readAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secured Data'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              controller: _textController,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _saveValue(_textController.value.text, i);
                    i++;
                  },
                  child: Text('Add data')),
              ElevatedButton(
                  onPressed: () {
                    _deleteAll();
                  },
                  child: Text('Delete All')),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _list.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_list[index].value),
                  trailing: IconButton(
                      onPressed: () {
                        _deleteItem(_list[index].key);
                      },
                      icon: Icon(Icons.delete)),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class _Sectem {
  final String key;
  final String value;

  _Sectem(this.key, this.value);
}
