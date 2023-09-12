import 'package:flutter/material.dart';
import 'package:sponsite/widgets/sponsee_bottom_navbar.dart';

class SponseeChat extends StatelessWidget {
  const SponseeChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
       body: Center(child: Text('No chats yet')),
      //  bottomNavigationBar: SponseeBottomNavBar(),
    );
  }
}
