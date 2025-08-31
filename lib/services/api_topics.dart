import 'package:cloud_firestore/cloud_firestore.dart';

class TopicsRequests {

  CollectionReference topics = FirebaseFirestore.instance.collection('topics');

  Future getTopics(String level, String subject, String subSubject) async{
    QuerySnapshot querySnapshot = await topics
        .where("level", arrayContains: level)
        .where("subject", isEqualTo: subject)
        .where("sub_subject", isEqualTo: subSubject)
        .orderBy("date", descending: true)
        .get();
    final allData = querySnapshot.docs.map(
            (doc){
          Map value = doc.data() as Map;
          value['topicId'] = doc.id;
          return value;
        }
    ).toList();

    return allData;
  }

  Future addTopic(String title, List country, String subject, String date,
                  List level, String exercise, String correction, String type,
                  String docType, String subSubject, int number) async {

    Map<String, dynamic> value = {
      "env" : "Dev",
      "date" : date,
      "type" : type,
      "title" : title,
      "level" : level,
      "number" : number,
      "subject": subject,
      "doc_type": docType,
      "country" : country,
      "exercise": exercise,
      "correction": correction,
      "sub_subject": subSubject
    };

    return topics
          .add(value)
          .then((value) => true)
          .catchError((error) => false);
  }

  Future updateTopic(String title, List country, String subject, String date,
                     List level, String exercise, String correction, String type,
                     String docType, String subSubject, int number, String topicId) async {

    Map<String, dynamic> value = {
      "env" : "Dev",
      "date" : date,
      "type" : type,
      "title" : title,
      "level" : level,
      "number" : number,
      "subject": subject,
      "doc_type": docType,
      "country" : country,
      "exercise": exercise,
      "correction": correction,
      "sub_subject": subSubject
    };

    return topics
        .doc(topicId)
        .update(value)
        .then((value) => true)
        .catchError((error) => false);
  }

  Future updateStatus(String topicId, String env) async {
    return topics
        .doc(topicId)
        .update({
          "env" : env
        })
        .then((value) => true)
        .catchError((error) => false);
  }

  Future<bool> deleteDocument(String docId) async {
    try{
      await topics.doc(docId).delete();
      return true;
    }
    catch(e){
      return false;
    }
  }
}