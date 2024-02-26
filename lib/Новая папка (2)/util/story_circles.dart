import 'package:flutter/material.dart';

class StoryCircle extends StatefulWidget {
  final Function function;
  final String newsTitle;
  final String imageUrl; // Добавляем поле для URL изображения

  StoryCircle({required this.function, required this.newsTitle, required this.imageUrl});


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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            widget.function();
          },
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                  child: Container(
                    width: 142,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      width: 130,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red, // Цвет границы
                          width: 1, // Ширина границы
                        ),
                        borderRadius: BorderRadius.circular(10), // Скругление углов границы
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.imageUrl, // Ссылка на изображение
                          fit: BoxFit.cover, // Режим заполнения изображения
                        ),
                      ),
                    ),

                  ),

              ),
              Positioned(
                top: 30,
                left: 10,
                width: 135,
                height: 80,
                child: Container(
                  color: Colors.black.withOpacity(0.02),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      widget.newsTitle, // Используйте переданный заголовок новости
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
