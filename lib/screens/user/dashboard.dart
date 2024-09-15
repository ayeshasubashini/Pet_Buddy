import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_buddy/screens/user/my_pets_page.dart';
import 'package:pet_buddy/screens/user/vaccination.dart';
import 'package:pet_buddy/utils/colors.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> images = [
    "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp",
  ];
  String? userName;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    var box = Hive.box('loginBox');
    String userRef = box.get('uid');

    DocumentReference documentReference =
    FirebaseFirestore.instance.collection('userdetails').doc(userRef);
    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> userdata = documentSnapshot.data() as Map<String, dynamic>;
      setState(() {
        userName = userdata['user_name'];
        profileImage = userdata['profile_image']; // Add this line
      });
    }
  }

  void navigateToMyPets() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const MyPetsPage()));
  }

  void navigateToVaccination() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const Vaccination()));
  }

  @override
  Widget build(BuildContext context) {
    // If userName or profileImage is null, show a loading indicator
    if (userName == null || profileImage == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: darkGreen,
          ),
        ),
      );
    }

    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Dashboard',
      home: Scaffold(
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                  child: Row(
                    children: [
                      const Spacer(),
                      Container(
                        child: CircleAvatar(
                          radius: 30.0,
                          backgroundImage: profileImage != null
                              ? NetworkImage(profileImage!)
                              : const NetworkImage(
                              'https://banner2.cleanpng.com/20180418/xqw/kisspng-avatar-computer-icons-business-business-woman-5ad736ba3f2735.7973320115240536902587.jpg'),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Hello ',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            userName!,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: navigateToMyPets,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: darkGreen,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.pets,
                                size: 40,
                                color: secondaryColor,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'My Pets',
                                style: TextStyle(
                                    fontSize: 20, color: secondaryColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: navigateToVaccination,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: darkGreen,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.vaccines,
                                size: 40,
                                color: secondaryColor,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'Vaccination',
                                style: TextStyle(
                                    fontSize: 20, color: secondaryColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  child: const Text(
                    "Next Vaccination Details",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: lightGrayColor,
                              borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 15),
                                  decoration: const BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: const Icon(
                                    Icons.pets,
                                    size: 40,
                                    color: darkGreen,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Animal Name',
                                        style: TextStyle(
                                            fontSize: 20, color: darkGreen),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.date_range),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: const Text(
                                              'date',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: darkGreen),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: lightGrayColor,
                              borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 15),
                                  decoration: const BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: const Icon(
                                    Icons.pets,
                                    size: 40,
                                    color: darkGreen,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Animal Name',
                                        style: TextStyle(
                                            fontSize: 20, color: darkGreen),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.date_range),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: const Text(
                                              'date',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: darkGreen),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
