import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import '../stories/story_1.dart';
import '../views/payment/payhistory.dart';
import 'package:http/http.dart' as http;
class StoryCircle extends StatefulWidget {
  final Function function;
  final String icon; // Добавлено
  final String imageUrl; // Добавлено
  StoryCircle({required this.function,  required this.icon, required this.imageUrl});

  @override
  _StoryCircleState createState() => _StoryCircleState();
}

class _StoryCircleState extends State<StoryCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 50), // Длительность анимации
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 360,
    ).animate(_controller);
    _controller.repeat(); // Запуск анимации в цикле
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            widget.function(widget.icon, widget.imageUrl); // Используйте widget.function с передачей параметров

          },
        //  child: Transform.rotate(
           // angle: _rotationAnimation.value * (3.1415927 / 90.0), // Преобразуем градусы в радианы

              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      width: 142,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red, // Цвет границы
                          width: 1, // Ширина границы
                        ),
                        borderRadius: BorderRadius.circular(15), // Скругление углов границы
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15), // Скругление углов картинки
                        child: Image.network(
                          widget.icon, // URL изображения
                          fit: BoxFit.cover, // Масштабирование картинки для заполнения контейнера
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 30,
                    left: 10,
                    width: 135,
                    height: 100,
                    child: Container(

                      color: Colors.black.withOpacity(0.02),
                      alignment: Alignment.centerLeft,


                    ),
                  ),
                ],

            )


          // ),
        );
      },
    );
  }
}
