import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.reference().child('newUsers');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Panel')),
     body: FutureBuilder<DatabaseEvent>(
  future: _usersRef.once(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        DataSnapshot data = snapshot.data!.snapshot;
        if (data.value != null && data.value is Map<dynamic, dynamic>) {
          Map<dynamic, dynamic> usersData = data.value as Map<dynamic, dynamic>;
          List<Widget> userWidgets = [];

          usersData.forEach((key, value) {
            String? email = value['Email'];
            String? status = value['Status']; 
            if (email != null) {
           userWidgets.add(
  ListTile(
    title: Text(email),
    subtitle: Text(status ?? 'No status available'),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            acceptUser(key, value['Type']);
          },  
          child: Text('Accept'),
        ),
        SizedBox(width: 10), // Add some spacing between buttons
        ElevatedButton(
          onPressed: () {
           rejectedUser(key, value['Type']); 
          },
          child: Text('Reject'),
        ),
      ],
    ),
  ),
);  
            }
          });

          return ListView(
            children: userWidgets,
          );
        } else {
          return Text('Data is not in the expected format.');
        }
      } else {
        return Text('No data found.');
      }
    } else {
      return CircularProgressIndicator();
    }
  },
),
    );
  }
void acceptUser(String? userId, String? userType) {
  if (userId == null || userType == null) {
    print("User ID or User Type is null.");
    return;
  }

  DatabaseReference newUsersRef = FirebaseDatabase.instance.reference().child('newUsers');
  newUsersRef.child(userId).update({'Status': 'Active'}).then((_) {
    DatabaseReference? destinationRef;
    if (userType == 'Sponsor') {
      destinationRef = FirebaseDatabase.instance.reference().child('Sponsors');
    } else if (userType == 'Sponsee') {
      destinationRef = FirebaseDatabase.instance.reference().child('Sponsees');
    }

    newUsersRef.child(userId).once().then((DatabaseEvent event) {
      DataSnapshot userData = event.snapshot;
      Map<dynamic, dynamic>? userMap = userData.value as Map<dynamic, dynamic>?;
      if (userMap != null) {
        destinationRef?.child(userId).set(userMap).then((_) {
          newUsersRef.child(userId).remove();
        });
      }
    }).catchError((error) {
      print("Error fetching user data: $error");
      // Handle the error appropriately
    });
  });
}




void rejectedUser(String userId, String userType) {
  if (userId == null || userType == null) {
    print("User ID or User Type is null.");
    return;
  }

  DatabaseReference newUsersRef = FirebaseDatabase.instance.reference().child('newUsers');
  newUsersRef.child(userId).update({'Status': 'Inactive'}).then((_) {
    DatabaseReference? destinationRef;
    if (userType == 'Sponsor') {
      destinationRef = FirebaseDatabase.instance.reference().child('rejectedSponsors');
    } else if (userType == 'Sponsee') {
      destinationRef = FirebaseDatabase.instance.reference().child('rejectedSponsees');
    }

    newUsersRef.child(userId).once().then((DatabaseEvent event) {
      DataSnapshot userData = event.snapshot;
      Map<dynamic, dynamic>? userMap = userData.value as Map<dynamic, dynamic>?;
      if (userMap != null) {
        destinationRef?.child(userId).set(userMap).then((_) {
          newUsersRef.child(userId).remove();
        });
      }
    }).catchError((error) {
      print("Error fetching user data: $error");
      // Handle the error appropriately
    });
  });
}

}

