import '../services/api.dart';
import '../services/utilities.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  var user;
  String gain = "";
  String code = "";
  String info = "";
  String numberPayment = "";
  String numberInvitation = "";
  String env = "Choisissez l'environnement";
  var envs = ["Choisissez l'environnement", 'Dev', 'Prod'];
  TextEditingController userIdController = TextEditingController();

  void getUser()async{
    String userId = userIdController.text;
    user = await Api().getUserById(userId);

    if(user != null){
      code = Utilities().generateCodeFromAuthId(user?["auth_id"]);
      getNumbers();
      getReferralEarnings();
    }
  }

  void getNumbers()async{
    String lastPaymentDate = user["last_payment_date"] ?? "";
    int value = await Api().getInvitedUsersCount(env, lastPaymentDate, code);
    setState(() {
      numberInvitation = value.toString();
    });
  }

  void getReferralEarnings()async{
    String lastPaymentDate = user["last_payment_date"] ?? "";
    Map<String, dynamic> value = await Api().getReferralEarnings(env, lastPaymentDate, code);
    setState(() {
      gain = value["total"].toString();
      numberPayment = value["count"].toString();
    });
  }

  void updatePaymentDate()async{
    String userId = userIdController.text;
    bool response = await Api().updatePaymentDate(env, userId);

    setState(() {
      if(response){
        info = "effectué avec succès";
      }
      else{
        info = "Erreur lors de l'operation";
      }
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
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                DropdownButtonFormField(
                    value: env,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: "Environnement",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        )
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: envs.map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        env = newValue!;
                      });
                    },
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Ce champ est obligatoire';
                      }
                      return null;
                    }
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                          cursorColor: Colors.black,
                          controller: userIdController,
                          decoration: const InputDecoration(
                              labelText: "Id de l'utilisateur",
                              labelStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder()
                          ),
                          validator: (value){
                            if(value == null || value.isEmpty){
                              return 'Ce champ est obligatoire';
                            }
                            return null;
                          }
                      )
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: getUser,
                        icon: const Icon(Icons.search_rounded)
                    )
                  ]
                ),
                const SizedBox(height: 10),
                Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                            children: [
                              Row(
                                  children: [
                                    Expanded(
                                        child: _statCard("Invitations", numberInvitation, Icons.group_add)
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: _statCard("Achats", numberPayment, Icons.shopping_bag)
                                    )
                                  ]
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                  width: double.infinity,
                                  child: _statCard("Vos gains", "$gain FCFA", Icons.payments)
                              )
                            ]
                        )
                    )
                ),
                const SizedBox(height: 10),
                Text(
                    info,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    )
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: TextButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              const Color(0xffec4899)
                          ),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              )
                          )
                      ),
                      onPressed: updatePaymentDate,
                      child: const Text(
                          "Valider le paiement",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          )
                      )
                  )
                )
              ]
          )
        )
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(icon, color: const Color(0xffec4899), size: 20)
                  ),
                  const SizedBox(height: 8),
                  Text(
                      label,
                      style: TextStyle(color: Colors.grey[700])
                  ),
                  const SizedBox(height: 2),
                  Text(
                      value,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      )
                  )
                ]
            )
        )
    );
  }
}