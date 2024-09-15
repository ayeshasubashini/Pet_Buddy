import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_buddy/utils/colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Notification',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: secondaryColor,
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
            child: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.vaccines),
                    title: Text('Title'),
                    subtitle: Text('this is subtitle'),
                    trailing: Text('18 min ago',
                      style: TextStyle(color: CupertinoColors.inactiveGray),),
                  ),
                );
              },
            )

        ),
      ),
    );
  }
}
