import 'package:flutter/material.dart';

import 'package:sponsite/widgets/sponsor_botton_navbar.dart';

class SponsorChat extends StatelessWidget {
  const SponsorChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
       body: Center(child: Text('No chats yet')),
      // bottomNavigationBar: SponsorBottomNavBar(),
    );
  }
}
