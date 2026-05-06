import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Skogsjakten/repositories/auth_repository.dart';
import 'package:Skogsjakten/services/token_storage.dart';
import 'package:Skogsjakten/services/user_local_storage.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final authRepository = AuthRepository(
    tokenStorage: TokenStorage(),
    userLocalStorage: UserLocalStorage(),
  );

  String username = '';
  String level = '';
  String profileImgUrl = '';

  List<dynamic> badges = [];

  int points = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("PROFILE INIT");
    loadAll();
  }

   Future<void> loadBadges() async{
      print("loadBadges START");
      final token = await authRepository.getToken();

      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/badges/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("TOKEN: $token");

      
      print("BADGES STATUS: ${response.statusCode}");
      print("BADGES BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          badges = data;
          print('Badges: $badges');
          if (badges.isEmpty) {
            badges = [
              {
                "name": "Testmedalj",
                "category": "FLOWER",
                "tier": "BRONZE",
                "unlockedAt": "test"
              },
              {
                "name": "Testmedalj2",
                "category": "FLOWER",
                "tier": "BRONZE",
                "unlockedAt": "test"
              },
              {
                "name": "Testmedalj3",
                "category": "FLOWER",
                "tier": "BRONZE",
                "unlockedAt": "test"
              }


            ];
          } 


        });
      } else {
        setState(() {

          isLoading = false;
        });
      }
   }

   Future<void> loadAll() async {
     print("loadAll START");
     await loadProfile();
     await loadBadges();

     setState(() {
       isLoading = false;
     });
   }

  Future<void> loadProfile() async {
    final token = await authRepository.getToken();

    final response = await http.get(
      Uri.parse('https://group-6-15.pvt.dsv.su.se/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        username = data['name'];
        points = data['totalPoints'];
        level = data['level'];
        profileImgUrl = data['profileImageUrl'];
        //isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  NetworkImage getBadgeImage(String? tier){
       return NetworkImage("https://cdn.pixabay.com/photo/2015/04/17/19/02/ko-727828_1280.jpg");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEDBB2),
        elevation: 0,
        centerTitle: true,

        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Text(
              "Profil: $username",
              /*style: TextStyle(
                color: Color(0xFF4C290C),
              )*/
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size:50, color: Color(0xFF000000)/*, color: Color(0xFF4C290C)*/),
            onPressed: () {
              print('clicked');
            },
          )
        ]
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            const SizedBox(height: 40),
            Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 120),
                  width: 350,
                  height: 170,
                  child: Card(
                    color: Color(0xFFF8ED76),
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.eco, color: Color(0xFF84C06C), size: 35,),
                                Text("Level: $level"),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 250,
                              child: LinearProgressIndicator(
                                backgroundColor: Color(0xFFDE75BF),
                                color: Color(0xFFC0008B),
                                value: (points % 300) / 300, // lägg in den korrekta beräkningen för poäng, hur gör vi så den börjar om från början för ny nivå
                                minHeight: 10,

                              ),
                            ),
                            const SizedBox(height:20),
                            Text("Poäng: $points"),

                          ]
                    ),
                    ),
                  ),
                ),
                Container(
                  width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFFC0008B),
                        width: 6,
                      ),
                  ),
                  child: CircleAvatar(
                      radius: 70,
                      backgroundImage: profileImgUrl.isNotEmpty
                        ? NetworkImage(profileImgUrl)
                        : const NetworkImage("https://cdn.pixabay.com/photo/2015/04/17/19/02/ko-727828_1280.jpg",),
                      
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Padding(
            //padding: const EdgeInsets.only(right: 260),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Medaljer", style: TextStyle(fontSize: 25)),
                IconButton(
                    onPressed: () {
                      print("Gå till medaljsida");
                      // Navigator.push(...) senare
                      },
                    icon: const Icon(Icons.arrow_forward, color: Color(0xFF000000), size: 35),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            child: badges.isEmpty
              ? const Align(
              alignment: Alignment.topCenter,
              child:
              Text("Inga medaljer ännu.\nSamla fler av en art så kanske du får en medalj!", textAlign: TextAlign.center),
            )
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: badges.length,
                separatorBuilder: (context, index) =>
                  const SizedBox(width:20),
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                          CircleAvatar(
                            radius: 42.5,
                            backgroundImage: NetworkImage("https://cdn.pixabay.com/photo/2015/04/17/19/02/ko-727828_1280.jpg"), //ska ändras när de finns bilder för medaljer
                            //ska egentligen vara en bild på medalj, när de sen lagts in
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 80,
                            child:
                              Text(badge['name'],
                              textAlign: TextAlign.center
                              ),

                          ),
                      ],
                    ),
                  );
                }
            ),
          ),
        ],
      )
    );
  }
}


