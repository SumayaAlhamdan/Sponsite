import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(context) {
    return Drawer(
        child: SizedBox(
      height: 90,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 50,
          ),
          DrawerHeader(
            child: ListTile(
              leading: const CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.perm_identity,
                  size: 40,
                ),
              ),
              title: const Text('KSU CPC', style: TextStyle(fontSize: 20)),
              subtitle: const Text('KSUCPC@gmail.com',
                  style: TextStyle(fontSize: 15)),
              onTap: () {
                // FirebaseAuth.instance.signOut();
              },
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          ListTile(
            leading: const Icon(
              Icons.perm_identity,
              size: 30,
            ),
            title: const Text(
              'My Account',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(
            height: 25,
          ),
          ListTile(
            leading: const Icon(
              Icons.exit_to_app,
              size: 30,
            ),
            title: const Text(
              'Sign out',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.delete,
              size: 30,
            ),
            title: const Text('Delete account', style: TextStyle(fontSize: 20)),
            onTap: () {},
          )
        ],
      ),
    ));
  }
}
