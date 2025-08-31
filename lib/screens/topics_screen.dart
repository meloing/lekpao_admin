import 'add_topic_screen.dart';
import 'add_topic_ia_screen.dart';
import '../services/utilities.dart';
import '../services/api_topics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:le_kpao/screens/update_topic_screen.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({
    super.key,
    required this.uid
  });

  final String uid;

  @override
  State<TopicsScreen> createState() => TopicsScreenState();
}

class TopicsScreenState extends State<TopicsScreen> {
  String uid = "";
  List topics = [];
  String env = "Prod";
  String level = '';
  String subject = "";
  Map subSubjects = {};
  var listSubSubject = [''];
  String subSubjectValue = "";

  var items = ['', 'sixieme', 'cinquieme', 'quatrieme', 'troisieme', 'seconde',
               'premiere', 'terminale', "cafop", "infas bac", "infas bepc",
               "ena", "police"];

  var subjects = ['', 'allemand', 'français', 'histoire géographie', 'physique chimie',
                  'edhc', 'espagnol', 'philosophie', 'tic', 'eps', 'anglais', 'svt',
                  'musique', 'mathématiques', 'art plastique', 'st', 'culture générale',
                  'aptitude verbale', 'logique mathématiques'];

  Future addTopicToProd(index) async{
    Map topic = topics[index];
    String docId = topic["topicId"];

    await TopicsRequests().updateStatus(docId, "Prod");

    setState(() {
      topics[index]["env"] = "Prod";
    });
  }

  Future getTopics() async{
    List values = await TopicsRequests().getTopics(level, subject, subSubjectValue);

    setState(() {
      topics.clear();
      topics.addAll(values);
    });
  }

  Future delete(index) async{
    Map topic = topics[index];
    String docId = topic["topicId"];

    bool value = await TopicsRequests().deleteDocument(docId);

    setState(() {
      if(value){
        topics.removeAt(index);
      }
    });
  }

