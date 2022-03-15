import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/blocs/calendars_bloc.dart';
import 'package:moment/clock_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalendarsBloc(),
      child: MaterialApp(
        title: 'Moment',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          brightness: Brightness.dark,
        ),
        home: const ClockScreen(),
      ),
    );
  }
}
