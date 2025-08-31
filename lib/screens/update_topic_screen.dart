import '../services/utilities.dart';
import '../services/api_topics.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateTopicScreen extends StatefulWidget {
  const UpdateTopicScreen({
    super.key,
    required this.topic
  });

  final Map topic;

  @override
  State<UpdateTopicScreen> createState() => UpdateTopicScreenState();
}

class UpdateTopicScreenState extends State<UpdateTopicScreen> {
  Map topic = {};
  List countrys = [];
  String env = "Dev";
  int topicIndex = 0;
  bool launch = false;
  Map subSubjects = {};
  List topicLevels = [];
  String typeValue = "";
  String levelValue = "";
  String subjectValue = "";
  String exerciseType = "";
  String visualizeText = "";
  String fileTypeValue = "";
  List topicIndexLists = [];
  String correctionType = "";
  String subSubjectValue = "";

  var listSubSubject = [''];

  var fileTypes = ['', 'pdf', 'text', 'html'];

  var types = ['', 'unlock', 'correctionLock', 'lock'];

  var levels = ['', 'sixieme', 'cinquieme', 'quatrieme', 'troisieme', 'seconde',
                'premiere', 'terminale', "cafop", "infas bac", "infas bepc",
                "ena", "police"];

  var subjects = ['', 'allemand', 'français', 'histoire géographie', 'physique chimie',
                  'edhc', 'espagnol', 'philosophie', 'tic', 'eps', 'anglais', 'svt',
                  'musique', 'mathématiques', 'art plastique', 'st', 'culture générale',
                  'aptitude verbale', 'logique mathématiques'];

  final _registerFormKey = GlobalKey<FormState>();

  TextEditingController dateController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController exerciseController = TextEditingController();
  TextEditingController correctionController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future updateTopic() async{

    setState(() { launch = true; });

    String title = nameController.text;
    String exercise = exerciseController.text;
    int number = int.parse(numberController.text);
    String correction = correctionController.text;
    String docType = "$exerciseType|$correctionType";
    String date = DateTime.now().toString().split(".")[0];

    var response = await TopicsRequests().updateTopic(title, countrys, subjectValue,
        date, topicLevels, exercise, correction, typeValue, docType,
        subSubjectValue, number, topic['topicId']);

    modal(response);

    setState(() {
      launch = false;
    });
  }

  Future getSubSubjects() async{
    subSubjects = await Utilities().remoteConfigValue("subSubjects");
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

  void markdExo(String element)async{
    if(element == "![Image](http://url/a.png)"){
      String fileUrl = await Utilities().loadImages(exerciseType);
      if(fileUrl.isNotEmpty){
        setState(() {
          if(exerciseType == "html"){
            exerciseController.text ='${exerciseController.text}\n<p><img src="$fileUrl" width="100%"></p>';
          }
          else{
            exerciseController.text = "${exerciseController.text}\n![Image]($fileUrl)";
          }
        });
      }
    }
    else{
      setState(() {
        exerciseController.text = "${exerciseController.text} $element";
      });
    }
  }

  void markdCor(String element)async{
    if(element == "![Image](http://url/a.png)"){
      String fileUrl = await Utilities().loadImages(correctionType);
      if(fileUrl.isNotEmpty){
        setState(() {
          if(exerciseType == "html"){
            correctionController.text ='${correctionController.text}\n<p><img src="$fileUrl" width="100%"></p>';
          }
          else{
            correctionController.text = "${correctionController.text}\n![Image]($fileUrl)";
          }
        });
      }
    }
    else{
      setState(() {
        correctionController.text = "${correctionController.text} $element";
      });
    }
  }

  void load(){
    List docTypes = topic["doc_type"].split("|");

    setState(() {
      typeValue = topic["type"];
      exerciseType = docTypes[0];
      countrys = topic["country"];
      topicLevels = topic["level"];
      correctionType = docTypes[1];
      subjectValue = topic["subject"];
      dateController.text = topic["date"];
      nameController.text = topic["title"];
      subSubjectValue = topic["sub_subject"];
      listSubSubject = [topic["sub_subject"]];
      exerciseController.text = topic["exercise"];
      correctionController.text = topic["correction"];
      numberController.text = topic["number"].toString();
    });
  }

  @override
  void initState() {
    super.initState();
    getSubSubjects();
    topic = widget.topic;
    load();
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
                            GestureDetector(
                                onTap: (){
                                  showCountryPicker(
                                      context: context,
                                      showPhoneCode: false,
                                      onSelect: (Country country) {
                                        setState(() {
                                          countrys.add(country.countryCode.toLowerCase());
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
                                      if(countrys.isEmpty){
                                        return 'Ce champ est obligatoire';
                                      }
                                      return null;
                                    }
                                )
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
                                  if(topicLevels.isEmpty){
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
                                    listSubSubject = List<String>.from(subSubjects[levelValue][subjectValue]);
                                    listSubSubject.insert(0, "");
                                  });
                                },
                                validator: (value){
                                  if(subjectValue.isEmpty){
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
                                  if(subSubjectValue.isEmpty){
                                    return 'Ce champ est obligatoire';
                                  }
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            DropdownButtonFormField(
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
                            ),
                            const SizedBox(height: 15),

                            DropdownButtonFormField(
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

                            Utilities().markdownWidget(markdExo),
                            const SizedBox(height: 15),

                            TextFormField(
                                maxLines: 20,
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

                            Utilities().markdownWidget(markdCor),
                            const SizedBox(height: 15),

                            TextFormField(
                                maxLines: 20,
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
                            const SizedBox(height: 10),

                            TextButton(
                                onPressed: (){
                                  loadImages("pdfFile");
                                },
                                child: const Text("Ajouter le pdf")
                            ),
                            const SizedBox(height: 20),

                            SizedBox(
                                height: 500,
                                child: exerciseType == "html" ?
                                TeXView(
                                    child: TeXViewDocument(
                                        visualizeText
                                    )
                                ) :
                                correctionType == "html" ?
                                TeXView(
                                    child: TeXViewDocument(
                                        visualizeText
                                    )
                                ) :
                                Markdown(
                                    data: visualizeText
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
                                        !launch ? updateTopic() : null;
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