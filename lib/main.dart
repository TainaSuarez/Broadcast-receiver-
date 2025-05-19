import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitor de Batería',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BatteryMonitorPage(title: 'Monitor de Batería'),
    );
  }
}

class BatteryMonitorPage extends StatefulWidget {
  const BatteryMonitorPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<BatteryMonitorPage> createState() => _BatteryMonitorPageState();
}

class _BatteryMonitorPageState extends State<BatteryMonitorPage> {
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  late StreamSubscription<BatteryState> _batteryStateSubscription;
  late Timer _batteryLevelTimer;
  bool _hasShownWarning = false;

  @override
  void initState() {
    super.initState();
    
    // Inicializar el nivel de batería
    _getBatteryLevel();
    
    // Configurar un temporizador para actualizar el nivel de batería periódicamente
    _batteryLevelTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _getBatteryLevel();
    });
    
    // Suscribirse a los cambios de estado de la batería
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      // Cuando cambia el estado de la batería, actualizar el nivel
      _getBatteryLevel();
    });
  }

  Future<void> _getBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;
    
    setState(() {
      _batteryLevel = batteryLevel;
    });
    
    // Mostrar advertencia si el nivel de batería es bajo y no se ha mostrado aún
    if (_batteryLevel <= 20 && !_hasShownWarning) {
      _showLowBatteryWarning();
      _hasShownWarning = true;
    } else if (_batteryLevel > 20) {
      // Resetear la bandera cuando la batería sube por encima del 20%
      _hasShownWarning = false;
    }
  }

  void _showLowBatteryWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Advertencia! El nivel de batería está por debajo del 20%'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _batteryStateSubscription.cancel();
    _batteryLevelTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Nivel actual de batería:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              '$_batteryLevel%',
              style: TextStyle(
                fontSize: 48, 
                fontWeight: FontWeight.bold,
                color: _batteryLevel <= 20 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            Icon(
              Icons.battery_alert,
              size: 100,
              color: _batteryLevel <= 20 ? Colors.red : Colors.green,
            ),
            if (_batteryLevel <= 20)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '¡Batería baja! Por favor, conecte su dispositivo a un cargador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
