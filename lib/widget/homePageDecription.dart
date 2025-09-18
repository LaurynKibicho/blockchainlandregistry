import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class LeftDescription extends StatelessWidget {
  const LeftDescription({Key? key}) : super(key: key);

  static final appContainer = kIsWeb
      ? html.window.document.querySelectorAll('flt-glass-pane')[0]
      : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF00796B), Color(0xFF26A69A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: const Text(
              "SECURING\nKENYA\nPROPERTY\nRIGHTS\nTOGETHER",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: Colors.white, // // //Masked by gradient
                height: 1.2,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Empowering citizens through a secure and transparent land registry system.\n"
            "Join us in transforming how Kenya protects property rights using blockchain.",
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
