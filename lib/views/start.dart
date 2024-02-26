import 'package:flutter/material.dart';
import 'package:Skynet/navigation/app_navigation.dart';



class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Skynet',
      debugShowCheckedModeBanner: false,
      routerConfig: AppNavigation.router,
    );
  }
}
