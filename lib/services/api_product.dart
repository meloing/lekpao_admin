import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRequests {
  CollectionReference products = FirebaseFirestore.instance.collection('products');

  Future addProduct(String title, String description, String price, String date,
                    List levels, String subject, String picture, String file,
                    List country, String type, String iapId,
      String isValidated) async {

    Map<String, dynamic> value = {
      "env": "Dev",
      "date" : date,
      "type" : type,
      "file" : file,
      "title" : title,
      "price" : price,
      "iap_id" : iapId,
      "levels" : levels,
      "subject": subject,
      "country" : country,
      "picture" : picture,
      "description" : description,
      "is_validated" : isValidated
    };

    try{
      final docRef = await products.add(value);
      return docRef.id;
    }
    catch(error){
      return null;
    }
  }

  Future updateProduct(String title, String description, String price, String date,
      List levels, String subject, String picture, String file,
      List country, String type, String productId, String iapId,
      String isValidated) async {

    Map<String, dynamic> value = {
      "date" : date,
      "type" : type,
      "file" : file,
      "title" : title,
      "price" : price,
      "iap_id" : iapId,
      "levels" : levels,
      "subject": subject,
      "country" : country,
      "picture" : picture,
      "description" : description,
      "is_validated" : isValidated
    };

    return products
        .doc(productId)
        .update(value)
        .then((value) => true)
        .catchError((error) => false);
  }

  Future updateStatus(String productId, String env) async {
    return products
        .doc(productId)
        .update({
          "env" : env
        })
        .then((value) => true)
        .catchError((error) => false);
  }

  Future getProducts(String level) async{
    QuerySnapshot querySnapshot = await products
        .where("levels", arrayContains: level)
        .orderBy("date", descending: true)
        .get();
    final allData = querySnapshot.docs.map(
            (doc){
          Map value = doc.data() as Map;
          value['productId'] = doc.id;
          return value;
        }
    ).toList();

    return allData;
  }

  Future<bool> addProductInJson(String id, int price, int bonus) async {
    final uri = Uri.parse(
      'https://gb-success.com/kpao/add_product.php?id=$id&price=$price&bonus=$bonus'
    );

    final response = await http.get(uri);

    if(response.statusCode == 200){
      return true;
    }

    return false;
  }
}