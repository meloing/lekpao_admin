import '../services/api.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => AdminScreenState();
}

class AdminScreenState extends State<AdminScreen> {
  String info = "";
  String total = "0";
  bool launch = false;
  DateTime? _selectedDate1;
  DateTime? _selectedDate2;
  String buyQuestion = "...";
  String? _selectedDate1Range;
  String? _selectedDate2Range;
  String totalInscrit = "...";
  String formula = "Choisissez la formule";
  final _registerFormKey = GlobalKey<FormState>();
  TextEditingController userIdController = TextEditingController();

  var formulas = [
    "Choisissez la formule",
    'basic',
    'advanced',
    'premium',
    'elite',
    'vip',
    'vvip'
  ];

  double parseAmount(dynamic value) {
    if (value == null) return 0.0;

    String raw = value.toString().trim();

    // Vérifie si la valeur contient "$"
    bool isDollar = raw.contains("\$");

    // Nettoie pour garder chiffres + .
    raw = raw.replaceAll(RegExp(r'[^0-9.]'), '');

    double amount = double.tryParse(raw) ?? 0.0;

    if (isDollar) {
      amount *= 500; // conversion en FCFA
    }

    return amount;
  }



  Future getData() async {
    Map stats = {};
    double tempTotal = 0;
    List documentList = [];
    int tempAchatPremium = 0;
    int tempAchatDocument = 0;
    int tempAchatQuestion = 0;

    var results = await Api().getDataInRange(_selectedDate1Range!, _selectedDate2Range!);

    for(var doc in results){
      Map data = doc.data();
      tempTotal += parseAmount(data["cpm_amount"]);

      if(data["command_type"] == "command_document"){
        tempAchatDocument += 1;
        documentList.add(data);
      }
      else if(data["command_type"] == "command_premium"){
        tempAchatPremium += 1;
      }
      else{
        tempAchatQuestion += 1;
      }

      stats[data["formula"]] = (stats[data["formula"]] ?? 0) + 1;
    }

    var subscribers = await Api().getNumberSubscribersInRange(_selectedDate1Range!, _selectedDate2Range!);
    setState(() {
      total = tempTotal.toString();
      buyQuestion = results.length.toString();
      totalInscrit = subscribers.length.toString();
    });
  }

  Future<void> _pickDate(BuildContext context, int index) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
            data: ThemeData.light().copyWith(
                primaryColor: Colors.blue,
                hintColor: Colors.blue,
                colorScheme: const ColorScheme.light(primary: Colors.blue),
                buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary)
            ),
            child: child!
        );
      },
    );

    if(pickedDate != null) {
      setState(() {
        if(index == 1){
          _selectedDate1 = pickedDate;
          _selectedDate1Range = pickedDate.toString().split(".")[0];
        }
        else{
          _selectedDate2 = pickedDate;
          _selectedDate2Range = "${pickedDate.toString().split(" ")[0]} 23:59:59";
        }
      });
    }
  }

  Future updateUser()async{

    setState(() { launch = true; });

    String numberQuestion = "";
    String finishQuestionDate = "";
    String docId = userIdController.text.trim();

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

    bool result = await Api().updateUser(docId, numberQuestion, finishQuestionDate);

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

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                                onTap: () => _pickDate(context, 1),
                                child: Text(
                                      _selectedDate1 == null ?
                                      "Aucune date sélectionnée" :
                                      "${_selectedDate1!.day}/${_selectedDate1!.month}/${_selectedDate1!.year}",
                                  style: const TextStyle(fontSize: 18)
                                )
                            )
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                            child: GestureDetector(
                                onTap: () => _pickDate(context, 2),
                                child: Text(
                                      _selectedDate2 == null ?
                                      "Aucune date sélectionnée" :
                                      "${_selectedDate2!.day}/${_selectedDate2!.month}/${_selectedDate2!.year}",
                                  style: const TextStyle(fontSize: 18)
                                )
                            )
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                            onPressed: (){
                              getData();
                            },
                            child: const Text("Valider")
                        )
                      ]
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                      children: [
                        Expanded(
                            child: Card(
                                elevation: 2,
                                child: Container(
                                    height: 210,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff1E3A8A),
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Stack(
                                        children: [
                                          Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 10),
                                                const Text(
                                                    "TOTAL INSCRIT",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold
                                                    )
                                                ),
                                                const SizedBox(height: 15),
                                                Text(
                                                    totalInscrit,
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold
                                                    )
                                                )
                                              ]
                                          ),
                                          const Positioned(
                                              top: 15,
                                              right: 0,
                                              child: Icon(
                                                Icons.groups_rounded,
                                                size: 50,
                                                color: Colors.white,
                                              )
                                          )
                                        ]
                                    )
                                )
                            )
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                            child: Column(
                              children: [
                                Card(
                                    elevation: 2,
                                    child: Container(
                                        height: 100,
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Stack(
                                            children: [
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                        "Achat de question",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold
                                                        )
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Text(
                                                        buyQuestion,
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold
                                                        )
                                                    )
                                                  ]
                                              ),
                                              const Positioned(
                                                  top: 15,
                                                  right: 0,
                                                  child: Icon(
                                                    Icons.question_mark_rounded,
                                                    size: 50,
                                                    color: Colors.white,
                                                  )
                                              )
                                            ]
                                        )
                                    )
                                ),
                                Card(
                                    elevation: 2,
                                    child: Container(
                                        height: 100,
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: const Color(0xff047857),
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Stack(
                                            children: [
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                        "Montant total",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold
                                                        )
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Text(
                                                        total,
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold
                                                        )
                                                    )
                                                  ]
                                              ),
                                              const Positioned(
                                                  top: 15,
                                                  right: 0,
                                                  child: Icon(
                                                    Icons.question_mark_rounded,
                                                    size: 50,
                                                    color: Colors.white,
                                                  )
                                              )
                                            ]
                                        )
                                    )
                                )
                              ],
                            )
                        )
                      ]
                  ),
                  Form(
                      key: _registerFormKey,
                      child: Column(
                        children: [
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
                                if (value == null || value.isEmpty) {
                                  return 'Ce champ est obligatoire';
                                }
                                return null;
                              }
                          ),
                          const SizedBox(height: 10),
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
                                if (value == null || value.isEmpty ||
                                    value == "Choisissez la formule") {
                                  return 'Ce champ est obligatoire';
                                }
                                return null;
                              }
                          ),
                          const SizedBox(height: 10),
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