import '../services/api_product.dart';
import 'package:flutter/material.dart';
import 'package:le_kpao/screens/update_product.dart';
import 'package:le_kpao/screens/add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    super.key,
    required this.uid
  });

  final String uid;

  @override
  State<ProductsScreen> createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {
  String uid = "";
  String level = '';
  List products = [];
  String env = "Prod";

  var items = ['', 'sixieme', 'cinquieme', 'quatrieme', 'troisieme', 'seconde a',
    'seconde c', 'premiere a', 'premiere c', 'premiere d', 'terminale a',
    'terminale c', 'terminale d', 'terminale e', "cafop", "infas bac",
    "infas bepc", "ena", "police"];

  Future addProductToProd(index) async{
    Map product = products[index];
    String docId = product["productId"];

    await ProductRequests().updateStatus(docId, "Prod");

    setState(() {
      products[index]["env"] = "Prod";
    });
  }

  Future getProducts() async{
    List values = await ProductRequests().getProducts(level);
    setState(() {
      products.clear();
      products.addAll(values);
    });
  }

  void modal(index){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Attention !!!"),
          content: const Text(
              "Attention le produit sera disponible pour tous."
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
                  addProductToProd(index);
                  Navigator.of(context).pop();
                },
                child: const Text("Valider")
            )
          ],
        )
    );
  }

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = (MediaQuery.of(context).size.width/2)-160;

    return Scaffold(
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                          onPressed: (){
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const AddProductScreen()
                                )
                            );
                          },
                          child: const Text("Ajouter une annale")
                      )
                    ]
                  ),
                  const SizedBox(height: 10),
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
                        IconButton(
                            onPressed: (){
                              getProducts();
                            },
                            icon: const Icon(
                                Icons.search_rounded
                            )
                        ),
                        const SizedBox(width: 15)
                      ]
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
                                              "Ajouter le document",
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
                                              "Ajouter la date du document dans remoteconfig dev",
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
                                              "Ajouter le document en prod",
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
                                            "Ajouter la date du document dans remoteconfig en prod",
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
                  Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: Iterable<int>.generate(products.length).toList().map(
                              (index){
                            Map e = products[index];
                            return SizedBox(
                                width: screenWidth,
                                child: Card(
                                    elevation: 2,
                                    child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                            children: [
                                              Row(
                                                  children: [
                                                    Text(e["type"]),
                                                    const Spacer(),
                                                    const SizedBox(width: 5),
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
                                              const SizedBox(height: 25),
                                              SizedBox(
                                                  height: 60,
                                                  child: Column(
                                                      children: [
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
                                                        Text(e['date'].toLowerCase())
                                                      ]
                                                  )
                                              ),
                                              const SizedBox(height: 25),
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
                                                                      builder: (context) => UpdateProductScreen(
                                                                          product: e
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
                                                                side: WidgetStateProperty.all(const BorderSide(color: Color(0xff0b65c2))),
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
                                                                    color: Color(0xff0b65c2),
                                                                    fontWeight: FontWeight.bold
                                                                )
                                                            )
                                                        )
                                                    ) :
                                                    const SizedBox()
                                                  ]
                                              )
                                            ]
                                        )
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
}