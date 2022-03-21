// to interact with notion api
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'Failure.dart';
import 'item_model.dart';

class BudgetRepository {
  final http.Client _client;
  static const String _baseUrl = 'https://api.notion.com/v1/';
  // static const String _baseUrl ='https://api.notion.com/v1/databases/66dbe0151dd2410785056250bf2cb601/query';

  BudgetRepository({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Future<List<Item>> getItem() async {
    try {
      final url =
          '${_baseUrl}databases/${dotenv.env['NOTION__DATABASE_ID']}/query';

      // making post request
      final response = await _client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader:
              'Bearer ${dotenv.env['NOTION_API_KEY']}',
          'Notion-Version': '2021-05-13',
        },
      );
      print(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        print(data['results']);

        return (data['results'] as List).map((e) => Item.fromMap(e)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        throw const Failure(message: 'Something went wrong!');
      }
    } catch (e) {
      print('error caught: $e');
      throw const Failure(message: 'Something went wrong!');
    }
  }
}
