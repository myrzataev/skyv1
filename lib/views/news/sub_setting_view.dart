import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../payment/payhistory.dart';


class NewsVieLoc extends StatefulWidget {
  const NewsVieLoc({Key? key}) : super(key: key);

  @override
  State<NewsVieLoc> createState() => _NewsVieLocState();
}

class _NewsVieLocState extends State<NewsVieLoc> {
  late SharedPreferences prefs;
  List<dynamic> newsList = [];
  Set<int> readNews = Set<int>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializePreferences();
    fetchNews();
  }

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    List<String>? readNewsStringList = prefs.getStringList('readNews');
    readNews = readNewsStringList?.map((idString) => int.parse(idString)).toSet() ?? Set<int>();
  }

  Future<void> fetchNews() async {

    setState(() {
      isLoading = true;
    });

    final token = await storage.read(key: 'token');
    final Uri uri = Uri.parse('http://91.210.169.237:8001/news/api/loc-pos/list/');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    try {
      final http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        setState(() {
          final utf8Decoder = Utf8Decoder();
          final responseBody = utf8Decoder.convert(response.bodyBytes);
          newsList = jsonDecode(responseBody);
          isLoading = false;
        });
      } else {
        // Обработка ошибок запроса
        print('Failed to load news: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Обработка ошибок, связанных с недоступностью сервера
      print('Error fetching news: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> markAsRead(int newsId) async {
    setState(() {
      readNews.add(newsId);
    });
    await prefs.setStringList('readNews', readNews.map((id) => id.toString()).toList());
  }

  bool isRead(int newsId) {
    return readNews.contains(newsId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новости'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[Colors.red, Colors.purple],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          DateTime publicationDate = DateTime.parse(newsList[index]['created_at']);

          return Card(
            margin: EdgeInsets.all(8.0),
            elevation: 3.0,
            child: ListTile(
              shape: isRead(newsList[index]['id'])
                  ? RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(4.0),
              )
                  : null,
              leading: SizedBox(
                width: 100,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    newsList[index]['image'],
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              title: Text(newsList[index]['title']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    newsList[index]['text'].length > 20
                        ? newsList[index]['text'].substring(0, 10) + '...'
                        : newsList[index]['text'],
                  ),
                  Divider(color: Colors.black),
                  Text(
                    'Опубликовано: ${DateFormat('HH:mm   dd.MM.yyyy').format(publicationDate)}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              tileColor: isRead(newsList[index]['id']) ? Colors.grey.withOpacity(0.3) : null,
              onTap: () {
                markAsRead(newsList[index]['id']);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailScreen(
                      news: newsList[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> news;

  NewsDetailScreen({required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(news['title']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(news['image']),
            SizedBox(height: 16.0),
            Text(
              news['title'],
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              news['text'],
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),



    );
  }
}
