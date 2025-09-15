import '../services/api.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

class ClaimScreen extends StatefulWidget {
  const ClaimScreen({super.key});

  @override
  State<ClaimScreen> createState() => ClaimScreenState();
}

class ClaimScreenState extends State<ClaimScreen> {
  String info = "";
  String type = "";
  String level = '';
  String total = "0";
  bool launch = false;
  String subject = "";
  String formula = "Choisissez la formule";
  String env = "Choisissez l'environnement";
  final _registerFormKey = GlobalKey<FormState>();
  TextEditingController docIdController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  var envs = ["Choisissez l'environnement", 'Dev', 'Prod'];

  var formulas = ["Choisissez la formule", 'basic', 'advanced', 'premium',
                  'elite', 'vip', 'vvip'];

  var types = ['', 'Achat de question', 'Achat de document', 'Achat de sujets et corrigés'];

  var items = ['', 'sixieme', 'cinquieme', 'quatrieme', 'troisieme', 'seconde a', 'seconde c', 'premiere a', 'premiere c', 'premiere d',
    'terminale a', 'terminale c', 'terminale d', 'terminale e', "cafop", "infas bac", "infas bepc",
    "ena", "police"];

  var subjects = ['', 'all', 'allemand', 'français', 'histoire géographie', 'physique chimie',
                  'edhc', 'espagnol', 'philosophie', 'tic', 'eps', 'anglais', 'svt',
                  'musique', 'mathématiques', 'art plastique', 'st', 'culture générale',
                  'aptitude verbale', 'logique mathématiques'];

  Future updateUser()async{

    setState(() {
      launch = true;
    });

    bool result = false;
    String numberQuestion = "5";
    String userId = userIdController.text.trim();
    String finishDate = DateTime.now().add(const Duration(days: 307)).toString().split(".")[0];
    String finishQuestionDate = DateTime.now().add(const Duration(days: 5)).toString().split(".")[0];

    final user = await Api().getUserById(userId, env);

    if(type == "Achat de question"){

      if(formula == "basic"){
        numberQuestion = "22";
        finishQuestionDate = DateTime.now().add(const Duration(days: 11)).toString().split(".")[0];
      }
      else if(formula == "advanced"){
        numberQuestion = "50";
        finishQuestionDate = DateTime.now().add(const Duration(days: 25)).toString().split(".")[0];
      }
      else if(formula == "premium"){
        numberQuestion = "160";
        finishQuestionDate = DateTime.now().add(const Duration(days: 60)).toString().split(".")[0];
      }
      else if(formula == "elite"){
        numberQuestion = "320";
        finishQuestionDate = DateTime.now().add(const Duration(days: 90)).toString().split(".")[0];
      }
      else if(formula == "vip"){
        numberQuestion = "550";
        finishQuestionDate = DateTime.now().add(const Duration(days: 120)).toString().split(".")[0];
      }
      else if(formula == "vvip"){
        numberQuestion = "1100";
        finishQuestionDate = DateTime.now().add(const Duration(days: 270)).toString().split(".")[0];
      }

      result = await Api().updateUser(userId, numberQuestion, finishQuestionDate, "", "", env);
    }
    else if(type == 'Achat de document'){
      String docId = docIdController.text;

      if(user != null){
        String products = filterElementsNoExpires(user["products"] ?? "");
        products = products.isEmpty ? "$docId=$finishDate" : "$products|$docId=$finishDate";
        result = await Api().updateUser(userId, numberQuestion, finishQuestionDate, "", products, env);
      }
      else{
        setState(() {
          info = "Aucun utilisateur";
        });
      }
    }
    else{
      if(user != null){
        String country = countryController.text.toLowerCase();
        String pack = filterElementsNoExpires(user["pack"] ?? "");
        pack = pack.isEmpty ? "$country $subject $level=$finishDate" : "$pack|$country $subject $level=$finishDate";
        result = await Api().updateUser(userId, numberQuestion, finishQuestionDate, pack, "", env);
      }
      else{
        setState(() {
          info = "Aucun utilisateur";
        });
      }
    }

    setState(() {
      if(result){
        info = "Ajouté avec succès";
      }
      else{
        info = "Erreur lors de l'ajout";
      }

      launch = false;
    });
  }

