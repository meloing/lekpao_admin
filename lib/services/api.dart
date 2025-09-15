import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Api {
  late Future<Database> database;

  CollectionReference topics = FirebaseFirestore.instance.collection('topics');
  CollectionReference users = FirebaseFirestore.instance.collection('usersDev');

  Future<bool> updateUser(String docId, String numberQuestion,
      String finishQuestionDate,
      [String pack="", String products="", String env=""]) async {

    users = FirebaseFirestore.instance.collection(env == "Prod" ? 'users': "usersDev");

    var data = {
      "number_question": numberQuestion,
      "finish_question": finishQuestionDate,
    };

    if(pack.isNotEmpty){
      data["pack"] = pack;
    }

    if(products.isNotEmpty){
      data["products"] = products;
    }

    try{
      await users.doc(docId).update(data);
      return true;
    }
    catch(e){
      return false;
    }
  }

  Future<bool> updatePaymentDate(env, docId) async {

    users = FirebaseFirestore.instance.collection(env == "Prod" ? 'users': "usersDev");

    try{
      await users.doc(docId).update({
        "last_payment_date": DateTime.now().toString().split(".")[0]
      });
      return true;
    }
    catch(e){
      return false;
    }
  }

  Future getDataInRange(String plage1, String plage2) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await firestore
        .collection('commands')
        .where('cpm_trans_date', isGreaterThanOrEqualTo: plage1)
        .where('cpm_trans_date', isLessThanOrEqualTo: plage2)
        .get();

    return querySnapshot.docs;
  }

  Future getNumberSubscribersInRange(String plage1, String plage2) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot  querySnapshot = await firestore
        .collection('users')
        .where('created_at', isGreaterThanOrEqualTo: plage1)
        .where('created_at', isLessThanOrEqualTo: plage2)
        .get();

    return querySnapshot.docs;
  }

  Future<int> getInvitedUsersCount(env, lastPaymentDate, referralCode) async {

    Query query;
    users = FirebaseFirestore.instance.collection(env == "Prod" ? 'users': "usersDev");

    if(lastPaymentDate.isEmpty){
      query = users.where('referral_code', isEqualTo: referralCode);
    }
    else{
      query = users
          .where('referral_code', isEqualTo: referralCode)
          .where('created_at', isGreaterThan: lastPaymentDate);
    }

    final result = await query.count().get();
    return result.count ?? 0;
  }

  Future<Map<String, dynamic>> getReferralEarnings(env, lastPaymentDate, referralCode) async {

    Query query;
    CollectionReference commands = FirebaseFirestore.instance.collection(env == "Prod" ? 'commands': "commandsDev");

    if(lastPaymentDate.isEmpty){
      query = commands.where('referral_code', isEqualTo: referralCode);
    }
    else{
      query = commands
          .where('referral_code', isEqualTo: referralCode)
          .where('cpm_trans_date', isGreaterThan: lastPaymentDate);
    }

    double total = 0.0;
    final snapshot = await query.get();
    final int count = snapshot.docs.length;

    for(final doc in snapshot.docs){
      final data = doc.data() as Map<String, dynamic>?;
      final dynamic raw = data?['cpm_amount'];
      double amount = double.tryParse(raw) ?? 0.0;

      total += amount;
    }

    return{
      'count': count,
      'total': total * 0.10
    };
  }

  Future<Map<String, dynamic>?> getUserById(String docId, String env) async {
    CollectionReference users = FirebaseFirestore.instance.collection(env == "Prod" ? 'users': "usersDev");

    try{
      DocumentSnapshot userDoc = await users.doc(docId).get();
      if(userDoc.exists){
        return userDoc.data() as Map<String, dynamic>;
      }
      else{
        return null;
      }
    }
    catch(e){
      return null;
    }
  }

  Future getDocumentsByIds(List<String> docIds) async {

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await firestore
        .collection("productsProd")
        .where(FieldPath.documentId, whereIn: docIds)
        .get();

    return querySnapshot.docs;
  }
}
