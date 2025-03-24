import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Not implemented',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          ElevatedButton(
            onPressed: () {},
            // style: ElevatedButton.styleFrom(
            //   backgroundColor: Colors.black,
            // ),
            child: const Text("Νέο παιχνίδι"),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Συνέχισε παλιό παιχνίδι"),
          ),
        ],
      ),
    );
  }
}
