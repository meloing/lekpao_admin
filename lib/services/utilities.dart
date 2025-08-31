import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:file_picker/file_picker.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class MarkDown{
  Widget myMarkDown(String text){
    return Padding(
        padding: const EdgeInsets.all(10),
        child: MarkdownBody(
            data: text,
            styleSheet: Constants.myStyleSheet,
            builders: <String, MarkdownElementBuilder>{
              'border': BorderBuilder(),
              'bggrey': BgGreyBuilder()
            },
            blockSyntaxes: [
              BorderLockSyntax(),
              BgGreyLockSyntax()
            ]
        )
    );
  }

  Widget body(course, path){
    List courses = course.split("|||");
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: courses.asMap().entries.map(
              (item) => Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              child: body2(item.value, path)
          ),
        ).toList()
    );
  }

  Widget body2(course, path){
    List courses = course.split("||");
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: courses.asMap().entries.map(
              (item) => design(item.value, path),
        ).toList()
    );
  }

  Widget design(text, path){
    text = text.trim();
    if(text.startsWith('[border]')){
      return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
              color: Color(0xff1f71ba)
          ),
          child: Text(
              text.replaceAll("[border]", "").toUpperCase(),
              textAlign: TextAlign.left,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              )
          )
      );
    }
    else if(text.startsWith('[bggrey]')){
      String t = text.replaceAll("[bggrey]", "");
      return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              color: Colors.grey
          ),
          child: Text(
              t.toUpperCase(),
              textAlign: TextAlign.left,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              )
          )
      );
    }
    else if(text.startsWith('[bord]')){
      String t = text.replaceAll("[bord]", "").replaceAll("[/bord]", "");
      return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color(0xfff29200)
              )
          ),
          child: textDesign(t)
      );
    }
    else if(text.startsWith('[li]')){
      String t = text.replaceAll("[li]", "");
      return Row(
          children: [
            const Icon(
                Icons.play_arrow,
                color: Color(0xfff29200)
            ),
            Expanded(child: textDesign(t))
          ]
      );
    }
    else if(text.startsWith('[bu]')){
      String t = text.replaceAll("[bu]", "");
      return Padding(
          padding: const EdgeInsets.only(top: 10, left: 0),
          child: Text(
              t,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline
              )
          )
      );
    }
    else if(text.startsWith('[img]')){
      String adr = text.replaceAll("[img]", "");
      return InteractiveViewer(
          panEnabled: true,
          minScale: 1,
          maxScale: 3,
          child: Image(
              image: NetworkImage("https://archetechnology.com/totale-reussite/coursesRessources/$adr"),
              alignment: Alignment.center,
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace){
                return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey)
                    ),
                    child: const Column(
                      children: [
                        Icon(
                            Icons.sync_rounded,
                            color: Color(0xfff29200)
                        ),
                        SizedBox(height: 5),
                        Text(
                            "Impossible de lire cette image hors ligne",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xfff29200),
                                fontWeight: FontWeight.bold
                            )
                        )
                      ],
                    )
                );
              }
          )
      );
    }
    else {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: textDesign(text)
      );
    }
  }

  Widget textDesign(String text){
    return ParsedText(
        text: text,
        alignment: TextAlign.justify,
        style:  const TextStyle(
            fontSize: 19,
            color: Colors.black
        ),
        parse: <MatchText>[
          MatchText(
            pattern: r"\[b\]([^\]|^\[]+)\[/b\]",
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            ),
            renderText: ({required pattern, required str}) {
              RegExp customRegExp = RegExp(r"\[b\]([^\]|^\[]+)\[/b\]");
              Match match = customRegExp.firstMatch(str)!;
              return {'display': match[1]!};
            },
            onTap: (url) {
            },
          ),
          MatchText(
              type: ParsedType.URL,
              style: const TextStyle(
                color: Colors.blue,
              ),
              onTap: (url) async{

              }
          )
        ]
    );
  }

  String mySanitizeLatex(String raw){
    String cleaned = raw;

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\$\$(.*?)\$\$', dotAll: true),
          (match) => '\\[${match.group(1)}\\]',
    );

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(?<!\$)\$(?!\$)(.+?)(?<!\$)\$(?!\$)', dotAll: true),
          (match) => '\\(${match.group(1)}\\)',
    );

    cleaned = cleaned.replaceAll(RegExp(r"```[a-zA-Z]*"), '');
    cleaned = cleaned.replaceAll("```", '');

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(</h1>|</h3>|</h2>|</h4>)', caseSensitive: false),
          (match) => '${match.group(0)}<br><br>',
    );

    cleaned = cleaned.replaceAll(RegExp(r'(<br>\s*){2,}'), '<br><br>');

    return cleaned.trim();
  }
}

