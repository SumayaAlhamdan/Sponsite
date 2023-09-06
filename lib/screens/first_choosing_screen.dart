// import 'package:flutter/material.dart';
// import 'package:sponsite/screens/auth_screen.dart';
// class FirstChoosingScreen extends StatelessWidget {
//   const FirstChoosingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Sponsite Start Page"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text("Welcome to Sponsite!"),
//             Text("Which are you?"),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AuthScreen('Sponsors')),
//                 );
//               },
//               child: Text('Sponsor'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AuthScreen('Sponsees')),
//                 );
//               },
//               child: Text('Sponsee'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
