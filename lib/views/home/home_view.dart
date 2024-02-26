import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:Skynet/util/story_circles.dart';
import 'package:Skynet/views/home/storypage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:async/async.dart';
import 'package:permission_handler/permission_handler.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}


class CopyTextButton extends StatelessWidget {
  final String textToCopy;
  const CopyTextButton({
    Key? key,
    required this.textToCopy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: textToCopy));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Лицевой счет скопирован')),
        );
      },
    );
  }
}

class _HomeViewState extends State<HomeView> {

  FlutterLocalNotificationsPlugin localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool isLoading = false;
// Создаем список для хранения информации о пользователе
  List<dynamic> newsList = [];
  List<dynamic> personalNewsList = [];
  Map<String, dynamic> balanceData = {}; // Add this line to hold

  Future<void> _fetchBalanceData() async {

    try {
      var data = await _balance();
      setState(() {
        balanceData = data; // Store the fetched data in the state variable
      });
    } catch (e) {
      // Handle exceptions
      print('Error fetching balance data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPersonalNewsAndDisplay();

    fetchNews();

    _fetchBalanceData();

    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
    var androidInitialize = new AndroidInitializationSettings('app_icon'); // Replace 'app_icon' with your icon's file name
    var iOSInitialize = new IOSInitializationSettings();
    var initializationsSettings =
    new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    localNotificationsPlugin.initialize(initializationsSettings);
    _showNotification();
  }


  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "channelId", "Local Notifications", "This is the description of the Notification, you can write anything",
        importance: Importance.high);
    var iOSDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
    new NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await localNotificationsPlugin.show(0, "Notification Title", "The body of the Notification", generalNotificationDetails);
  }
  void fetchPersonalNewsAndDisplay() async {
    await fetchPersonalNews(); // Получение личных новостей
    if (personalNewsList.isNotEmpty) { // Проверка наличия новостных элементов
      var firstNewsItem = personalNewsList[0]; // Получение первого элемента новостей
      _openFullscreenNews(firstNewsItem); // Открытие его на весь экран
    }
  }
  void _openFullscreenNews(dynamic newsItem) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7), // Задний фон полупрозрачный
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10), // Увеличение размера модального окна
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 2), // Ограничение по высоте
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Заголовок новости
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      newsItem['title'] ?? 'Заголовок неизвестен',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0), // Радиус скругления
                      child: Image.network(newsItem['image']),
                    ),
                  ),
                  // Текст новости
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      newsItem['text'] ?? 'Текст отсутствует',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  // Кнопка закрытия
                  TextButton(
                    child: Text('Закрыть'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  final storage = FlutterSecureStorage();
  Future<void> fetchNews() async {

    setState(() {
      isLoading = true;
    });

    final token = await storage.read(key: 'token');

    final Uri uri = Uri.parse('http://91.210.169.237:8001/news/api/stories-post/list/');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    try {
      final http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        setState(() async {
          final utf8Decoder = Utf8Decoder();
          final responseBody = utf8Decoder.convert(response.bodyBytes);
          newsList = jsonDecode(responseBody);
          print(newsList);
          final fbtoken = await storage.read(key: 'fbtoken');
          print(fbtoken);
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
  Future<void> fetchPersonalNews() async {
    setState(() {
      isLoading = true;
    });
    try {
      final token = await storage.read(key: 'token');
      final ip = await storage.read(key: 'ip_address');
      print(ip);
      print(token);


      final Uri uri = Uri.parse('http://91.210.169.237:8001/news/api/loc-post/list/?ip=$ip');

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
  Future<Map<String, dynamic>> _balance() async {

    final token = await storage.read(key: 'token');
    final username = await storage.read(key: 'username');
    try {
      final Uri uri = Uri.parse('http://91.210.169.237:8001/balance/');
      final Map<String, String> headers = {'Content-Type': 'application/x-www-form-urlencoded','Authorization':'Token $token'};
      print(token);
      final Map<String, String> body = {'ls_abonent': '$username' };
      final response = await http.post(uri, headers: headers,body:body);


      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        await storage.write(key: 'ip_address', value: data['ip_address'].toString());

        return data ; // Возвращаем полученные данные
      } else {
        throw Exception('Failed to load user info'); // Бросаем исключение в случае ошибки
      }
    } catch (e) {
      throw Exception('Failed to load user info'); // Бросаем исключение в случае ошибки
    }
  }
  Future<Map<String, dynamic>> _credits() async {

    final token = await storage.read(key: 'token');
    final username = await storage.read(key: 'username');
    print(username);


    final Uri uri = Uri.parse('http://91.210.169.237:8001/credit/');
    final Map<String, String> headers = {'Content-Type': 'application/x-www-form-urlencoded','Authorization':'Token $token'};
    final Map<String, String> body = {'ls_abonent': '$username' };
    final response = await http.post(uri, headers: headers,body:body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 4),
          content: Text("Доверительный платеж выдан успешно"),
        ),
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      print(data);
      return data ; // Возвращаем полученные данные
    } else if (response.statusCode == 405) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 4),
          content: Text("Доверительный  платеж доступен с 1 по 5 число  каждого месяца"),
        ),
      );
      throw Exception('Failed to load user info!!!'); // Бросаем исключение в случае ошибки
    }
    else {
      throw Exception('Failed to load user info'); // Бросаем исключение в случае ошибки
    }

  }
  void _openStory(BuildContext context, String icon, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryPage(icon: icon, imageUrl: imageUrl, ),
      ),
    );
  }

  @override
  void dispose() {

    _fetchBalanceData();
    fetchPersonalNews();

    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await _fetchBalanceData();

    await fetchNews();
    // You can add more refresh logic here if needed.

    setState(() {
      // Update your state if necessary
    });
  }
  @override
  Widget build(BuildContext context) {


    DateTime now = DateTime.now();
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int daysLeft = daysInMonth - now.day;
    double progress = daysLeft / daysInMonth;


    String getDayWord(int days) {
      if (days % 10 == 1 && days % 100 != 11) {
        return 'день';
      } else if ((days % 10 == 2 || days % 10 == 3 || days % 10 == 4) &&
          (days % 100 < 10 || days % 100 >= 20)) {
        return 'дня';
      } else {
        return 'дней';
      }
    }





    final name = (balanceData['name'] ?? '..') ?? 'Имя отсутствует';
    final address = (balanceData['address'] ?? '..') ?? 'Адрес отсутствует';


    final balance = double.tryParse(balanceData['balance'] ?? '0') ?? 0;
    final payment = (balanceData['vc_rem'] ?? '') ?? 0;
    final payment_sum  = (balanceData['n_sum'] ?? '') ?? 0;
    final credit = balanceData['credit'];

    final services = balanceData['services'] ?? [];

    final crdate = credit != null && credit['d_end'] != null ? credit['d_end'] : '';
    DateTime? dateTime = DateTime.tryParse(crdate);
    String date = '';
    String time = '';
    if (dateTime != null) {
      date = '${dateTime.year}-${dateTime.month}-${dateTime.day}';
      time = '${dateTime.hour+6}:${dateTime.minute}:${dateTime.second}';
    }
    final crdtend = date + ' ' + time;

    Color textColor = Colors.black; // Цвет текста по умолчанию
    if (balance < 0) {

      textColor = Colors.red; // Красный цвет для отрицательного баланса
    } else if (balance > 0) {
      textColor = Colors.green; // Зеленый цвет для положительного баланса
    }


    final ls_abonent = balanceData['ls'] ?? '';
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70), // Установка высоты AppBar
        child: AppBar(
          centerTitle: false,
          title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$name\n',
                        style: TextStyle(fontSize: 22.0, color: Colors.black, fontFamily: 'Gotham'),
                      ),
                      TextSpan(
                        text: '$address',
                        style: TextStyle(fontSize: 14.0, color: Colors.black45, fontFamily: 'Gotham'),
                      ),
                    ],
                  ),
                ),

          backgroundColor: Colors.white, // Цвет фона AppBar


          actions: [
            Badge(
              alignment: AlignmentDirectional.center,
              backgroundColor: Colors.red,
              label: Text('..'),
              child: IconButton(
                icon: Icon(Icons.notifications),
                color: Colors.black45,
                onPressed: () {

                },
              ),
            )
          ],
        ),
      ),
      body:RefreshIndicator(
        onRefresh: _handleRefresh,
        child:SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Важно для активации RefreshIndicator

          child:
        Column(

          children: [

            SizedBox(
              height: 110,
              child: ListView.builder(
                itemCount: newsList.length,

                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {


                  return StoryCircle(
                    function: (icon, imageUrl) {
                      _openStory(context, icon, imageUrl);
                    },
                    icon: newsList[index]['icon'],
                  imageUrl: newsList[index]['image'], // Передаем URL изображения
                  );

                },
              ),
            ),

            Container(

              alignment: Alignment.center,
              padding: const EdgeInsets.all(5),
              margin: new EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
                // gradient: LinearGradient(
                //   colors: [Colors.pinkAccent, Colors.red,Color.fromRGBO(221, 8, 122,2)],
                //   //colors: [Colors.pinkAccent, Colors.red,Color.fromRGBO(221, 8, 122,2)],
                // ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 50,
                    offset: Offset(0, 20), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                      Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 10.0, left: 25), // Отступ справа для первого текста
                                child: Text(
                                  'Лицевой счет:',
                                  style: TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'Gotham', fontWeight: FontWeight.w100),
                                  textScaler: TextScaler.noScaling,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10.0, right: 25), // Отступ слева для второго текста
                                child: Text(
                                  'Баланс:',
                                  style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'Gotham', fontWeight: FontWeight.w100),
                                  textScaler: TextScaler.noScaling,
                                ),
                              ),
                            ],
                          ),




                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Padding(
                              padding: EdgeInsets.only(left: 6.0), // Здесь задаётся величина внешнего отступа для Card
                              child: Card(
                                color: Colors.white, // Здесь можно указать любой цвет
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10), // Устанавливаем скругление углов радиусом 20
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 15.0), // Уменьшаем вертикальные отступы
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          ls_abonent,
                                          style: TextStyle(fontSize: 20, fontFamily: 'Gotham'),
                                          // Обратите внимание, что textScaler: TextScaler.noScaling может вызвать ошибку, если это не часть вашего кастомного Text виджета
                                        ),
                                        // Предполагается, что CopyTextButton — это ваш кастомный виджет для копирования текста
                                        CopyTextButton(textToCopy: ls_abonent),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),




                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                Padding(
                                  padding: EdgeInsets.only(right: 6.0),
                                  child: Card(
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        context.goNamed("payhistory");
                                      },
                                      child: Container(

                                        decoration: BoxDecoration(
                                          color: Colors.white, // Устанавливаем белый цвет фона
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '$balance с.',
                                            style: TextStyle(
                                              fontSize: 18 ,
                                              color: textColor,
                                              fontFamily: 'Gotham',
                                              fontWeight: FontWeight.w100,
                                            ),
                                            textScaler: TextScaler.noScaling,

                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                ),


                              ],
                            ),




                          ],
                        ),



                       Container(
                         margin: EdgeInsets.symmetric(horizontal: 10.0), // Добавляем горизонтальные внешние отступы

                            // Растягиваем контейнер на всю доступную ширину
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal:20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Состояние счета:\n' ,
                                    style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Gotham'),
                                    textScaler: TextScaler.noScaling,
                                  ),
                                  Text(
                                     payment + ": " + payment_sum,
                                    style: TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Gotham'),
                                    textScaler: TextScaler.noScaling,
                                  ),
                                  // Другие текстовые блоки...
                                ],
                              ),
                            ),

                        ),










                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 100.0,
                                margin: const EdgeInsets.all(0.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          insetPadding: EdgeInsets.zero,
                                          contentPadding: EdgeInsets.zero,
                                          content: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'images/assets/credits.png',
                                                  width: 600.0,
                                                  height: 300.0,
                                                  fit: BoxFit.cover,
                                                ),
                                                if (balance < 0 && (credit == null || credit['n_sum'] == null))
                                                Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: <Widget>[
                                                      Text(
                                                        'Если у Вас закончились деньги на лицевом счете, а возможности срочно пополнить баланс нет, воспользуйтесь услугой\n Доверительный платеж.',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontFamily: 'Gotham',
                                                        ),
                                                        textScaler: TextScaler.noScaling,
                                                      ),
                                                      Divider(color: Colors.black12,), // Разделитель
                                                      Text(
                                                        'Размер Доверительного платежа равен сумме абонентской платы по тарифу и дополнительных услуг.',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontFamily: 'Gotham',
                                                        ),
                                                        textScaler: TextScaler.noScaling,
                                                      ),
                                                      Divider(color: Colors.black12,), // Разделитель
                                                      Text(
                                                        'Услуга предоставляется на 4 дня. С 1-5 число каждого месяца',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontFamily: 'Gotham',
                                                        ),
                                                        textScaler: TextScaler.noScaling,
                                                      ),
                                                      Divider(), // Разделитель
                                                      Text(
                                                        'Активируя Обещанный платеж, Вы гарантируете оплату услуг за текущий месяц в полном объеме.',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontFamily: 'Gotham',
                                                        ),
                                                        textScaler: TextScaler.noScaling,
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                SizedBox(),
                                                FutureBuilder<Map<String, dynamic>>(
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return CircularProgressIndicator();
                                                    } else if (snapshot.hasError) {
                                                      return Text('Error');
                                                    } else {

                                                    

                                                      if (balance < 0 && (credit == null || credit['n_sum'] == null)) {
                                                        return               ElevatedButton(
                                                          onPressed: () async {
                                                            _credits();
                                                            Navigator.of(context).pop();
                                                          },
                                                          style: ButtonStyle(
                                                            minimumSize: MaterialStateProperty.all(Size(300, 50)),
                                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(15.0), // Здесь можно изменить радиус кнопки
                                                                side: BorderSide(width: 1, color: Colors.pinkAccent), // Установка параметров границы
                                                              ),
                                                            ),
                                                          ),

                                                          child: Text(
                                                            "Активировать",
                                                            style: const TextStyle(
                                                              fontFamily: "Gotham",
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.w500,
                                                              color: Color(0xff000000),
                                                              height: 17 / 14,
                                                            ),
                                                            textScaler: TextScaler.noScaling,
                                                            textAlign: TextAlign.center,
                                                          ),

                                                        );

                                                    } else {
                                                        return

                                                          Card(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0), // Добавляем отступы внутри Card
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.center, // Выровнять иконку и текст по верхнему краю
                                                                children: <Widget>[

                                                                  SizedBox(width: 8), // Добавить небольшое пространство между иконкой и текстом
                                                                  Expanded(
                                                                    child: RichText(
                                                                      text: TextSpan(
                                                                        style: TextStyle(fontSize: 20, color: Colors.black), // Базовый стиль для всего текста
                                                                        children: <TextSpan>[
                                                                          TextSpan(
                                                                            text: 'Ваш баланс:\n',
                                                                            style: TextStyle(fontWeight: FontWeight.bold,),

                                                                          ),
                                                                          TextSpan(
                                                                            text: '$balance\n',
                                                                            style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red),
                                                                          ),
                                                                          TextSpan(
                                                                            text: balance >= 0
                                                                                ? 'У вас положительный баланс,\nдоверительный платеж не доступен'
                                                                                : 'Вам выдан доверительный платеж на сумму: ${credit['n_sum']}, \nДата истечения: $crdtend',
                                                                            style: TextStyle(color: Colors.grey),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );


                                                      }

                                                    }
                                                  }, future: null,
                                                ),
                                                SizedBox(height: 20),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                  },
                                                  style: ButtonStyle(
                                                    minimumSize: MaterialStateProperty.all(Size(300, 50)),
                                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15.0), // Здесь можно изменить радиус кнопки
                                                        side: BorderSide(width: 1, color: Colors.pinkAccent), // Установка параметров границы
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Отмена",
                                                    style: const TextStyle(
                                                      fontFamily: "Gotham",
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xff000000),
                                                      height: 17 / 14,
                                                    ),
                                                    textScaler: TextScaler.noScaling,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },




                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(80.0),
                                    ),
                                    padding: EdgeInsets.all(0.0),
                                  ),
                                  child: Ink(
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(width: 1, color: Color(0xFFFD4417)),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Container(
                                      constraints: BoxConstraints(maxWidth: 150.0, minHeight: 80.0),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Image.asset(
                                              'images/assets/3.png', // Укажите путь к вашему изображению
                                              width: 30.0,
                                              height: 30.0,
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Доверительный\nплатеж",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 14.0, color: Colors.black, fontFamily: 'Gotham'),
                                                textScaler: TextScaler.noScaling,
                                              ),

                                              Text.rich(
                                                TextSpan(
                                                  children: [

                                                    if (balance < 0 )
                                                      TextSpan(
                                                        text: 'Доступно на 3 дня',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.black45,
                                                          fontFamily: 'Gotham',
                                                        ),

                                                      ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),


                                  ),
                                ),
                              ),



                              const SizedBox(
                                height: 10,

                              ),
                              Container(
                                height: 100.0,
                                margin: const EdgeInsets.all(5.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.goNamed("chat");
                                  }, // Замените на ваш собственный виджет для страницы оплаты},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    padding: EdgeInsets.all(0.0),
                                  ),
                                  child: Ink(
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(width: 1, color: Color(0xFFFD4417)),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Container(
                                      constraints: BoxConstraints(maxWidth: 150.0, minHeight: 80.0),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Image.asset(
                                              'images/assets/2.png', // Укажите путь к вашему изображению
                                              width: 30.0,
                                              height: 30.0,
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Служба тех.\nподдержки",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 14.0, color: Colors.black, fontFamily: 'Gotham'),
                                                textScaler: TextScaler.noScaling,
                                              ),

                                              Text(
                                                "Онлайн 24/7",
                                                style: TextStyle(fontSize: 10.0, color: Colors.grey, fontFamily: 'Gotham'),
                                                textScaler: TextScaler.noScaling,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                  ),
                                ),
                              ),




                            ]),






                        Container(
                          height: 70.0,
                          child: ElevatedButton(
                            onPressed: () {

                              print('test');
                              context.goNamed("payment");

                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: EdgeInsets.all(0.0),
                            ),
                            child: Ink(
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(width: 1, color: Color(0xFFFD4417)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 3000.0, minHeight: 80.0),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Image.asset(
                                        'images/assets/wallet.png', // Укажите путь к вашему изображению
                                        width: 24.0,
                                        height: 24.0,

                                      ),
                                    ),

                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Оплатить за интерент",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16.0, color: Colors.black, fontFamily: 'Gotham'),
                                          textScaler: TextScaler.noScaling,
                                        ),
                                        SizedBox(height: 2.0),
                                        Text(
                                          "Онлайн перевод",
                                          style: TextStyle(fontSize: 12.0, color: Colors.grey, fontFamily: 'Gotham'),
                                          textScaler: TextScaler.noScaling,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          margin: const EdgeInsets.all(5.0),
                        ),





                      ],
                    ),

            ),
            SizedBox(
              height: 20,

            ),
            Text(
              'Подключенные услуги',
              style: TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'Gotham'),
              textScaler: TextScaler.noScaling,


            ),
            SizedBox(
              height: 10,

            ),

        SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: services.map<Widget>((service) {
                          var tariff = service[0]; // Тариф
                          var serviceDescription = service.length > 1 ? service[1] : 'Тариф'; // Описание услуги
                          var price = service[2] ;
                          var trafik = service[3] ;
                          bool showInactiveMessage = true; // По умолчанию показываем сообщение

                          IconData serviceIcon;
                          Color serviceIconColor;
                          Widget paymentInfoWidget;
                          paymentInfoWidget = Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Услуга будет неактивна через $daysLeft ${getDayWord(daysLeft)}',
                                style: TextStyle(fontSize: 14),
                                textScaler: TextScaler.noScaling,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                ),
                              ),
                            ],
                          );
                          // Установка иконки и цвета в зависимости от тарифа
                          if (tariff == 'Телевидение') {
                            serviceIcon = Icons.tv;
                            serviceIconColor = Colors.green;
                            tariff = 'SuperTV: $tariff ($price c.)';
                          }
                          else if (tariff == 'ТВ Нооруз') {
                            serviceIcon = Icons.tv;
                            serviceIconColor = Colors.green;
                            tariff = 'Услуга: SuperTV ($price c.)';}
                          else if (tariff == 'Реальный IP') {
                            serviceIcon = Icons.router;
                            serviceIconColor = Colors.green;
                            tariff = 'Услуга: $tariff ($price c.)';
                          } else if (tariff == 'Интернет-трафик исх.') {
                            serviceIcon = Icons.output;
                            serviceIconColor = Colors.green;
                            tariff = 'Исходящий  трафик\nИспользовано: $trafik Мб';
                            showInactiveMessage = false;
                            serviceDescription='';

                          } else if (tariff == 'Интернет-трафик вх.') {
                            serviceIcon = Icons.input;
                            serviceIconColor = Colors.green;
                            tariff = 'Входящий  трафик\nИспользовано: $trafik Мб';
                            showInactiveMessage = false;
                            serviceDescription='';

                          }
                          else if (tariff == 'Доступ в Интернет') {
                            serviceIcon = Icons.network_check;
                            serviceIconColor = Colors.green;
                          } else {
                            serviceIcon = Icons.router;
                            serviceIconColor = Colors.green; // Цвет для неизвестных услуг
                            tariff = 'Тариф: $tariff ($price c.)';
                          }

                          if (serviceDescription.contains('Услуга оказывается в ограниченном режиме' )) {
                            serviceIconColor = Colors.red; // Покрасить в красный цвет
                            serviceIcon = Icons.error; // Использовать иконку ошибки для неактивной услуги

                            serviceDescription = 'Неактивная';
                            paymentInfoWidget = Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Нет оплаты за  услугу',
                                  style: TextStyle(fontSize: 14),
                                  textScaler: TextScaler.noScaling,
                                ),
                              ],
                            );
                          }

                          else {
                            // Активная услуга
                            paymentInfoWidget = Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (showInactiveMessage) // Используем переменную для условия отображения обоих виджетов
                                  Column(
                                    children: [
                                      Text(
                                        'Услуга будет неактивна через $daysLeft ${getDayWord(daysLeft)}',
                                        style: TextStyle(fontSize: 14),
                                        textScaler: TextScaler.noScaling,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.grey,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            );

                          }

                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 50,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      serviceIcon,
                                      color: serviceIconColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ' $tariff ',
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.black,
                                            fontFamily: 'Gotham',
                                          ),
                                          textScaler: TextScaler.noScaling,
                                        ),
                                        Text(
                                          serviceDescription,
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: serviceIconColor,
                                            fontFamily: 'Gotham',
                                          ),
                                          textScaler: TextScaler.noScaling,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                paymentInfoWidget,
                                const SizedBox(height: 10),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),








          ],

        ),
      ),
    ),
    );
  }
}



class NotificationPermissionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('Enable Notifications'),
      onPressed: () async {
        var status = await Permission.notification.status;
        if (status.isGranted) {
          // Notifications already granted
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Notification permission is already granted."),
          ));
        } else if (status.isDenied) {
          // Directly request the permission
          await Permission.notification.request();
        } else if (status.isPermanentlyDenied) {
          // The user opted not to allow notifications. Open app settings.
          openAppSettings();
        }
      },
    );
  }
}
