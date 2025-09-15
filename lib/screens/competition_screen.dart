import '../services/api.dart';
import 'package:flutter/material.dart';

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => CompetitionScreenState();
}

class CompetitionScreenState extends State<CompetitionScreen> {
  String info = "";
  String total = "0";
  bool launch = false;
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

  String level = '';
  String subject = "";

  var items = ['', 'sixieme', 'cinquieme', 'quatrieme', 'troisieme', 'seconde a',
    'seconde c', 'premiere a', 'premiere c', 'premiere d', 'terminale a',
    'terminale c', 'terminale d', 'terminale e', "cafop", "infas bac", "infas bepc",
    "ena", "police"];

  var subjects = ['', 'allemand', 'français', 'histoire géographie', 'physique chimie',
    'edhc', 'espagnol', 'philosophie', 'tic', 'eps', 'anglais', 'svt',
    'musique', 'mathématiques', 'art plastique', 'st', 'culture générale',
    'aptitude verbale', 'logique mathématiques'];

  Future updateUser()async{

    setState(() {
      launch = true;
    });

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
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
                children: [
                  Text(
                      "Concours",
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      )
                  )
                ]
            )
        )
    );
  }
}