class DownloadFile{

  Future<String> getFilePath(uniqueFileName) async {
    String path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_PICTURES);
    await Directory('$path/prepa reussite images').create(recursive: true);
    path = '$path/prepa reussite images/$uniqueFileName';
    return path;
  }

  Future downloadFile(imageUrl) async {
    try {
      Dio dio = Dio();
      String fileName = imageUrl.substring(imageUrl.lastIndexOf("/") + 1);
      String savePath = await getFilePath(fileName);

      if(!await File(savePath).exists()){
        await dio.download(imageUrl, savePath, onReceiveProgress: (rec, total) {} );
      }
    }
    catch (_) {}
  }

  Future deleteFile(image) async {
    try {
      String path = await getFilePath(image);
      if(await File(path).exists()){
        await File(path).delete();
      }
    }
    catch (_) {}
  }
}

class Utilities{
  List elements = [
    {
      "name": "border",
      "value": "\n\n[border]",
    },
    {
      "name": "bggrey",
      "value": "\n[bggrey]",
    },
    {
      "name": "h1",
      "value": "\n\n#",
    },
    {
      "name": "h2",
      "value": "##",
    },
    {
      "name": "h3",
      "value": "###",
    },
    {
      "name": "h4",
      "value": "####",
    },
    {
      "name": "h5",
      "value": "#####",
    },
    {
      "name": "h6",
      "value": "######",
    },
    {
      "name": "Italic",
      "value": "*ecrire ici*",
    },
    {
      "name": "Bold",
      "value": "**ecrire ici**",
    },
    {
      "name": "Link",
      "value": "[Link](http://a.com)",
    },
    {
      "name": "Image",
      "value": "![Image](http://url/a.png)",
    },
    {
      "name": "Quote",
      "value": "> mettre ici",
    },
    {
      "name": "Liste à puce",
      "value": "-",
    },
    {
      "name": "Liste à ordonnée",
      "value": "1.",
    },
    {
      "name": "Diviseur horizontal",
      "value": "---",
    },
    {
      "name": "Inline code",
      "value": "`Inline code`"
    },
    {
      "name": "Diviseur horizontal",
      "value": "```block here ```",
    },
    {
      "name": "br",
      "value": "\n[br]\n",
    }
  ];

