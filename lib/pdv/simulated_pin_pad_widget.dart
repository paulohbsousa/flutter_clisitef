library clisitef;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimulatedPinPadWidget extends StatefulWidget {
  final String title;
  final String options;
  final submit;
  final cancel;
  const SimulatedPinPadWidget(
      {super.key,
      this.title = "",
      this.options = "",
      this.submit,
      this.cancel});

  @override
  _SimulatedPinPadWidgetState createState() => _SimulatedPinPadWidgetState();
}

class _SimulatedPinPadWidgetState extends State<SimulatedPinPadWidget> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.26,
        child: Column(
          children: [
            Center(
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Text(
                widget.options,
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(hintText: ""),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: controller,
              ),
            ),
            TextButton(
                onPressed: () {
                  widget.submit(controller.text);
                  Navigator.of(context).pop();
                },
                child: Text('SUBMIT')),
            TextButton(
                onPressed: () {
                  widget.cancel();
                  Navigator.of(context).pop();
                },
                child: Text('CANCEL')),
          ],
        ),
      ),
    );
  }
}
