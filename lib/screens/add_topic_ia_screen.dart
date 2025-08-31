import '../services/utilities.dart';
import '../services/api_topics.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tex/flutter_tex.dart';
import '../services/ai_studio_http_service.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddTopicIAScreen extends StatefulWidget {
  const AddTopicIAScreen({super.key});

  @override
  State<AddTopicIAScreen> createState() => AddTopicIAScreenState();
}

class AddTopicIAScreenState extends State<AddTopicIAScreen> {
  List countrys = [];
  String env = "Dev";
  int topicIndex = 0;
  bool launch = false;
  List topicLevels = [];
  String typeValue = "";
  String difficulty = "";
  String levelValue = "";
  String subjectValue = "";
  String visualizeText = "";
  String fileTypeValue = "";
  List topicIndexLists = [];
  String exerciseType = "";
  String correctionType = "";
  String subSubjectValue = "";

  var listSubSubject = [
    '',
    'CALCUL LITTERAL',
    'PROPRIETES DE THALES',
    'RACINES CARREES',
    'TRIANGLE RECTANGLE',
    'CALCUL NUMERIQUE',
    'ANGLES INSCRITS',
    'VECTEURS',
    'EQUATION ET INEQUATION DANS R',
    'COORDONNEES D\'UN VECTEUR',
    'EQUATIONS DE DROITES',
    'STATISTIQUE',
    'SYSTEME D\'EQUATIONS ET INEQUATIONS DANS R x R',
    'APPLICATIONS AFFINES',
    'PYRAMIDE ET CONE'
  ];

  var fileTypes = [
    '',
    'pdf',
    'text',
    'html'
  ];

  var types = [
    '',
    'unlock',
    'correctionLock',
    'lock'
  ];

  var difficulties = [
    '',
    'facile',
    'moyen',
    'difficile'
  ];

  var levels = [
    '',
    'sixieme',
    'cinquieme',
    'quatrieme',
    'troisieme',
    'seconde',
    'premiere',
    'terminale',
  ];

  var subjects = [
    '',
    'allemand',
    'français',
    'histoire géographie',
    'physique chimie',
    'edhc',
    'espagnol',
    'philosophie',
    'tic',
    'eps',
    'anglais',
    'svt',
    'musique',
    'mathématiques',
    'art plastique',
    'st',
    'culture générale',
    'aptitude verbale',
    'lm'
  ];

  final _registerFormKey = GlobalKey<FormState>();

  TextEditingController dateController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController exerciseController = TextEditingController();
  TextEditingController correctionController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future addTopic() async{

    setState(() { launch = true; });

    String title = nameController.text;
    String exercise = exerciseController.text;
    int number = int.parse(numberController.text);
    String correction = correctionController.text;
    String docType = "$exerciseType|$correctionType";
    String date = DateTime.now().toString().split(".")[0];

    var response = await TopicsRequests().addTopic(title, countrys, subjectValue,
        date, topicLevels, exercise, correction, typeValue, docType,
        subSubjectValue, number);

    modal(response);

    setState(() {
      launch = false;
      if(response){

      }
    });
  }

  Future<void> loadImages(String part) async{

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowCompression: true,
        allowedExtensions: part == "pdfFile" ? ["pdf"] : ["png", "jpg", "jpeg"]
    );

