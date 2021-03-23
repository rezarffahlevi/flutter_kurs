import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reza_uts/models/item_model.dart';
import 'package:reza_uts/widgets/currency_flags.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  static const API_KEY = '42c54eefbe2ffac48b83d236f528a6cb';
  static const BASE_URL = 'data.fixer.io';
  List<ItemModel> itemList = List<ItemModel>();
  bool _isLoading = true;
  String date;
  String base;

  @override
  void initState() {
    super.initState();
    _getRates();
    _getSymbols();
  }

  void _getRates() async {
    var client = http.Client();
    try {
      _isLoading = true;
      var param = {"access_key": API_KEY};
      var uri = Uri.http(BASE_URL, '/api/latest', param);
      var uriResponse = await client.get(uri);
      var _res = json.decode(uriResponse.body.toString());
      final rates = _res['rates'];
      base = _res['base'];
      var time = DateTime.fromMillisecondsSinceEpoch(_res['timestamp'] * 1000);
      date = time.toString();

      rates.forEach((final String key, final value) {
        // print("Key: {{$key}} -> value: ${value}");
        ItemModel _item = ItemModel();
        double val = value.toDouble();
        _item.code = key;
        _item.value = val;
        itemList.add(_item);
      });

      _isLoading = false;
    } finally {
      _isLoading = false;
      client.close();
    }
  }

  void _getSymbols() async {
    var client = http.Client();
    try {
      _isLoading = true;
      var param = {"access_key": API_KEY};
      var uri = Uri.http(BASE_URL, '/api/symbols', param);
      var uriResponse = await client.get(uri);
      Map<String, dynamic> _res = json.decode(uriResponse.body.toString());

      _res['symbols'].forEach((final String key, final value) {
        var i = itemList.indexWhere((element) => element.code.contains(key));
        if (i >= 0) {
          itemList[i].name = value;
        }
      });
      setState(() {
        itemList = itemList;
      });
      _isLoading = false;
    } finally {
      _isLoading = false;
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reza UTS - KURS')),
      body: RefreshIndicator(
        onRefresh: () async {
          await _getRates();
          await _getSymbols();
          return true;
        },
        child: _isLoading
            ? Center(
                child: Text('Loading'),
              )
            : Column(
                children: [
                  Material(
                    child: InkWell(
                      onTap: null,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('Base : $base'),
                            SizedBox(
                              height: 5,
                            ),
                            Text('Last Update : $date'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: itemList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Material(
                            child: InkWell(
                              onTap: null,
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    CurrencyFlag(code: itemList[index]?.code),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            itemList[index]?.code ?? '-',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            itemList[index]?.name ?? '-',
                                            // style: context.caption,
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Row(
                                      children: <Widget>[
                                        Text(itemList[index]?.value.toString()),
                                        const SizedBox(width: 16.0),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
