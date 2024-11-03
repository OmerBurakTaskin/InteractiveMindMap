import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/custom_colors.dart';
import 'package:hackathon/screens/home_screen.dart';
import 'package:hackathon/services/user_db_service.dart';
import 'package:hive/hive.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  String? selectedValue;
  TextEditingController ageController = TextEditingController();
  TextEditingController jobController = TextEditingController();
  TextEditingController interestsController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _getStartedDefaultText(
                      "Hoşgeldin! Başlamadan önce kişiselleştirilmiş akıl haritası deneyimi için seni biraz tanıyalım:",
                      16,
                      color3),
                  const SizedBox(height: 20),
                  SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: _getStartedTextField(
                          "Kaç yaşındasın?", true, ageController, 1)),
                  const SizedBox(height: 20),
                  _getStartedDefaultText("Eğitim durumun:", 16, color3),
                  const SizedBox(height: 20),
                  DropdownButton<String>(
                    isDense: false,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    alignment: Alignment.center,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child:
                          _getStartedDefaultText("Eğitim durumun", 18, color3),
                    ),
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue;
                      });
                    },
                    items: <String>['Ortaokul', 'Lise', 'Üniversite', 'Mezun']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: color3),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  selectedValue == "Mezun"
                      ? SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          child: _getStartedTextField(
                              "Hangi işle uğraşıyorsun?",
                              false,
                              jobController,
                              1))
                      : const SizedBox.shrink(),
                  selectedValue == "Üniversite"
                      ? SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          child: _getStartedTextField(
                              "Hangi bölümde okuyorsun?",
                              false,
                              jobController,
                              1))
                      : const SizedBox.shrink(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _getStartedDefaultText(
                        "Bize biraz kendinden bahset. Nelere ilgi duyuyorsun, uygulamayı ne için kullanacaksın... Bu, yapay zeka modelimizin sana daha iyi hizmet vermesine yardımcı olacaktır.",
                        16,
                        color3),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: _getStartedTextField("İlgi alanlarınızı belirtin",
                          false, interestsController, 5)),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: ElevatedButton(
                      clipBehavior: Clip.none,
                      onPressed: () async {
                        if (selectedValue == null ||
                            ageController.text.isEmpty ||
                            interestsController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: color3,
                              content: const Text(
                                "Lütfen tüm alanları doldurun",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              )));
                          return;
                        }
                        await UserDbService()
                            .addUserPersonalInfo(_auth.currentUser!.uid, {
                          "age": int.parse(ageController.text),
                          "education": selectedValue,
                          "occupation": jobController.text,
                          "interests": interestsController.text
                        });
                        final box = await Hive.openBox("userpersonalinfo");
                        box.put("userInfo", {
                          "age": int.parse(ageController.text),
                          "education": selectedValue,
                          "occupation": jobController.text,
                          "interests": interestsController.text
                        });
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundBuilder: (context, states, child) {
                          return Container(
                            height: 70,
                            width: 220,
                            decoration: BoxDecoration(
                              color: color3,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: child,
                          );
                        },
                      ),
                      child: const Text(
                        "Hadi Başlayalım!",
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getStartedDefaultText(String text, double size, Color color) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _getStartedTextField(String hintText, bool isNumber,
      TextEditingController controller, int lines) {
    return TextField(
        maxLines: lines,
        minLines: lines,
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          hintText: hintText,
          hintStyle: TextStyle(color: skinColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: skinColor),
          ),
        ));
  }
}
