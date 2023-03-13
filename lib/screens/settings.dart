import 'package:flutter/material.dart';
import 'package:flutter_movie/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Home.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localTheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 150,
                child: Center(
                  child: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // create a ListTile with an avatar of logged in user , username and email ,and logout button

                      SizedBox(
                        height: 32,
                        child: Text(
                          "General",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),


                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.moon,
                        ),
                        title: const Text('Dark Mode'),
                        subtitle: const Text(
                          'Coming soon, stay tuned!',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: Switch(
                          value: false,
                          onChanged: (bool value) {
                            // TODO implement dark mode toggle
                          },
                        ),
                      ),

                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const Home()));
                        },
                        leading: const FaIcon(
                          FontAwesomeIcons.chartPie,
                        ),
                        title: const Text('Categories'),
                        subtitle: const Text(
                          'Manage product categories',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),

                      const Divider(),
                      SizedBox(
                        height: 32,
                        child: Text(
                          "Other settings",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
/*
                      ListTile(
                        leading: FaIcon(
                          FontAwesomeIcons.lock,
                          color: primaryColor,
                        ),
                        title: const Text('Security'),
                        subtitle: const Text(
                          'Protect your account with fingerprint',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),*/

                      const ListTile(
                        leading: FaIcon(
                          FontAwesomeIcons.shieldHalved,
                        ),
                        title: Text('Password'),
                        subtitle: Text(
                          'Change your password,This feature is coming soon',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.circleInfo,
                        ),
                        title: const Text('About'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const Home()));
                        },
                        subtitle: const Text(
                          'Learn more about us',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
