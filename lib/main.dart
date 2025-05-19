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
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BatteryMonitorPage(title: 'Monitor de Batería'),
    );
  }
}

class BatteryMonitorPage extends StatefulWidget {
  const BatteryMonitorPage({super.key, required this.title});

  

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
  
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
     
        title: Text(widget.title),
      ),
      body: Center(
        
        child: Column(
          
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
