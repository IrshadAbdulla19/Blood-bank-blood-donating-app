import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_app/main.dart';
import 'package:sample_app/model/user_model.dart';

class AuthController extends GetxController {
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
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  final CollectionReference donor =
      FirebaseFirestore.instance.collection("user");
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  String? selected = "";
  TextEditingController password = TextEditingController();
  TextEditingController loginemail = TextEditingController();
  TextEditingController loginpassword = TextEditingController();
  TextEditingController resetemail = TextEditingController();
  var loading = false.obs;

  signup() async {
    try {
      loading.value = true;
      await auth.createUserWithEmailAndPassword(
          email: email.text, password: password.text);
      addUser();
      verifyEmail();
      Get.offAll(() => HomePage());
      loading.value = false;
    } catch (e) {
      Get.snackbar("error", "$e");
      loading.value = false;
    }
  }

  addUser() async {
    UserModel user = UserModel(
        username: username.text,
        email: auth.currentUser?.email,
        phone: phone.text,
        blood: selected);
    await db.collection("users").doc(auth.currentUser!.uid).set(user.tomap());
  }

  signOut() async {
    await auth.signOut();
  }

  signIn() async {
    try {
      loading.value = true;
      await auth.signInWithEmailAndPassword(
          email: loginemail.text, password: loginpassword.text);
      Get.offAll(() => HomePage());
      loading.value = false;
    } catch (e) {
      Get.snackbar("error", "$e");
      loading.value = false;
    }
  }

  verifyEmail() async {
    await auth.currentUser?.sendEmailVerification();
    Get.snackbar("email", "send");
  }

  resetPassword() async {
    try {
      await auth.sendPasswordResetEmail(email: resetemail.text);
      Get.snackbar("email", "send successfully");
      Get.offAll(() => SigninScreen());
    } catch (e) {
      Get.snackbar("error", "$e");
    }
  }
}