  void modal(index){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Attention !!!"),
          content: const Text(
              "Attention le sujet sera disponible pour tous."
          ),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: const Text("Annuler")
            ),
            TextButton(
                onPressed: (){
                  addTopicToProd(index);
                  Navigator.of(context).pop();
                },
                child: const Text("Valider")
            )
          ],
        )
    );
  }

  void deleteModal(index){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Attention !!!"),
          content: const Text(
              "Suppression d'un sujet"
          ),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: const Text("Annuler")
            ),
            TextButton(
                onPressed: (){
                  delete(index);
                  Navigator.of(context).pop();
                },
                child: const Text("Valider")
            )
          ],
        )
    );
  }

  void showAddTopicModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String? selectedSubject;
    final TextEditingController unitPriceController = TextEditingController();
    final TextEditingController allPriceController = TextEditingController();
    final TextEditingController bonusUnitController = TextEditingController();
    final TextEditingController bonusAllController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajouter un Topic dans Json"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Niveau",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedSubject,
                    items: items.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedSubject = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Sélectionnez une matière';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField("Prix Unité", unitPriceController, isNumber: true),
                  _buildTextField("Prix Complet", allPriceController, isNumber: true),
                  _buildTextField("Bonus Unité", bonusUnitController, isNumber: true),
                  _buildTextField("Bonus Complet", bonusAllController, isNumber: true)
                ]
              )
            )
          ),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Ajouter"),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final uri = Uri.parse(
                      'https://gb-success.com/kpao/add_topic.php'
                          '?id=${Uri.encodeComponent(selectedSubject!)}'
                          '&unit_price=${unitPriceController.text.trim()}'
                          '&all_price=${allPriceController.text.trim()}'
                          '&bonus_unit_price=${bonusUnitController.text.trim()}'
                          '&bonus_all_price=${bonusAllController.text.trim()}'
                  );

                  try {
                    final response = await http.get(uri);
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Topic ajouté avec succès")),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erreur serveur : ${response.statusCode}")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erreur réseau : $e")),
                    );
                  }
                }
              }
            )
          ]
        );
      }
    );
  }

  Future getSubSubjects() async{
    subSubjects = await Utilities().remoteConfigValue("subSubjects");
  }

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
    getSubSubjects();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            onPressed: (){
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => const AddTopicScreen()
                                  )
                              );
                            },
                            child: const Text("Ajouter un sujet")
                        )
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextButton(
                            onPressed: (){
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => const AddTopicIAScreen()
                                  )
                              );
                            },
                            child: const Text("Ajouter un sujet avec l'IA")
                        )
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: TextButton(
                              onPressed: () => showAddTopicModal(context),
                              child: const Text("Ajouter dans le json")
                          )
                      )
                    ]
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  Row(
                      children: [
                        Expanded(
                            child: DropdownButtonFormField(
                                value: level,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                    labelText: "Niveau",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    )
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: items.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    level = newValue!;
                                  });
                                }
                            )
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                            child: DropdownButtonFormField(
                                value: subject,
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
                                    subject = newValue!;
                                    listSubSubject = List<String>.from(subSubjects[level][subject]);
                                    listSubSubject.insert(0, "");
                                  });
                                }
                            )
                        ),
                        const SizedBox(width: 15),
                        IconButton(
                            onPressed: (){
                              getTopics();
                            },
                            icon: const Icon(
                                Icons.search_rounded
                            )
                        ),
                        const SizedBox(width: 15)
                      ]
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
                        if(value == null || value.isEmpty){
                          return 'Ce champ est obligatoire';
                        }
                        return null;
                      }
                  ),
                  const SizedBox(height: 15),
                  const SizedBox(
                      width: double.infinity,
                      child: Card(
                          elevation: 2,
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Consignes",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        )
                                    ),
                                    Divider(),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Icon(
                                              Icons.check_box_rounded,
                                              color: Colors.green
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                              child: Text(
                                                  "Ajouter le sujet",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Icon(
                                              Icons.check_box_rounded,
                                              color: Colors.green
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                              child: Text(
                                                  "Ajouter la date du sujet dans remoteconfig dev",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Icon(
                                              Icons.check_box_rounded,
                                              color: Colors.green
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                              child: Text(
                                                  "Faire les tests",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Icon(
                                              Icons.check_box_rounded,
                                              color: Colors.green
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                              child: Text(
                                                  "Si la matiere n'est pas dans json ajouté la",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Icon(
                                              Icons.check_box_rounded,
                                              color: Colors.green
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                              child: Text(
                                                  "Ajouter le sujet en prod",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                        children: [
                                          Icon(
                                              Icons.check_box_rounded,
                                              color: Colors.green
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                              child: Text(
                                                  "Ajouter la date du sujet dans remoteconfig en prod",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              )
                                          )
                                        ]
                                    )
                                  ]
                              )
                          )
                      )
                  ),
                  const SizedBox(height: 15),
                  Column(
                      children: Iterable<int>.generate(topics.length).toList().map(
                              (index){
                            Map e = topics[index];
                            return Card(
                                elevation: 2,
                                child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                          Row(
                                              children: [
                                                Text(e["type"]),
                                                const Spacer(),
                                                Container(
                                                    padding: const EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                        color: e["env"] == null ? Colors.orange :
                                                        e["env"] == "Prod" ? Colors.green : Colors.orange,
                                                        borderRadius: BorderRadius.circular(100)
                                                    ),
                                                    child: Text(
                                                        e["env"] == "Dev" ? "en dev" : "en prod",
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold
                                                        )
                                                    )
                                                )
                                              ]
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                              e['title'].toString().toLowerCase(),
                                              textAlign: TextAlign.justify,
                                              maxLines: 2,
                                              style:  const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black
                                              )
                                          ),
                                          const SizedBox(height: 5),
                                          Text(e['date'].toLowerCase()),
                                          const SizedBox(height: 10),
                                          Row(
                                              children: [
                                                Expanded(
                                                    child: TextButton(
                                                        style: ButtonStyle(
                                                            side: WidgetStateProperty.all(const BorderSide(color: Colors.red)),
                                                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(5)
                                                                )
                                                            )
                                                        ),
                                                        onPressed: (){
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (context) => UpdateTopicScreen(
                                                                      topic: e
                                                                  )
                                                              )
                                                          );
                                                        },
                                                        child: const Text(
                                                            "Voir",
                                                            style: TextStyle(
                                                                color: Colors.red,
                                                                fontWeight: FontWeight.bold
                                                            )
                                                        )
                                                    )
                                                ),
                                                const SizedBox(width: 5),
                                                uid == 'archetechnology1011@gmail.com' ?
                                                Expanded(
                                                    child: TextButton(
                                                        style: ButtonStyle(
                                                            side: WidgetStateProperty.all(const BorderSide(color: Colors.green)),
                                                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(5)
                                                                )
                                                            )
                                                        ),
                                                        onPressed: (){
                                                          modal(index);
                                                        },
                                                        child: const Text(
                                                            "Ajouter en prod",
                                                            style: TextStyle(
                                                                color: Colors.green,
                                                                fontWeight: FontWeight.bold
                                                            )
                                                        )
                                                    )
                                                ) :
                                                const SizedBox(),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                    child: TextButton(
                                                        style: ButtonStyle(
                                                            side: WidgetStateProperty.all(const BorderSide(color: Color(0xff0b65c2))),
                                                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(5)
                                                                )
                                                            )
                                                        ),
                                                        onPressed: (){
                                                          deleteModal(index);
                                                        },
                                                        child: const Text(
                                                            "Supprimer",
                                                            style: TextStyle(
                                                                color: Color(0xff0b65c2),
                                                                fontWeight: FontWeight.bold
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
                      ).toList()
                  )
                ]
            )
        )
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder()
        ),
        validator: (value) {
          if(value == null || value.trim().isEmpty){
            return 'Ce champ est requis';
          }
          return null;
        }
      )
    );
  }
}