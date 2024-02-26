import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:http/http.dart' as http;



class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}
final storage = FlutterSecureStorage();


class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {

  Future<Map<String, dynamic>> _tranaction() async {

    final token = await storage.read(key: 'token');
    print(token);
    final username = await storage.read(key: 'username');
    print(username);
    try {
      final Uri uri = Uri.parse('http://91.210.169.237:8001/transactions/');
      final Map<String, String> headers = {'Content-Type': 'application/x-www-form-urlencoded','Authorization':'Token $token'};
      final Map<String, String> body = {'ls_abonent': '$username' };
      final response = await http.post(uri, headers: headers,body:body);

       print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print(data);
        return data ; // Возвращаем полученные данные
      } else {
        throw Exception('Failed to load user info'); // Бросаем исключение в случае ошибки
      }
    } catch (e) {
      throw Exception('Failed to load user info'); // Бросаем исключение в случае ошибки
    }
  }

  @override
  void initState() {


    _tranaction();
    super.initState();
  }


  @override
  void dispose() {

    _tranaction();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
           leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {

        context.goNamed("Главная");
      },
    ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'История операций по счету',
                style: TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'Mazzard'),
              ),

            ],
          ),
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

      ),

      // The rest of your Scaffold's content
      body: Column(
        children: [
          // Ваши другие виджеты здесь

          FutureBuilder<Map<String, dynamic>>(
            future: _tranaction(), // Получение данных о транзакциях
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(

                  child: CircularProgressIndicator(),
                ); // Индикатор загрузки
              } else if (snapshot.hasError) {
                return Text('Ошибка: ${snapshot.error}'); // Отображение ошибки
              } else {
                final transactions = snapshot.data?['transactions'] ?? [];

                return Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final amount = transaction[0];
                      final date = (transaction[1]);
                      String dt =date as String;
                      final paymentSystem = transaction[2];
                      String formattedDate = dt.replaceAll('T', ' ').replaceAll('+06:00', '');



                      return Card(
                        child: ListTile(
                          title: Text('Сумма: $amount с.'), // Вывод суммы транзакции
                          subtitle: Text('Дата: ${formattedDate}\nСистема оплаты: $paymentSystem'), // Вывод даты и системы оплаты
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      )



    );
  }
}