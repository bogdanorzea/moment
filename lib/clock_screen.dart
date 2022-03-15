import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockScreen extends StatelessWidget {
  const ClockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<void>(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, _) {
          return Align(
            alignment: const Alignment(0, 1 / 3),
            child: Text(
              DateFormat('hh:mm:ss a').format(DateTime.now()),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 48,
                fontFeatures: <FontFeature>[
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
