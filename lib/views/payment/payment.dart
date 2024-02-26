import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

final storage = FlutterSecureStorage();
Future<Map<String, dynamic>> _balance() async {

  final token = await storage.read(key: 'token');
  final username = await storage.read(key: 'username');

  try {
    final Uri uri = Uri.parse('http://91.210.169.237:8001/balance/');
    final Map<String, String> headers = {'Content-Type': 'application/x-www-form-urlencoded','Authorization':'Token $token'};
    final Map<String, String> body = {'ls_abonent': '$username' };
    final response = await http.post(uri, headers: headers,body:body);

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

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    Color blackColor = Colors.white;
    return Scaffold(
      backgroundColor:blackColor,
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
                text: 'Оплатить за интернет',
                style: TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'Gotham'),
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
        actions: [
          Badge(
            alignment: AlignmentDirectional.center,
            backgroundColor: Colors.red,
            label: Text('...'),
            child: IconButton(
              icon: Icon(Icons.notifications),
              color: Colors.white,
              onPressed: () {


              },
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              direction: Axis.horizontal,
              children: <Widget>[
                Container(
                  height: 100.0,
                  margin: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () async {

                      Map<String, dynamic> data = await _balance();
                      String balance = data['balance'];
// Предполагая, что balance включает знак минуса и является строковым представлением числа
// Преобразуем строку в числовой формат (double или int), чтобы убедиться, что balance является числом
                      double balanceAmount = double.parse(balance);

// Преобразуем отрицательное значение в положительное
                      double positiveBalanceAmount = balanceAmount.abs();
                      String positiveBalance = positiveBalanceAmount.toString();
                      print(positiveBalance);

                      String ls = data['ls']; // Assuming the LS key in userInfo




                    launch('https://app.mbank.kg/deeplink?service=85313047-1c13-4151-a770-b54b536f7366&account=$ls&amount=$positiveBalance');
                      //  launch('https://app.mbank.kg/deeplink?service=ad98e3c0-dd0d-4092-a77d-7275e9b116cc&PARAM1=00001&amount=10');

                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: EdgeInsets.all(0.0),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 100.0, maxHeight: 100.0),
                        alignment: Alignment.center,
                        child: Column( // Use Column to stack the image and text vertically
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/assets/mbank.webp', // Replace with your image asset path
                              width: 70, // Set the desired width
                              height: 70, // Set the desired height
                            )
                            ,// Add some spacing between the image and text

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 100.0,
                  margin: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () async {

                      Map<String, dynamic> data = await _balance();
                      String balance = data['balance'];
                      String ls = data['ls']; // Assuming the LS key in userInfo
// Предполагая, что balance включает знак минуса и является строковым представлением числа
// Преобразуем строку в числовой формат (double или int), чтобы убедиться, что balance является числом
                      double balanceAmount = double.parse(balance);

// Преобразуем отрицательное значение в положительное
                      int positiveInteger = (balanceAmount.abs() * 100).round();
                      String positiveBalance = positiveInteger.toString();
                      print(positiveBalance);


                       launch('https://o.kg/l/a?t=wl_ctl&id=9&req=$ls&sum=$positiveBalance');




                    }, // Замените на ваш собственный виджет для страницы оплаты},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      padding: EdgeInsets.all(0.0),
                      primary: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(

                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 100.0, maxHeight: 100.0),
                        alignment: Alignment.center,
                        child: Column( // Use Column to stack the image and text vertically
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/assets/omoney.png', // Replace with your image asset path
                              width: 90, // Set the desired width
                              height: 70, // Set the desired height
                            )
                            ,// Add some spacing between the image and text

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Container(
                //   height: 100.0,
                //   margin: const EdgeInsets.all(10.0),
                //   child: ElevatedButton(
                //     onPressed: () { launch('https://megapay.kg/#deeplink?serviceId=32&destination=450430641&amount=200&special=false');},
                //     style: ElevatedButton.styleFrom(
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                //       padding: EdgeInsets.all(0.0),
                //       primary: Colors.transparent,
                //     ),
                //     child: Ink(
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(15.0),
                //       ),
                //       child: Container(
                //         constraints: BoxConstraints(maxWidth: 100.0, maxHeight: 100.0),
                //         alignment: Alignment.center,
                //         child: Column( // Use Column to stack the image and text vertically
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Image.asset(
                //               'images/assets/megapay.png', // Replace with your image asset path
                //               width: 90, // Set the desired width
                //               height: 70, // Set the desired height
                //             )
                //             ,// Add some spacing between the image and text
                //
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Container(
                  height: 100.0,
                  margin: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic> data = await _balance();
                      String balance = data['balance'];
// Предполагая, что balance включает знак минуса и является строковым представлением числа
// Преобразуем строку в числовой формат (double или int), чтобы убедиться, что balance является числом
                      double balanceAmount = double.parse(balance);

// Преобразуем отрицательное значение в положительное
                      double positiveBalanceAmount = balanceAmount.abs();
                      String positiveBalance = positiveBalanceAmount.toString();
                      print(positiveBalance);
                      String ls = data['ls']; // Assuming the LS key in userInfo
                      launch('https://balance.kg/pay/skynet?amount=$positiveBalance&requisite=$ls');
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      padding: EdgeInsets.all(0.0),
                      primary: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(

                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 100.0, maxHeight: 100.0),
                        alignment: Alignment.center,
                        child: Column( // Use Column to stack the image and text vertically
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/assets/balancekg.png', // Replace with your image asset path
                              width: 140, // Set the desired width
                              height: 100, // Set the desired height
                            )
                            ,// Add some spacing between the image and text

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Container(
                //   height: 100.0,
                //   child: ElevatedButton(
                //     onPressed: () {  },
                //     style: ElevatedButton.styleFrom(
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                //       padding: EdgeInsets.all(0.0),
                //       primary: Colors.transparent,
                //     ),
                //     child: Ink(
                //       decoration: BoxDecoration(
                //
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(15.0),
                //       ),
                //       child: Container(
                //         constraints: BoxConstraints(maxWidth: 100.0, maxHeight: 100.0),
                //         alignment: Alignment.center,
                //         child: Column( // Use Column to stack the image and text vertically
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Image.asset(
                //               'images/assets/optima.png', // Replace with your image asset path
                //               width: 140, // Set the desired width
                //               height: 100, // Set the desired height
                //             )
                //             ,// Add some spacing between the image and text
                //
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                //   margin: const EdgeInsets.all(10.0),
                // ),
                // Container(
                //   height: 100.0,
                //   child: ElevatedButton(
                //     onPressed: () {  },
                //     style: ElevatedButton.styleFrom(
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                //       padding: EdgeInsets.all(0.0),
                //       primary: Colors.transparent,
                //     ),
                //     child: Ink(
                //       decoration: BoxDecoration(
                //
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(15.0),
                //       ),
                //       child: Container(
                //         constraints: BoxConstraints(maxWidth: 100.0, maxHeight: 100.0),
                //         alignment: Alignment.center,
                //         child: Column( // Use Column to stack the image and text vertically
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Image.asset(
                //               'images/assets/rskbank.png', // Replace with your image asset path
                //               width: 90, // Set the desired width
                //               height: 80, // Set the desired height
                //             )
                //             ,// Add some spacing between the image and text
                //
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                //   margin: const EdgeInsets.all(10.0),
                // ),
                // Container(
                //   height: 100.0,
                //   child: ElevatedButton(
                //     onPressed: () {  },
                //     style: ElevatedButton.styleFrom(
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                //       padding: EdgeInsets.all(0.0),
                //       primary: Colors.transparent,
                //     ),
                //     child: Ink(
                //       decoration: BoxDecoration(
                //
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(15.0),
                //       ),
                //       child: Container(
                //         constraints: BoxConstraints(maxWidth: 100.0, maxHeight: 100.0),
                //         alignment: Alignment.center,
                //         child: Column( // Use Column to stack the image and text vertically
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Image.asset(
                //               'images/assets/elsom.png', // Replace with your image asset path
                //               width: 70, // Set the desired width
                //               height: 80, // Set the desired height
                //             )
                //             ,// Add some spacing between the image and text
                //
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                //   margin: const EdgeInsets.all(10.0),
                // ),
                // Container(
                //   height: 100.0,
                //   child: ElevatedButton(
                //     onPressed: () {  },
                //     style: ElevatedButton.styleFrom(
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                //       padding: EdgeInsets.all(0.0),
                //       primary: Colors.transparent,
                //     ),
                //     child: Ink(
                //       decoration: BoxDecoration(
                //
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(15.0),
                //       ),
                //       child: Container(
                //         constraints: BoxConstraints(maxWidth: 100.0, maxHeight: 100.0),
                //         alignment: Alignment.center,
                //         child: Column( // Use Column to stack the image and text vertically
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Image.asset(
                //               'images/assets/halyk.png', // Replace with your image asset path
                //               width: 70, // Set the desired width
                //               height: 80, // Set the desired height
                //             )
                //             ,// Add some spacing between the image and text
                //
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                //   margin: const EdgeInsets.all(10.0),
                // ),
                // Container(
                //   height: 100.0,
                //   child: ElevatedButton(
                //     onPressed: () {  launch('https://bakai24.app/services/payment/54?requisite=175050620&amount=2');},
                //     style: ElevatedButton.styleFrom(
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                //       padding: EdgeInsets.all(0.0),
                //       primary: Colors.transparent,
                //     ),
                //     child: Ink(
                //       decoration: BoxDecoration(
                //
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(15.0),
                //       ),
                //       child: Container(
                //         constraints: BoxConstraints(maxWidth: 100.0, maxHeight: 100.0),
                //         alignment: Alignment.center,
                //         child: Column( // Use Column to stack the image and text vertically
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Image.asset(
                //               'images/assets/bakai.png', // Replace with your image asset path
                //               width: 70, // Set the desired width
                //               height: 80, // Set the desired height
                //             )
                //             ,// Add some spacing between the image and text
                //
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                //   margin: const EdgeInsets.all(10.0),
                // )
                // Add more Button Widgets here
              ],
            ),
          ],
        ),
      ),
    );
  }
}
