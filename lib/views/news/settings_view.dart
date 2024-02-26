import 'dart:convert';

import 'package:Skynet/views/news/sub_setting_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../payment/payhistory.dart';



class NewsView extends StatefulWidget {
  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SharedPreferences prefs;
  Set<int> readNews = Set<int>();
  List<dynamic> generalNewsList = [];
  List<dynamic> personalNewsList = [];
  bool isLoading = false;

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    List<String>? readNewsStringList = prefs.getStringList('readNews');
    readNews =
        readNewsStringList?.map((idString) => int.parse(idString)).toSet() ??
            Set<int>();
  }

  @override
  void initState() {
    super.initState();
    initializePreferences();
    _tabController = TabController(length: 2, vsync: this);
    fetchNews(); // Загрузить общие новости
    fetchMyNews(); // Загрузить личные новости
  }

  Future<void> fetchData() async {
    await fetchNews(); // Загрузить общие новости
    await fetchMyNews(); // Загрузить личные новости
  }
  @override
  void dispose() {
    _tabController.dispose();
    initializePreferences();
    fetchNews(); // Загрузить общие новости
    fetchMyNews(); // Загрузить личные новости
    super.dispose();
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
    });

    final token = await storage.read(key: 'token');
    final Uri uri = Uri.parse(
        'http://91.210.169.237:8001/news/api/gen-post/list/');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    try {
      final http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          final utf8Decoder = Utf8Decoder();
          final responseBody = utf8Decoder.convert(response.bodyBytes);
          generalNewsList = jsonDecode(responseBody);
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



  Future<void> readnews(int post_id, String post_type) async {

    final token = await storage.read(key: 'token');
    String postid = post_id.toString();
    final Uri uri = Uri.parse('http://91.210.169.237:8001/news/api/hit/');
    final Map<String, String> headers = {'Content-Type': 'application/x-www-form-urlencoded','Authorization':'Token $token'};
    final Map<String, dynamic> body = {'post_id': '$postid', 'post_type': post_type };
    try {
      final http.Response response = await http.post(uri, headers: headers, body:body);

      if (response.statusCode == 200) {

      } else if (response.statusCode == 400) {

      } else if (response.statusCode == 401) {

      } else {

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Ошибка загрузки новости"),
        ),
      );
    }
  }

  Future<void> fetchMyNews() async {
    setState(() {
      isLoading = true;
    });
    try {



      final token = await storage.read(key: 'token');
      final ls = await storage.read(key: 'username');
      print(ls);
      print(token);


      final Uri uri = Uri.parse('http://91.210.169.237:8001/news/api/sin-post/list/?ls_abonent=$ls');

      final Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Token $token'
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          final utf8Decoder = Utf8Decoder();
          final responseBody = utf8Decoder.convert(response.bodyBytes);
          personalNewsList = jsonDecode(responseBody);
          print(personalNewsList);
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

  bool isRead(int newsId) {
    return readNews.contains(newsId);
  }

  Future<void> markAsRead(int newsId) async {
    setState(() {
      readNews.add(newsId);
    });
    await prefs.setStringList(
        'readNews', readNews.map((id) => id.toString()).toList());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Новости Skynet', // обновленный текст заголовка
          style: TextStyle(color: Colors.black),
        ),

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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white70, // Цвет индикатора между вкладками
          labelColor: Colors.black, // Цвет текста активной вкладки
          tabs: [
            Tab(
              child: Text(
                'Новости ',
                style: TextStyle(fontFamily: 'Gotham'), // установка fontFamily
              ),
            ),
            Tab(
              child: Text(
                'Мои новости',
                style: TextStyle(fontFamily: 'Gotham'), // установка fontFamily
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          buildNewsList(generalNewsList),
          buildNewsList(personalNewsList),
        ],
      ),
    );
  }

  Widget buildNewsList(List<dynamic> newsList) {
    return RefreshIndicator(
      onRefresh: fetchData,
      child: ListView.builder(
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          DateTime publicationDate = DateTime.parse(
              newsList[index]['created_at']);
          return Card(
            margin: EdgeInsets.all(8.0),
            elevation: 10.0,
            child: ListTile(
              shape: isRead(newsList[index]['id'])
                  ? RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(4.0),
              )
                  : null,
              leading: SizedBox(
                width: 80,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    newsList[index]['image'],
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              title: Text(
                newsList[index]['title'],
                style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold, fontFamily: 'Gotham',),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    newsList[index]['text'].length > 20
                        ? newsList[index]['text'].substring(0, 10) + '...'
                        : newsList[index]['text'],
                    style: TextStyle(color: Colors.black87),
                  ),
                  Divider(color: Colors.black),
                  Text(
                    'Опубликовано: ${DateFormat('HH:mm   dd.MM.yyyy').format(publicationDate)}',
                    style: TextStyle(color: Colors.grey, fontFamily: 'Gotham',),
                  ),
                ],
              ),
              tileColor: isRead(newsList[index]['id']) ? Colors.grey.withOpacity(0.3) : null,
              onTap: () {
                final newsType = newsList[index]['post_type']; // Получаем тип новости

                markAsRead(newsList[index]['id']);

                readnews(newsList[index]['id'], newsType);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailScreen(news: newsList[index]),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Радиус закругления углов
                child: Image.network(
                  news['image'],
                  fit: BoxFit.cover, // Масштабирование изображения для заполнения всего прямоугольника
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                news['title'],
                style: TextStyle(color: Colors.black, fontFamily: 'Gotham',fontSize: 18),
              ),
              Divider(color: Colors.grey,),
              SizedBox(height: 8.0),
              Text(
                news['text'],
                style: TextStyle(color: Colors.black45, fontFamily: 'Gotham',fontSize: 16),
              ),
              // Дополнительные виджеты, если есть...
            ],
          ),
        ),
      ),




    );
  }
}