  final myStyleSheet = MarkdownStyleSheet(
      h1: const TextStyle(
          fontSize: 25,
          color: Colors.black,
          fontWeight: FontWeight.bold
      ),
      h2: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      p: const TextStyle(
          fontSize: 18,
          color: Colors.black
      ),
      a: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline
      )
  );

  Widget markdownWidget(void Function(String) function){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              color: Colors.grey
          )
      ),
      child: Wrap(
          spacing: 5,
          runSpacing: 5,
          children: elements.map(
                  (e) => TextButton(
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
                    function(e["value"]);
                  },
                  child: Text(
                      e["name"],
                      style: const TextStyle(
                          color: Colors.white
                      )
                  )
              )
          ).toList()
      ),
    );
  }

  Future<String> loadImages(String type) async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowCompression: true,
        allowedExtensions: ["png", "jpg", "jpeg"]
    );

    if(result?.files.first != null){
      var fileBytes = result?.files.first.bytes;
      var fileName = DateTime.now().toString().replaceAll(".", "")
          .replaceAll(" ", "").replaceAll("-", "").replaceAll(":", "");

      String fileUrl = await (
          await FirebaseStorage.instance.ref().child('ressources/$fileName')
              .putData(fileBytes!)
              .whenComplete(() => null)).ref.getDownloadURL();

      if(type != "html"){
        fileUrl = Utilities().changeUrl(fileUrl);
      }

      return fileUrl;
    }
    return "";
  }

  String changeUrl(String url){
    int lastIndex = url.lastIndexOf("/");
    String baseUrl = url.substring(0, lastIndex+1);
    String value = url.substring(lastIndex+1);

    List splitter = value.split("token=");
    String base = "bucket${splitter[0]}";
    return "$baseUrl${base}token=${splitter[1].split('').reversed.join()}";
  }

  String changeInMark(String text){
    String result = "$text ||";
    String pattern = r'\[img\](.*?)\s*\|\|';
    String replacementText = "![image](\$1)";

    RegExp regex = RegExp(pattern);
    result = result.replaceAllMapped(regex, (match) {
      return replacementText.replaceAll("\$1", match.group(1)!);
    });

    result = result.replaceAll("||", "");
    result = result.replaceAll("[li]", "- ");
    result = result.replaceAll("[b]", "**");
    result = result.replaceAll("[/b]", "**");

    return result;
  }

  Future<String> createDynamicLink(String pseudo) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://archetechnology.page.link/',
        link: Uri.parse('https://archetechnology.page.link/$pseudo'),
        androidParameters: const AndroidParameters(
          packageName: 'com.archetechnology.taktik',
          minimumVersion: 0,
        ),
        iosParameters: const IOSParameters(
            bundleId: 'com.archetechnology.taktik',
            minimumVersion: '0'
        )
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }

  Future remoteConfigValue(String part) async{
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
            fetchTimeout: const Duration(minutes: 1),
            minimumFetchInterval: const Duration(minutes: 1)
        )
    );
    await remoteConfig.setDefaults(const {
      "subSubjects": "{}"
    });

    try{
      await remoteConfig.fetchAndActivate();
    }
    catch (_) {}

    if(part == "subSubjects"){
      return jsonDecode(remoteConfig.getString("subSubjects"));
    }
  }

  String generateCodeFromAuthId(authId) {
    final prefix = authId.substring(0, 3).toUpperCase();
    final suffix = authId.substring(authId.length - 3).toUpperCase();
    return 'KPAO-$prefix$suffix'.toLowerCase();
  }
}

class BorderLockSyntax extends md.BlockSyntax {
  static const String _pattern = r'^\[border\](.*)$';
  @override
  RegExp get pattern => RegExp(_pattern);

  BorderLockSyntax();

  @override
  md.Node parse(md.BlockParser parser) {
    var childLines = parseChildLines(parser);
    var content = childLines[0]?.content.replaceAll("[border]", "");

    final md.Element el = md.Element('p', [
      md.Element('border', [md.Text(content!)]),
    ]);

    return el;
  }
}

class BorderBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(builder: (context) {
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.blue.shade100
          ),
          child: Text(
              element.textContent,
              style: const TextStyle(
                  fontWeight: FontWeight.bold
              )
          )
      );
    });
  }
}

class BgGreyLockSyntax extends md.BlockSyntax {
  static const String _pattern = r'^\[bggrey\](.*)$';
  @override
  RegExp get pattern => RegExp(_pattern);

  BgGreyLockSyntax();

  @override
  md.Node parse(md.BlockParser parser) {
    var childLines = parseChildLines(parser);
    var content = childLines[0]?.content.replaceAll("[bggrey]", "");

    final md.Element el = md.Element('p', [
      md.Element('bggrey', [md.Text(content!)]),
    ]);

    return el;
  }
}

class BgGreyBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(builder: (context) {
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[200]
          ),
          child: Text(
              element.textContent,
              style: const TextStyle(
                  color: Color(0xff0b65c2),
                  fontWeight: FontWeight.bold
              )
          )
      );
    });
  }
}

class Constants{
  static final myStyleSheet = MarkdownStyleSheet(
      textAlign: WrapAlignment.spaceBetween,
      p: const TextStyle(
          fontSize: 18
      )
  );

