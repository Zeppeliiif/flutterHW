import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'about.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CalculatorPage(title: '20221060061 李子佩 计算器'),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key, required this.title});
  final String title;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '';

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        try {
          Parser p = Parser();
          Expression exp = p.parse(
            _expression.replaceAll('×', '*').replaceAll('÷', '/'),
          );
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          _result = '= $eval';
        } catch (e) {
          _result = '错误';
        }
      } else {
        _expression += value;
      }
    });
  }

  Widget _buildButton(String text, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 22),
          ),
          onPressed: () => _onPressed(text),
          child: Text(text, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions),
            tooltip: 'Emoji小游戏',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.centerRight,
              child: Text(_expression, style: const TextStyle(fontSize: 28)),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                _result,
                style: const TextStyle(fontSize: 24, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('/', color: Colors.orange),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('*', color: Colors.orange),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('-', color: Colors.orange),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('0'),
                      _buildButton('.'),
                      _buildButton('C', color: Colors.red),
                      _buildButton('+', color: Colors.orange),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('(', color: Colors.grey),
                      _buildButton(')', color: Colors.grey),
                      _buildButton('⌫', color: Colors.grey),
                      _buildButton('=', color: Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
