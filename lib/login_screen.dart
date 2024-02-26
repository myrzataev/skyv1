import 'dart:async';
import 'dart:convert';
import 'package:Skynet/views/payment/payhistory.dart';
import 'package:Skynet/views/start.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final storage = FlutterSecureStorage();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false; // Для индикатора загрузки

  @override
  void initState() {
    super.initState();
  }

  Future<void> login(String username, String password) async {
    setState(() {
      isLoading = true; // Показываем индикатор загрузки
    });

    // Получаем токен для Firebase Messaging
    String? firebaseToken = await FirebaseMessaging.instance.getToken();
    await storage.write(key: 'firebase_token', value: firebaseToken);

    // Определяем URI для запроса
    final Uri uri = Uri.parse('http://91.210.169.237:8001/login_verify/');
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final body = {
      'ls_abonent': username,
      'phone_number': password,
      'firebase_token': firebaseToken ?? '',
      'version': "mobile"
    };


    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        await storage.write(key: 'sms_token', value: data['sms_token'].toString());
        await storage.write(key: 'token', value: data['token'].toString());
        await storage.write(key: 'username', value: username);
        await storage.write(key: 'password', value: password);

        // Переход на экран ввода SMS-кода
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SmsCodeScreen()));
      } else if (response.statusCode == 402) {
        setState(() {
          isLoading = false; // Показываем индикатор загрузки
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Указанный лицевой счет не найдет')),
        );
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false; // Показываем индикатор загрузки
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Лицевой счет с указанным номером не найден')),
        );
      } else {
        setState(() {
          isLoading = false; // Показываем индикатор загрузки
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Неверно указаны данные для входа')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Ошибка  входа"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Добавление изображения (необходимо заменить на свой путь к изображению)
              Image.asset(
                'images/assets/cat.png',
                width: 223,
                height: 248,
              ),
              SizedBox(height: 20),
              Text(
                "Вход",
                style: TextStyle(
                  fontFamily: "Gotham",
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff000000),
                  height: 38 / 32,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "Личный кабинет",
                style: TextStyle(
                  fontFamily: "Gotham",
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff808080),
                  height: 24 / 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: usernameController,
                style: TextStyle(
                  fontFamily: "Gotham",
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff808080),
                  height: 24 / 20,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(9)],
                decoration: InputDecoration(
                  labelText: 'Лицевой счет',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: Icon(Icons.account_box, color: Colors.pink),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                style: TextStyle(
                  fontFamily: "Gotham",
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff808080),
                  height: 24 / 20,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(9)],
                decoration: InputDecoration(
                  labelText: 'Номер телефона',
                  hintText: 'Введите без 0 и 996',
                  hintStyle: TextStyle(color: Colors.black45),
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: Icon(Icons.phone, color: Colors.pinkAccent),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (!isLoading) {
                    await login(usernameController.text, passwordController.text);
                  }
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(400, 50)),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(width: 1, color: Colors.pinkAccent),
                    ),
                  ),
                ),
                child: isLoading
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Войти",
                      style: TextStyle(
                        fontFamily: "Gotham",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff000000),
                        height: 17 / 14,
                      ),
                    ),
                    SizedBox(width: 10),

               LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.pinkAccent,
                      size: 30,
                    ),

                  ],
                )
                    : Text(
                  "Войти",
                  style: TextStyle(
                    fontFamily: "Gotham",
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff000000),
                    height: 17 / 14,
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

// Этот экран должен быть создан для ввода SMS-кода

class SmsCodeScreen extends StatefulWidget {
  const SmsCodeScreen({Key? key}) : super(key: key);

  @override
  State<SmsCodeScreen> createState() => _SmsCodeScreenState();
}

class _SmsCodeScreenState extends State<SmsCodeScreen> {
  List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());





  Future<void> sms( String code) async {

    final smstoken = await storage.read(key: 'sms_token');
    print(smstoken);
   print(code);
    // Определяем URI для запроса
    final Uri uri = Uri.parse('http://91.210.169.237:8001/sms_verify/');
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final body = {
      'sms_token':smstoken,
      'code': code,

    };

    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await storage.write(key: 'token', value: data['token'].toString());


        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Start()),
        );


      } else if (response.statusCode == 402) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Указанный лицевой счет не найдет')),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Лицевой счет с указанным номером не найден')),
        );
      } else {
        final data = json.decode(response.body);
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Неверно указаны данные для входа')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Ошибка  входа"),
        ),
      );
    }
  }
  String getEnteredCode() {
    return _controllers.map((controller) => controller.text).join();
  }


  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {

    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Widget _buildCodeInputField({required TextEditingController controller}) {
    return Container(
      width: 60,
      child: TextFormField(
        controller: controller,
        autofocus: true,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 24),
        decoration: InputDecoration(
          counterText: "", // Hide the counter text
          border: OutlineInputBorder(),
          // Add more decoration as needed
        ),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Настройки вашего AppBar
      ),
      backgroundColor: Colors.white, // Установка белого фона для Scaffold

      body: Container(

        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('images/assets/cat.png'), // Укажите путь к изображению
        //
        //    fit: BoxFit.scaleDown, // Заполнение всего доступного пространства
        //   ),
        //
        // ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Введите код из СМС', style: TextStyle(fontSize: 22, color: Colors.white)), // Измените цвет текста, если нужно
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _controllers.map((c) => _buildCodeInputField(controller: c)).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String code = getEnteredCode();
                  sms(code); // Вызов функции с передачей собранного кода
                },
                child: Text('Подтвердить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}