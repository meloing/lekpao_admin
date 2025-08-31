import '../services/utilities.dart';
import '../services/api_product.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen> {
  List countrys = [];
  String env = "Dev";
  bool launch = false;
  List topicLevels = [];
  String typeValue = "";
  String levelValue = "";
  String visualizeText = "";
  String fileTypeValue = "";

  var fileTypes = ['', 'pdf', 'text', 'html'];

  var levels = ['', 'sixieme', 'cinquieme', 'quatrieme', 'troisieme', 'seconde',
                'premiere', 'terminale', "cafop", "infas bac", "infas bepc",
                "ena", "police"];

  final _registerFormKey = GlobalKey<FormState>();

  TextEditingController subjectValue = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController fileController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController pictureController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future addTopic() async{

    setState(() { launch = true; });

    bool response = false;
    String file = fileController.text;
    String subject = subjectValue.text;
    String title = titleController.text;
    String price = priceController.text;
    String picture = pictureController.text;
    String description = descriptionController.text;
    String date = DateTime.now().toString().split(".")[0];

    final productId = await ProductRequests().addProduct(title, description, price, date,
        topicLevels, subject, picture, file, countrys, fileTypeValue);

    if(productId != null){
      response = await ProductRequests().addProductInJson(productId, int.parse(price), 10);
    }

    modal(response);

    setState(() {
      launch = false;
      if(response){
        subjectValue.text = "";
        fileController.text = "";
        titleController.text = "";
        priceController.text = "";
        dateController.text = date;
        pictureController.text = "";
        descriptionController.text = "";
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
        descriptionController.text = fileUrl;
      });
    }
  }

  void modal(bool value){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Information"),
            content: Text(
                value ? "Ajout effectué avec succès" : "Erreur lors de l'ajout"
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: const Text("AJOUTER UNE ANNALE")
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Form(
                      key: _registerFormKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            TextFormField(
                                controller: dateController,
                                decoration: const InputDecoration(
                                    labelText: "Date dernier annale",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: Colors.red)
                                    )
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
                                      if(value == null || value.isEmpty){
                                        return 'Ce champ est obligatoire';
                                      }
                                      return null;
                                    }
                                )
                            ),
                            const SizedBox(height: 15),

                            TextFormField(
                                controller: titleController,
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

                            TextFormField(
                                controller: subjectValue,
                                decoration: const InputDecoration(
                                    labelText: "Image",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: Colors.red)
                                    )
                                )
                            ),
                            const SizedBox(height: 15),

                            DropdownButtonFormField(
                                value: fileTypeValue,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                    labelText: "Type",
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
                                    fileTypeValue = newValue!;
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
                                controller: pictureController,
                                decoration: const InputDecoration(
                                    labelText: "Image",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: Colors.red)
                                    )
                                )
                            ),
                            const SizedBox(height: 15),

                            TextFormField(
                                controller: priceController,
                                decoration: const InputDecoration(
                                    labelText: "Prix",
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
                                maxLines: 20,
                                controller: fileController,
                                decoration: const InputDecoration(
                                    labelText: "Fichier",
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
                                maxLines: 10,
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                    labelText: "Description",
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
                                child: Markdown(
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
                                        visualizeText = descriptionController.text;
                                      });
                                    },
                                    child: const Text(
                                        "Visualiser",
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