  static final topicDetails = {
    "cp1": {},
    "cp2": {},
    "ce1": {},
    "ce2": {},
    "cm1": {},
    "cm2": {},
    "6eme": {},
    "5eme": {},
    "4eme": {},
    "3eme": {
      "maths": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "CALCUL LITTERAL",
        "PROPRIETES DE THALES",
        "RACINES CARREES",
        "TRIANGLE RECTANGLE",
        "CALCUL NUMERIQUE",
        "ANGLES INSCRITS",
        "VECTEURS",
        "EQUATIONS ET INEQUATIONS DANS R",
        "COORDONNEES D'UN VECTEUR",
        "EQUATIONS DE DROITES",
        "STATISTIQUES",
        "EQUATIONS ET INEQUATIONS DANS R X R",
        "APPLICATIONS AFFINES",
        "PYRAMIDE ET CÔNE"
      ],
      "pc": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "MASSE ET POIDS",
        "LES FORCES",
        "ÉQUILIBRE D’UN SOLIDE SOUMIS A DEUX FORCES",
        "TRAVAIL ET PUISSANCE MÉCANIQUES",
        "ÉNERGIE MÉCANIQUE",
        "ELECTROLYSE ET SYNTHESE DE L’EAU",
        "LES ALCANES",
        "LES LENTILLES",
        "LES DÉFAUTS DE L’ŒIL ET LEURS CORRECTIONS",
        "OXYDATION DES CORPS PURS SIMPLES",
        "RÉDUCTION DES OXYDES",
        "SOLUTIONS ACIDES, BASIQUES ET NEUTRES",
        "LE CONDUCTEUR OHMIQUE",
        "PUISSANCE ET ENERGIE ELECTRIQUES"
      ],
      "svt": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "LES ALIMENTS ET L'HOMME",
        "LA DIGESTION DES ALIMENTS",
        "LE SANG",
        "LA PROTECTION ET L'AMELIORATION DES SOLS",
        "LA DEGRADATION DU SOL",
        "LES RELATIONS SOLS PLANTES",
        "LES CARACTERISTIQUES DES SOLS",
        "L'INFECTION AU VIH",
        "LA CIRCULATION SANGUINE",
        "LA TRANSFUSION SANGUINE"
      ],
      "hg": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "ETUDE ECONOMIQUE DE L'AFRIQUE",
        "LES PROBLEMES DU DEVELOPPEMENT ECONOMIQUE DE LA CÔTE D'IVOIRE",
        "LES SECTEURS D'ACTIVITES ECONOMIQUES DE LA CÔTE D'IVOIRE",
        "LES ATOUTS NATURELS ET HUMAINS DU DEVELOPPEMENT ECONOMIQUE DE LA CÔTE D'IVOIRE",
        "LES CAUSES, CARACTERES ET CONSEQUENCES DE LA DEUXIEME GUERRE MONDIALE",
        "CAUSES ET CARACTERES DES CRISES SOCIOPOLITIQUES DE L'AFRIQUE INDEPENDANTE",
        "L'ACCESSION DE LA CÔTE D'IVOIRE A L'INDEPENDANCE",
        "LE MOUVEMENT IMPERIALISTE ET LA COLONISATION EN CÔTE D'IVOIRE",
        "L’UNION AFRICAINE (UA)",
        "LA PLACE DE L’AFRIQUE DANS LA MONDIALISATION",
        "L’ORGANISATION DES NATIONS UNIES (ONU)"
      ],
      "edhc": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "LES DEVOIRS DE PARENTS ET L’EPANOUISSEMENT DE L’ENFANT",
        "LES ORGANISATIONS HUMANITAIRES ET L’ASSISTANCE AUX POPULATIONS EN DETRESSE",
        "LES INSTRUMENTS ET LES MECANISMES JURIDIQUES ET LA LUTTE CONTRE LES VIOLENCES FAITES AUX PERSONNES VULNERABLES",
        "LES PARTIS POLITIQUES ET LES INSTITUTIONS DE LA REPUBLIQUE  ET LA PRESERVATION DE LA PAIX SOCIALE",
        "LE VOTE ET LA PARTICIPATION DU CITOYEN A LA VIE DE LA NATION",
        "L’IMPÔT ET LE DEVELOPPEMENT DE LA NATION",
        "L’UTILISATION RATIONNELLE DES BIENS PUBLICS ET LE DEVELOPPEMENT DU PAYS",
        "LE PROJET D’ENTREPRISE ET L’INSERTION SOCIALE",
        "LES ALLIANCES INTERETHNIQUES ENTRE LES PEUPLES GOUR ET LES PEUPLES MANDÉ ET LA COHÉSION SOCIALE",
        "LA FRÉQUENTATION DES CENTRES DE SANTÉ ET LA LUTTE CONTRE L’AUTOMÉDICATION, LES MALADIES ENDÉMIQUES ET PARASITAIRES",
        "LES BIENFAITS DU DÉPISTAGE DU VIH ET LA GESTION DE LA VIE",
        "LA PROTECTION DES PARCS NATIONAUX ET DES RÉSERVES FORESTIÈRES ET LA SAUVEGARDE DE L’ENVIRONNEMENT",
        "LA GESTION RATIONNELLE DE L’EAU ET LA SAUVEGARDE DE LA PAIX  SOCIALE"
      ],
      "art": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "fr": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "mus": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "ang": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "all": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "esp": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ]
    },
    "seca": {},
    "secc": {},
    "1erea": {},
    "1erec": {},
    "1ered": {},
    "tlea": {
      "maths": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "pc": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "philo": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "hg": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "Les fondements du développement économique de la Côte d'Ivoire",
        "Les secteurs d'activités économiques de la Côte d'Ivoire",
        "Les problèmes de développement économique de la Côte d'Ivoire",
        "Les fondements du développement économique de la corée du Sud",
        "La CEDEAO une organisation régionale à caractère économique",
        "Les relations UE-ACP un exemple de coopération Nord-Sud",
        "L'Organisation des Nations Unies(ONU)",
        "L'ère de la bipolarisation de 1947 à 1991",
        "De la fin de la guerre froide vers un monde multipolaire",
        "la montée des nationalismes",
        "L'Accession de la Côte d'Ivoire à l'indépendance",
        "L'accession de l'Algérie à l'indépendance",
        "L' Union Africaine",
        "Croyances et valeurs dominantes dans le monde Occidental",
        "Les mutations contemporaines de la civilisation négro africaine"
      ],
      "all": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "esp": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "ang": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ]
    },
    "tlec": {
      "maths": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "LIMITES ET CONTINUITE",
        "PROBABILITE",
        "DERIVABILITE ET ETUDE DE FONCTIONS",
        "PRIMITIVES",
        "FONCTIONS LOGARITHMES",
        "NOMBRES COMPLEXES",
        "FONCTION EXPONENTIELLE ET FONCTION PUISSANCE",
        "NOMBRES COMPLEXES ET GEOMETRIE DU PLAN",
        "SUITES NUMERIQUES",
        "CALCUL INTEGRAL",
        "STATISTIQUES",
        "EQUATIONS DIFFERENTIELLES"
      ],
      "pc": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "svt": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "philo": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS"
      ],
      "hg": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "Les fondements du développement économique de la Côte d'Ivoire",
        "Les secteurs d'activités économiques de la Côte d'Ivoire",
        "Les problèmes de développement économique de la Côte d'Ivoire",
        "Les fondements du développement économique de la corée du Sud",
        "La CEDEAO une organisation régionale à caractère économique",
        "Les relations UE-ACP un exemple de coopération Nord-Sud",
        "L'Organisation des Nations Unies(ONU)",
        "L'ère de la bipolarisation de 1947 à 1991",
        "De la fin de la guerre froide vers un monde multipolaire",
        "la montée des nationalismes",
        "L'Accession de la Côte d'Ivoire à l'indépendance",
        "L'accession de l'Algérie à l'indépendance",
        "L' Union Africaine",
        "Croyances et valeurs dominantes dans le monde Occidental",
        "Les mutations contemporaines de la civilisation négro africaine"
      ]
    },
    "tled": {
      "maths": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "LIMITES ET CONTINUITE",
        "PROBABILITE",
        "DERIVABILITE ET ETUDE DE FONCTIONS",
        "PRIMITIVES",
        "FONCTIONS LOGARITHMES",
        "NOMBRES COMPLEXES",
        "FONCTION EXPONENTIELLE ET FONCTION PUISSANCE",
        "NOMBRES COMPLEXES ET GEOMETRIE DU PLAN",
        "SUITES NUMERIQUES",
        "CALCUL INTEGRAL",
        "STATISTIQUES",
        "EQUATIONS DIFFERENTIELLES"
      ],
      "pc": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "LES ALCOOLS",
        "COMPOSES CARBONYLES : ALDEHYDES ET CETONES",
        "LES AMINES",
        "ACIDES CARBOXYLIQUES ET DERIVES",
        "FABRICATION D'UN SAVON",
        "SOLUTIONS AQUEUSES-NOTION DE pH",
        "ACIDE FORT BASE FORTE",
        "ACIDE FAIBLE BASE FAIBLE",
        "COUPLE ACIDE/BASE CLASSIFICATION",
        "REACTIONS ACIDOBASIQUES. SOLUTIONS TAMPONS",
        "DOSAGE ACIDO-BASIQUE",
        "ACIDES ALPHA AMINES",
        "CINEMATIQUE DU POINT",
        "MOUVEMENT DU CENTRE D'INERTIE D'UN SOLIDE",
        "INTERACTION GRAVITATIONNELLE",
        "MOUVEMENT DANS LES CHAMPS G ET E UNIFORMES",
        "OSCILLATIONS MECANIQUES LIBRES",
        "CHAMP MAGNETIQUE",
        "LOI DE LAPLACE",
        "INTRODUCTION ELECTROMAGNETIQUE",
        "AUTO INDUCTION",
        "MONTAGNES DERIVATEUR ET INTEGRATEUR",
        "CIRCUIT RLC EN REGIME SINUSOIDAL FORCE",
        "RESONANCES EN COURANT ALTERNATIF",
        "PUISSANCE EN COURANT ALTERNATIF",
        "MODELE ONDULATOIRE DE LA LUMIERE",
        "MODELE CORPUSCULAIRE LUMIERE",
        "REACTIONS NUCLEAIRES SPONTANEES",
        "REACTIONS NUCLEAIRES PROVOQUEES"
      ],
      "svt": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "Le reflexe conditionnel",
        "Le fonctionnement du  tissu nerveux",
        "Le fonctionnement du muscle strié squelettique",
        "Le fonctionnement du coeur",
        "Le maintien de la constance du milieu intérieur",
        "Le système de défense de l'organisme",
        "L'INFECTION DE L'ORGANISME PAR LE VIH",
        "Le devenir des cellules sexuelles chez les mammifères",
        "Le fonctionnement des organes sexuels chez l'Homme",
        "La reproduction chez les spermaphytes",
        "La transmission d'un caractère héréditaire chez l'Homme",
        "La transmission de deux caractères héréditaires chez les êtres vivants",
        "La mise en place des gisements miniers en Côte d'Ivoire",
        "L'exploitation des gisements miniers",
        "L'amélioration et la protection des sols"
      ],
      "hg": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "Les fondements du développement économique de la Côte d'Ivoire",
        "Les secteurs d'activités économiques de la Côte d'Ivoire",
        "Les problèmes de développement économique de la Côte d'Ivoire",
        "Les fondements du développement économique de la corée du Sud",
        "La CEDEAO une organisation régionale à caractère économique",
        "Les relations UE-ACP un exemple de coopération Nord-Sud",
        "L'Organisation des Nations Unies(ONU)",
        "L'ère de la bipolarisation de 1947 à 1991",
        "De la fin de la guerre froide vers un monde multipolaire",
        "la montée des nationalismes",
        "L'Accession de la Côte d'Ivoire à l'indépendance",
        "L'accession de l'Algérie à l'indépendance",
        "L' Union Africaine",
        "Croyances et valeurs dominantes dans le monde Occidental",
        "Les mutations contemporaines de la civilisation négro africaine"
      ],
      "philo": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "La dissertation philosophique",
        "Le commentaire de texte philosophique",
        "La connaissance de l'homme",
        "La vie en société",
        "Dieu et la religion",
        "L'histoire et l'humanité",
        "La valeur de la philosophie",
        "Progrès et Bonheur",
        "Langage et Vérité",
        "La Connaissance scientifique"
      ]
    },
    "cafop": {
      "maths": [
        "SUJETS D'EXAMENS",
        "SUJETS TYPES EXAMENS",
        "CALCUL LITTERAL",
        "PROPRIETES DE THALES",
        "RACINES CARREES",
        "TRIANGLE RECTANGLE",
        "CALCUL NUMERIQUE",
        "ANGLES INSCRITS",
        "VECTEURS",
        "EQUATIONS ET INEQUATIONS DANS R",
        "COORDONNEES D'UN VECTEUR",
        "EQUATIONS DE DROITES",
        "STATISTIQUES",
        "EQUATIONS ET INEQUATIONS DANS R X R",
        "APPLICATIONS AFFINES",
        "PYRAMIDE ET CÔNE"
      ],
      "cg": [
        "SUJETS DE COMPOSITION",
        "SUJETS TYPES COMPOSITION",
        "ARTS - CULTURE - SPORT",
        "LITTERATURE",
        "SCIENCES",
        "HISTOIRE",
        "GEOGRAPHIE",
        "EDHC"
      ],
      "fr": [
        "SUJETS DE COMPOSITION",
        "SUJETS TYPES COMPOSITION"
      ]
    },
    "ena": {
      "av": [
        "SUJETS DE COMPOSITION",
        "SUJETS TYPES COMPOSITION",
        "VOCABULAIRE","INTRUS",
        "ANALOGIE VERBALE",
        "PROVERBE",
        "ORTHOGRAPHE",
        "GENRE",
        "ANAGRAMME",
        "JEUX DE MOTS"
      ],
      "cg": [
        "SUJETS DE COMPOSITION",
        "SUJETS TYPES COMPOSITION",
        "ARTS - CULTURE - SPORT",
        "LITTERATURE",
        "SCIENCES",
        "HISTOIRE",
        "GEOGRAPHIE",
        "EDHC"
      ],
      "lm": [
        "SUJETS DE COMPOSITION",
        "SUJETS TYPES COMPOSITION",
        "Famille des nombres",
        "Opération de base - Priorités des opérations",
        "Calcul mental",
        "Chiffre romain",
        "Critères de divisibilité - Nombres premiers",
        "Fractions - Base et Calcul",
        "Puissance - Racine carrée",
        "Développement - Factorisation",
        "Equation 1er degré - 2 équations - inéquations",
        "Proportionnalité - Echelle d'un plan",
        "Mesure du temps - Vitesse & Débit",
        "Partages - Pourcentages",
        "Prix - Intérêt",
        "Eléments de statistiques",
        "Unité de masse - Unité de longueur - Unité d'aire",
        "Périmètre - Surface",
        "Unité de volume / capacité - Volume",
        "Densité - Unité d'angle",
        "Théorème de Thalès - Théorème de Pythagore", "Fonction"
      ],
      "ang":[
        "SUJETS DE COMPOSITION",
        "SUJETS TYPES COMPOSITION",
      ]
    },
    "infasbepc": {
      "maths": [
        "SUJETS DE COMPOSITION",
        "SUJETS TYPES COMPOSITION",
        "CALCUL LITTERAL",
        "PROPRIETES DE THALES",
        "RACINES CARREES",
        "TRIANGLE RECTANGLE",
        "CALCUL NUMERIQUE",
        "ANGLES INSCRITS",
        "VECTEURS",
        "EQUATIONS ET INEQUATIONS DANS R",
        "COORDONNEES D'UN VECTEUR",
        "EQUATIONS DE DROITES",
        "STATISTIQUES",
        "EQUATIONS ET INEQUATIONS DANS R X R",
        "APPLICATIONS AFFINES",
        "PYRAMIDE ET CÔNE"
      ],
      "cg": [
        "SUJETS DE COMPOSITION",
        "SUJETS TYPES COMPOSITION",
        "ARTS - CULTURE - SPORT",
        "LITTERATURE",
        "SCIENCES",
        "HISTOIRE",
        "GEOGRAPHIE",
        "EDHC"
      ]
    },
    "infasbac": {
      "cg": [
        "SUJETS DE COMPOSITION",
        "SUJETS TYPES COMPOSITION",
        "ARTS - CULTURE - SPORT",
        "LITTERATURE",
        "SCIENCES",
        "HISTOIRE",
        "GEOGRAPHIE",
        "EDHC"
      ]
    }
  };
}