import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
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
                text: 'Техподдержка',
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
                  child: ElevatedButton(
                    onPressed: () {   launch('https://wa.me/996555794444?text=Я%20пишу%20с%20мобильного%20приложения%20Skynet');


                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0),
                      ),
                      padding: EdgeInsets.all(0.0),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 120.0, maxHeight: 120.0),
                        alignment: Alignment.center,
                        child: Column( // Use Column to stack the image and text vertically
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/assets/wa.png', // Replace with your image asset path
                              width: 70, // Set the desired width
                              height: 70, // Set the desired height
                            )
                            ,// Add some spacing between the image and text

                          ],
                        ),
                      ),
                    ),
                  ),
                  margin: const EdgeInsets.all(10.0),
                ),
                Container(
                  height: 100.0,
                  child: ElevatedButton(
                    onPressed: () {  launch('https://t.me/SkynetTelecom');




                    }, // Замените на ваш собственный виджет для страницы оплаты},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                      padding: EdgeInsets.all(0.0),
                      primary: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(

                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 120.0, maxHeight: 120.0),
                        alignment: Alignment.center,
                        child: Column( // Use Column to stack the image and text vertically
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/assets/tg.png', // Replace with your image asset path
                              width: 90, // Set the desired width
                              height: 90, // Set the desired height
                            )
                            ,// Add some spacing between the image and text

                          ],
                        ),
                      ),
                    ),
                  ),
                  margin: const EdgeInsets.all(10.0),
                ),

                // Add more Button Widgets here
              ],
            ),
          ],
        ),
      ),
    );
  }
}
