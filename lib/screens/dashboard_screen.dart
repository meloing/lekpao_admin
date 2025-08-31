import '../services/api.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
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

  Future getData() async {
    Map stats = {};
    int tempTotal = 0;
    List documentList = [];
    int tempAchatPremium = 0;
    int tempAchatDocument = 0;
    int tempAchatQuestion = 0;

    var results = await Api().getDataInRange(_selectedDate1Range!, _selectedDate2Range!);

    for(var doc in results){
      Map data = doc.data();
      tempTotal += int.parse(data["cpm_amount"]);

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

    int number = await Api().getNumberSubscribersInRange(_selectedDate1Range!, _selectedDate2Range!);
    setState(() {
      total = tempTotal.toString();
      totalInscrit = number.toString();
      buyQuestion = results.length.toString();
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

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              children: [
                Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () => _pickDate(context, 1),
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey
                                  ),
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Text(
                                  _selectedDate1 == null
                                      ? "Aucune date sélectionnée"
                                      : "${_selectedDate1!.day}/${_selectedDate1!.month}/${_selectedDate1!.year}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                              )
                          )
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: GestureDetector(
                              onTap: () => _pickDate(context, 2),
                              child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.grey
                                      ),
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Text(
                                    _selectedDate2 == null
                                        ? "Aucune date sélectionnée"
                                        : "${_selectedDate2!.day}/${_selectedDate2!.month}/${_selectedDate2!.year}",
                                    style: const TextStyle(fontSize: 18),
                                  )
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
                              ]
                          )
                      )
                    ]
                )
              ]
          )
        )
    );
  }
}