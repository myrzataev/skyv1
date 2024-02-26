import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:Skynet/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart'; // Импорт для использования launch

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}
class _SettingScreenState extends State<SettingScreen> {

  Future<String> getAppVersion() async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  final storage = FlutterSecureStorage();
  Future<void> logout() async {
    final token = await storage.read(key: 'token');
    final Uri uri = Uri.parse('http://91.210.169.237:8001/logout/');
    final Map<String, String> headers = {'Content-Type': 'application/x-www-form-urlencoded','Authorization': 'Token $token'};


    try {
      final http.Response response = await http.post(uri, headers: headers, );
      print(response.statusCode);
      if (response.statusCode == 200) {


        await storage.delete(key: 'username');
        await storage.delete(key: 'password');
        await storage.delete(key: 'firebase_token');
        await storage.delete(key: 'token');

      } else if (response.statusCode == 400) {
        // Ваш код при неверном вводе значений логина и пароля
      } else if (response.statusCode == 401) {
        // Ваш код при неверном логине или пароле
      } else {
        // Ваш код при других сценариях ошибок
      }
    } catch (e) {
      // Ваш код при ошибке запроса (например, сервер не доступен)
    }
  }



// Ваш код для состояния виджета

// Функция для очистки кэша приложения
  Future<void> clearApplicationCache() async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }
  Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Выход из приложения'),
          content: Text('В  случае выхода из приложения вам понадобится  ввести  лицевой счет и  номер  телефона  для того, чтобы зайти снова'),
          actions: <Widget>[
            TextButton(
              child: Text('Отменить'),
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
            ),
            TextButton(
              child: Text('Выйти'),
              onPressed: () async {
                await logout();
                await clearApplicationCache();
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Еще..'),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            // Меню службы поддержки клиентов
            ListTile(
              leading: Icon(Icons.headset_mic), // Иконка для службы поддержки
              title: Text('Служба поддержки клиентов', style: TextStyle(fontSize: 14.0, color: Colors.black45, fontFamily: 'Gotham'),),

              onTap: () {
                // Действия при нажатии на пункт "Служба поддержки клиентов"
                // Например, открытие экрана со списком вариантов связи

                // Открытие экрана со списком позвонить, написать, соц. сети
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactOptionsScreen(), // Ваш экран с вариантами связи
                  ),
                );
              },
            ),
            Divider(), // Горизонтальная линия-разделитель

            // Кнопка "Выйти"
            ListTile(
              leading: Icon(Icons.exit_to_app), // Иконка для кнопки "Выйти"
              title: Text('Выйти'),
              onTap: () async {

                showLogoutDialog(context); // Отобразить диалог выхода


              },
            ),

      ListTile(
        leading: Icon(Icons.verified), // Иконка для кнопки "Выйти"
        title: Text('Версия приложения'),
        trailing: FutureBuilder<String>(
          future: getAppVersion(), // Вызов функции для получения версии приложения
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Если данные загружаются, показываем индикатор загрузки или сообщение "Загрузка..."
              return CircularProgressIndicator(); // Или другой вид индикатора загрузки
            } else {
              if (snapshot.hasError) {
                // Если произошла ошибка при получении данных, отображаем сообщение об ошибке
                return Text('Ошибка получения версии: ${snapshot.error}', style: TextStyle(fontSize: 14.0, color: Colors.black45, fontFamily: 'Gotham'),);
              } else {
                // Если данные успешно получены, выводим версию приложения
                return Text(snapshot.data ?? 'Версия не найдена');
              }
            }
          },
        ),
      ),

          ],
        ),
      ),

    );
  }
}


class ContactOptionsScreen extends StatelessWidget {

  List<String> phoneNumbers = [
    '0555794444', // Здесь перечислите ваши номера телефонов
    '0500794444',
    '0774794444',// Пример добавления другого номера
    // Добавьте другие номера по аналогии
  ];

  List<String> chat = [
    'wa.me/996555794444', // Здесь перечислите ваши номера телефонов
    't.me/skynettelecom',
    '0774794444',// Пример добавления другого номера
    // Добавьте другие номера по аналогии
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Наши контакты', style: TextStyle(fontSize: 14.0, color: Colors.black45, fontFamily: 'Gotham'),),
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
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Позвонить'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Выберите номер для звонка', style: TextStyle(fontSize: 14.0, color: Colors.black45, fontFamily: 'Gotham'),),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: phoneNumbers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(phoneNumbers[index]),
                            onTap: () {
                              launch('tel:${phoneNumbers[index]}');
                              Navigator.pop(context); // Закрытие диалогового окна после выбора номера
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.message),
            title: Text('Написать'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Выберите мессенджер'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.message),
                          title: Text('WhatsApp'),
                          onTap: () {
                            launch('https://wa.me/996555794444?text=Я%20пишу%20с%20мобильного%20приложения%20Skynet');
                            Navigator.of(context).pop(); // Закрываем диалоговое окно
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.message),
                          title: Text('Telegram'),
                          onTap: () {
                            launch('https://t.me/SkynetTelecom');
                            Navigator.of(context).pop(); // Закрываем диалоговое окно
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.account_box),
            title: Text('Инстаграм'),
            onTap: () {
              launch('https://www.instagram.com/skynet_kg/'); // Замените ссылкой на инстаграм
            },
          ),
          ListTile(
            leading: Icon(Icons.open_in_browser),
            title: Text('Facebook'),
            onTap: () {
              launch('https://www.facebook.com/sntkg/'); // Замените ссылкой на Facebook
            },
          ),
          // Добавьте другие пункты меню или ссылки на социальные сети по аналогии
        ],
      ),
    );
  }
}


