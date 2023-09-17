import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:sample_app/constants/constants.dart';
import 'package:sample_app/controller/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    forCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("asset/images/blood donation png.png"))),
    );
  }

  forCheck() async {
    await Future.delayed(Duration(seconds: 3));
    if (auth.currentUser != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return SigninScreen();
        },
      ));
    }
  }
}

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});
  final cntrl = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signin"),
      ),
      body: Column(
        children: [
          BloodTextFiled("Email", cntrl.loginemail),
          BloodTextFiled("Password", cntrl.loginpassword),
          Obx(
            () => ElevatedButton(
                onPressed: () {
                  cntrl.signIn();
                },
                child: cntrl.loading.value
                    ? CircularProgressIndicator(
                        color: Colors.blue,
                      )
                    : Text("SignIn")),
          ),
          TextButton(
              onPressed: () {
                Get.to(SignUpScreen());
              },
              child: const Text("for SignUp")),
        ],
      ),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final cntrl = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SignUp"),
      ),
      body: Column(
        children: [
          BloodTextFiled("username", cntrl.username),
          BloodTextFiled("phone", cntrl.phone),
          BloodTextFiled("email", cntrl.email),
          BloodTextFiled("Password", cntrl.password),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField(
              decoration:
                  const InputDecoration(label: Text("Select your blood group")),
              items: cntrl.groups
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                cntrl.selected = value;
              },
            ),
          ),
          Obx(
            () => ElevatedButton(
                onPressed: () {
                  cntrl.signup();
                },
                child: cntrl.loading.value
                    ? CircularProgressIndicator(
                        color: Colors.blue,
                      )
                    : Text("SignUp")),
          ),
          TextButton(onPressed: () {}, child: const Text("for Signin")),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final cntrl = Get.put(AuthController());

  var auth = FirebaseAuth.instance;

  // getUser() async {
  //   QuerySnapshot<Map<String, dynamic>> snap =
  //       await FirebaseFirestore.instance.collection('users').get();

  //   for (var element in snap.docs) {
  //     setState(() {
  //       username = element['username'];
  //       bloodGroup = element['blood'];
  //     });
  //   }
  // }

  var tot = FirebaseFirestore.instance.collection('users');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("blood"),
          actions: [
            TextButton(
                onPressed: () {
                  cntrl.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return SigninScreen();
                    },
                  ));
                },
                child: Text(
                  "SignOut",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var user = snapshot.data!.docs[index];
                  String username = user['username'];
                  String bloodGroup = user['blood'];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        child: Text(bloodGroup),
                      ),
                      title: Text(username),
                      // subtitle: Text(donarsnap['phone'].toString()),
                    ),
                  );
                },
              );
            }));
  }
}

class AddBlood extends StatelessWidget {
  AddBlood({super.key});
  final List<String> groups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-"
  ];
  String? selected = "";
  final CollectionReference donor =
      FirebaseFirestore.instance.collection("user");

  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  void addDonor() {
    final data = {
      'name': name.text,
      'phone': int.parse(phone.text),
      'group': selected
    };
    donor.add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Your Deteiles"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            BloodTextFiled("Name", name),
            BloodTextFiled("Phone", phone),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                    label: Text("Select your blood group")),
                items: groups
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  selected = value;
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  addDonor();
                },
                child: const Text("Submit"))
          ],
        ),
      ),
    );
  }
}

Padding BloodTextFiled(String hint, TextEditingController cntrl) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      controller: cntrl,
      decoration: textFormDec.copyWith(hintText: hint),
    ),
  );
}
