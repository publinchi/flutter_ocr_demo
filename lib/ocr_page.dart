
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';


class OCRPage extends StatefulWidget {
  @override
  _OCRPageState createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> {

  int _ocrCamera = FlutterMobileVision.CAMERA_BACK;
  String _text = "TEXT";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('OCR In Flutter'),
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_text,style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              ),
              Center(
                child: RaisedButton(
                  onPressed: _read,
                  child: Text('Scanning',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> _read() async {
    List<OcrText> texts = [];
    try {
      texts = await FlutterMobileVision.read(
        camera: _ocrCamera,
        waitTap: true,
        showText: false,
        multiple: true,
      );

      setState(() {
        _text = "";
        texts.forEach((element) {
          var _curp = CURP.curpValida(element.value);
          if(_curp != null) {
            _text = _curp;
            return;
          }
        });
      });
    } on Exception {
      texts.add(OcrText('Failed to recognize text'));
    }
  }
}

class CURP {
  static String curpValida(String curp) {
    var re = new RegExp(r"[A-Z]{1}[AEIOU]{1}[A-Z]{2}[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])[HM]{1}(AS|BC|BS|CC|CS|CH|CL|CM|DF|DG|GT|GR|HG|JC|MC|MN|MS|NT|NL|OC|PL|QT|QR|SP|SL|SR|TC|TS|TL|VZ|YN|ZS|NE)[B-DF-HJ-NP-TV-Z]{3}[0-9A-Z]{1}[0-9]{1}",
      caseSensitive: false,
      multiLine: true,
    );

    var validado = re.allMatches(curp);

    var matches = validado.toList();
    if (matches.length == 0) {  //Coincide con el formato general?
      print("CURP No matches with RegEx");
      return null;
    }

    String _curp = re.stringMatch(curp);

    var digitVerif = double.parse(_curp[17]).toString();
    var digitoVerifCalculado = digitoVerificador(_curp).toString();

    if (digitoVerifCalculado != digitVerif) {
      print("Digito verificador CURP digito: " + digitoVerifCalculado + " calculado: " + digitVerif.toString());
      return null;
    }

    return _curp;
  }

  //Validar que coincida el dígito verificador
  static digitoVerificador(curp17) {
    //Fuente https://consultas.curp.gob.mx/CurpSP/
    var diccionario  = "0123456789ABCDEFGHIJKLMNÑOPQRSTUVWXYZ",
        lngSuma      = 0.0,
        lngDigito    = 0.0;
    for(var i=0; i<17; i++)
      lngSuma = lngSuma + diccionario.indexOf(curp17[i]) * (18 - i);
    lngDigito = 10 - lngSuma % 10;
    if (lngDigito == 10) return 0;
    return lngDigito;
  }
}