    if(result?.files.first != null){

      var fileBytes = result?.files.first.bytes;
      var fileName = DateTime.now().toString().replaceAll(".", "")
          .replaceAll(" ", "").replaceAll("-", "").replaceAll(":", "");

      String fileUrl = await (
          await FirebaseStorage.instance.ref().child('ressources/$fileName')
              .putData(fileBytes!)
              .whenComplete(() => null)).ref.getDownloadURL();

      fileUrl = Utilities().changeUrl(fileUrl);

      setState(() {
        exerciseController.text = fileUrl;
      });

    }
  }

  void modal(bool value){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Information"),
            content: Text(
                value ? "Ajout effectué avec succès" :
                "Erreur lors de l'ajout"
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: const Text("Fermer")
              )
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: const Text("Admin")
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                      "AJOUTER UN Sujet",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  Form(
                      key: _registerFormKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),

                            TextFormField(
                                controller: dateController,
                                decoration: const InputDecoration(
                                    labelText: "Date dernier sujet",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: Colors.red)
                                    )
                                )
                            ),
                            const SizedBox(height: 15),

                            const Text(
                                "N'oublie pas d'ajouter la série pour faire la différence dans le titre",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            const SizedBox(height: 15),

                            Row(
                                children: countrys.map(
                                        (e) => TextButton(
                                        onPressed: (){
                                          setState(() {
                                            countrys.remove(e);
                                          });
                                        },
                                        child: Text(e)
                                    )
                                ).toList()
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: GestureDetector(
                                        onTap: (){
                                          showCountryPicker(
                                              context: context,
                                              showPhoneCode: false,
                                              onSelect: (Country country) {
                                                setState(() {
                                                  countrys.add(country.countryCode);
                                                  countryController.text = "${country.countryCode}-${country.name}";
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
                                              if(value == null || value.isEmpty){
                                                return 'Ce champ est obligatoire';
                                              }
                                              return null;
                                            }
                                        )
                                    )
                                ),
                                Expanded(
                                    child: TextFormField(
                                        controller: countryController,
                                        decoration: const InputDecoration(
                                            labelText: "Pays",
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                borderSide: BorderSide(color: Colors.red)
                                            )
                                        ),
                                        validator: (value){
                                          if(value == null || value.isEmpty){
                                            return 'Ce champ est obligatoire';
                                          }
                                          return null;
                                        }
                                    )
                                )
                              ]
                            ),
                            const SizedBox(height: 15),

                            TextFormField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                    labelText: "Titre",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: Colors.red)
                                    )
                                ),
                                validator: (value){
                                  if(value == null || value.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            Row(
                                children: topicLevels.map(
                                        (e) => TextButton(
                                        onPressed: (){
                                          setState(() {
                                            topicLevels.remove(e);
                                          });
                                        },
                                        child: Text(e)
                                    )
                                ).toList()
                            ),
                            const SizedBox(height: 15),

                            DropdownButtonFormField(
                                value: levelValue,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                    labelText: "Niveau",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: levels.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    levelValue = newValue!;
                                    topicLevels.add(levelValue);
                                  });
                                },
                                validator: (value){
                                  if(value == null || value.isEmpty || topicLevels.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            DropdownButtonFormField(
                                value: subjectValue,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                    labelText: "Matières",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
                                    subjectValue = newValue!;

                                    topicIndexLists.clear();
                                    //topicIndexLists = Constants.topicDetails[levelValue]![subjectValue].toList();
                                    topicIndexLists.insert(0, "");
                                  });
                                },
                                validator: (value){
                                  if(value == null || value.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            DropdownButtonFormField(
                                value: subSubjectValue,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                    labelText: "Sous matière",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: listSubSubject.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    subSubjectValue = newValue!;
                                  });
                                },
                                validator: (value){
                                  if(value == null || value.isEmpty || topicLevels.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            Row(
                              children: [
                                Expanded(
                                   child:  DropdownButtonFormField(
                                       value: exerciseType,
                                       isExpanded: true,
                                       decoration: const InputDecoration(
                                           labelText: "Document type exercice",
                                           border: OutlineInputBorder(
                                               borderRadius: BorderRadius.all(Radius.circular(10))
                                           )
                                       ),
                                       icon: const Icon(Icons.keyboard_arrow_down),
                                       items: fileTypes.map((String item) {
                                         return DropdownMenuItem(
                                           value: item,
                                           child: Text(item),
                                         );
                                       }).toList(),
                                       onChanged: (String? newValue) {
                                         setState(() {
                                           exerciseType = newValue!;
                                         });
                                       },
                                       validator: (value){
                                         if(value == null || value.isEmpty){
                                           return 'Ce champ est obligatoire';
                                         }
                                         return null;
                                       }
                                   )
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                    child: DropdownButtonFormField(
                                        value: correctionType,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                            labelText: "Document type correction",
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                            )
                                        ),
                                        icon: const Icon(Icons.keyboard_arrow_down),
                                        items: fileTypes.map((String item) {
                                          return DropdownMenuItem(
                                            value: item,
                                            child: Text(item),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            correctionType = newValue!;
                                          });
                                        },
                                        validator: (value){
                                          if(value == null || value.isEmpty){
                                            return 'Ce champ est obligatoire';
                                          }
                                          return null;
                                        }
                                    )
                                )
                              ]
                            ),
                            const SizedBox(height: 15),

                            DropdownButtonFormField(
                                value: typeValue,
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
                                    typeValue = newValue!;
                                  });
                                },
                                validator: (value){
                                  if(value == null || value.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            TextFormField(
                                controller: numberController,
                                decoration: const InputDecoration(
                                    labelText: "Numéro",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: Colors.red)
                                    )
                                ),
                                validator: (value){
                                  if(value == null || value.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            DropdownButtonFormField(
                                value: difficulty,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                    labelText: "Difficulté",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: difficulties.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    difficulty = newValue!;
                                  });
                                },
                                validator: (value){
                                  if(value == null){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            TextFormField(
                                maxLines: 15,
                                controller: exerciseController,
                                decoration: const InputDecoration(
                                    labelText: "Exercice",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: Colors.red)
                                    )
                                ),
                                validator: (value){
                                  if(value == null || value.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            TextFormField(
                                maxLines: 15,
                                controller: correctionController,
                                decoration: const InputDecoration(
                                    labelText: "Correction",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: Colors.red)
                                    )
                                ),
                                validator: (value){
                                  if(value == null || value.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 20),

                            SizedBox(
                                height: 500,
                                child: TeXView(
                                    child: TeXViewDocument(
                                        visualizeText
                                    )
                                )
                            )
                          ]
                      )
                  ),
                  const SizedBox(height: 20),
                  Row(
                      children: [
                        Expanded(
                            child: SizedBox(
                                height: 45,
                                width: double.infinity,
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<Color>(
                                            Colors.grey
                                        ),
                                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15)
                                            )
                                        )
                                    ),
                                    onPressed: ()async{
                                      String prompt = """
                                        Genere moi un exercice de $subjectValue niveau ${topicLevels[0]}
                                        sur $subSubjectValue de difficulté $difficulty contenant
                                        15 questions. Une fois l'exercice generer. genere moi la reponse en détaillant toutes les étapes de calcul.
                                        l'exercice dans un html et le corrigé dans un autre html les deux séparer par |||
                                        Au format html,facilement affichable avec
                                        flutter_tex.
                                        
                                        - La sortie doit être exclusivement en **HTML** (pas en Markdown).
                                        - Les formules en LaTeX:
                                          - Encadre obligatoirement les formules inline avec \\(...\\) (jamais \$...\$).
                                          - Encadre les formules centrées avec \\[...\\] (jamais \$\$...\$\$).
                                        - Bien espacer les parties avec des `<br>`
                                        - Evite de mettre cette phrase : Voici l'exercice et son corrigé au format HTML.
                                        - N'ajoute pas de balise title
                                        - ⚠️ N’utilise jamais \$...\$ ni \$\$...\$\$ pour les formules.
                                      """;

                                      var response = await AiStudioHttpService().generateText("", prompt);
                                      if(response != null){
                                        List values = MarkDown().mySanitizeLatex(response["message"]).split("|||");
                                        setState(() {
                                          exerciseController.text = values[0].trim();
                                          correctionController.text = values[1].trim();
                                        });
                                      }
                                    },
                                    child: const Text(
                                        "Genere prompt",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        )
                                    )
                                )
                            )
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                            child: SizedBox(
                                height: 45,
                                width: double.infinity,
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<Color>(
                                            Colors.grey
                                        ),
                                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15)
                                            )
                                        )
                                    ),
                                    onPressed: (){
                                      setState(() {
                                        visualizeText = exerciseController.text;
                                      });
                                    },
                                    child: const Text(
                                        "Visualiser exercice",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        )
                                    )
                                )
                            )
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                            child: SizedBox(
                                height: 45,
                                width: double.infinity,
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<Color>(
                                            Colors.grey
                                        ),
                                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15)
                                            )
                                        )
                                    ),
                                    onPressed: (){
                                      setState(() {
                                        visualizeText = correctionController.text;
                                      });
                                    },
                                    child: const Text(
                                        "Visualiser correction",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        )
                                    )
                                )
                            )
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                            child: SizedBox(
                                height: 45,
                                width: double.infinity,
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<Color>(
                                            Colors.blue
                                        ),
                                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15)
                                            )
                                        )
                                    ),
                                    onPressed: (){
                                      if(_registerFormKey.currentState!.validate()){
                                        !launch ? addTopic() : null;
                                      }
                                    },
                                    child: !launch ?
                                    const Text(
                                        "Enregister",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        )
                                    ) :
                                    const CircularProgressIndicator(
                                        color: Colors.white
                                    )
                                )
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