  String filterElementsNoExpires(String phrase) {
    List<String> elements = phrase.split('|');
    DateTime now = DateTime.now();

    List<String> valid = elements.where((element) {
      List<String> parts = element.split('=');
      if (parts.length != 2) return false;

      try {
        DateTime date = DateTime.parse(parts[1]);
        return date.isAfter(now);
      } catch (e) {
        return false;
      }
    }).toList();

    return valid.join('|');
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
                children: [
                  Text(
                      "Réclamations".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                      )
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 15),
                  Form(
                      key: _registerFormKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            DropdownButtonFormField(
                                value: env,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                    labelText: "Environnement",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: envs.map((String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    env = newValue!;
                                  });
                                },
                                validator: (value){
                                  if(value == null || value.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 10),

                            DropdownButtonFormField(
                                value: type,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                    labelText: "Type",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: types.map((String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    type = newValue!;
                                  });
                                },
                                validator: (value){
                                  if(value == null || value.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 10),

                            TextFormField(
                                cursorColor: Colors.black,
                                controller: userIdController,
                                decoration: const InputDecoration(
                                    labelText: "Id de l'utilisateur",
                                    labelStyle: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    border: OutlineInputBorder()
                                ),
                                validator: (value){
                                  if(value == null || value.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 10),

                            type == "Achat de question" ?
                            Column(
                              children: [
                                DropdownButtonFormField(
                                    value: formula,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                        labelText: "Formule",
                                        border: OutlineInputBorder()
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: formulas.map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        formula = newValue!;
                                      });
                                    },
                                    validator: (value){
                                      if(type == "Achat de question" &&
                                          (value == null || value.isEmpty ||
                                          value == "Choisissez la formule")){
                                        return 'Ce champ est obligatoire';
                                      }
                                      return null;
                                    }
                                ),
                                const SizedBox(height: 10)
                              ]
                            ) :
                            const SizedBox(),

                            type == "Achat de document" ?
                            Column(
                              children: [
                                TextFormField(
                                    cursorColor: Colors.black,
                                    controller: docIdController,
                                    decoration: const InputDecoration(
                                        labelText: "Id du document",
                                        labelStyle: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                        border: OutlineInputBorder()
                                    ),
                                    validator: (value){
                                      if(type == "Achat de document" &&
                                          (value == null || value.isEmpty)) {
                                        return 'Ce champ est obligatoire';
                                      }
                                      return null;
                                    }
                                ),
                                const SizedBox(height: 10)
                              ]
                            ) :
                            const SizedBox(),

                            type == "Achat de sujets et corrigés" ?
                            Column(
                              children: [
                                GestureDetector(
                                    onTap: (){
                                      showCountryPicker(
                                          context: context,
                                          showPhoneCode: false,
                                          onSelect: (Country country) {
                                            setState(() {
                                              countryController.text = country.countryCode;
                                            });
                                          }
                                      );
                                    },
                                    child: TextFormField(
                                        enabled: false,
                                        controller: countryController,
                                        decoration: const InputDecoration(
                                            labelText: "Pays",
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                borderSide: BorderSide(color: Colors.red)
                                            )
                                        ),
                                        validator: (value){
                                          if(type == "Achat de sujets et corrigés" &&
                                              (value == null || value.isEmpty)){
                                            return 'Ce champ est obligatoire';
                                          }
                                          return null;
                                        }
                                    )
                                ),
                                const SizedBox(height: 15),

                                DropdownButtonFormField(
                                    value: level,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                        labelText: "Niveau",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        )
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: items.map((String item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(item),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        level = newValue!;
                                      });
                                    },
                                    validator: (value){
                                      if(type == "Achat de sujets et corrigés" &&
                                          (value == null || value.isEmpty)){
                                        return 'Ce champ est obligatoire';
                                      }
                                      return null;
                                    }
                                ),
                                const SizedBox(height: 10),

                                DropdownButtonFormField(
                                    value: subject,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                        labelText: "Matières",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                        )
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: subjects.map((String item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(item),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        subject = newValue!;
                                      });
                                    },
                                    validator: (value){
                                      if(type == "Achat de sujets et corrigés" &&
                                          (value == null || value.isEmpty)){
                                        return 'Ce champ est obligatoire';
                                      }
                                      return null;
                                    }
                                ),
                                const SizedBox(height: 10)
                              ]
                            ) :
                            const SizedBox(),

                            Text(
                                info,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            const SizedBox(height: 10),

                            SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<Color>(const Color(0xff2ab2a4)),
                                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            )
                                        )
                                    ),
                                    onPressed: !launch ?
                                        (){
                                      if(_registerFormKey.currentState!.validate()){
                                        updateUser();
                                      }
                                    } : null,
                                    child: !launch ?
                                    const Text(
                                        "Valider",
                                        style: TextStyle(
                                            color: Colors.white
                                        )
                                    ) :
                                    const SizedBox(
                                        width: 25,
                                        height: 25,
                                        child: CircularProgressIndicator(
                                            color: Colors.white
                                        )
                                    )
                                )
                            )
                          ]
                      )
                  )
                ]
            )
        )
    );
  }
}