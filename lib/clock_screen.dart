import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ClockScreen extends StatelessWidget {
  const ClockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<void>(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, _) {
          return Center(
            child: Text(
              DateFormat('hh:mm:ss').format(DateTime.now()),
              style: GoogleFonts.lato(fontSize: 48),
            ),
          );
        },
      ),
    );
  }
}
