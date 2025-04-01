import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = "";
  String _result = "";

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _expression = "";
        _result = "";
      } else if (value == "=") {
        try {
          Parser p = Parser();
          Expression exp = p.parse(_expression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          _result = eval.toString();
        } catch (e) {
          _result = "Invalid input!";
        }
      } else {
        _expression += value == "x" ? "*" : value;
      }
    });
  }

  Widget _buildButton(String text) {
    Color buttonColor = text == "="
        ? Colors.orange
        : (text == "+" || text == "-" || text == "*" || text == "/" || text == "C") ? Colors.grey[200]! : Colors.white!;

    Color buttonTextColor = text == "=" ? Colors.white : Colors.black;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(30),
            backgroundColor: buttonColor,
          ),
          child: Text(text, style: TextStyle(fontSize: 14, color: buttonTextColor, fontWeight: FontWeight.normal)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(16),
              color: Colors.black,
              child: Text(
                _expression,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
          ),

          Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.only(left: 16, right: 16, top:0,bottom: 0 ),
              color: Colors.black,
              child: Text(
                _result,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
          ),
          Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildButton("7"), _buildButton("8"), _buildButton("9"), _buildButton("x")
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton("4"), _buildButton("5"), _buildButton("6"), _buildButton("/")
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton("1"), _buildButton("2"), _buildButton("3"), _buildButton("+")
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton("="), _buildButton("0"), _buildButton("C"), _buildButton("-")
                    ],
                  ),
                ],
              ),
          )
        ],
      ),
    );
  }
}
