import 'package:banking/pages/scan/qr_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '/utils/constants.dart';
import '../card/card_page.dart';
import '../dashboard/dashboard_page.dart';
import '../profile/profile_page.dart';
// import '../wallet/wallet_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  _NavigationPageState createState() => _NavigationPageState();
}


class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardPage(),
    // WalletPage(),
    CardPage(),
    ProfilePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.dashboard,
                color: _selectedIndex == 0 ? primaryColor : navigationIconColor,
              ),
              label: 'Dashboard',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(
            //     Icons.wallet,
            //     color: _selectedIndex == 1 ? primaryColor : navigationIconColor,
            //   ),
            //   label: 'Wallet',
            // ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.credit_card_outlined,
                color: _selectedIndex == 1 ? primaryColor : navigationIconColor,
              ),
              label: 'Card',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline_outlined,
                color: _selectedIndex == 2 ? primaryColor : navigationIconColor,
              ),
              label: 'Profile',
            ),
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: primaryColor,
          iconSize: 24,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal, color: Colors.black),
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          onTap: _onItemTapped,
          elevation: 5),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: SvgPicture.asset('assets/svg/scan_icon.svg'),
        onPressed: () {
          // Navigator.of(context).pushNamed(
          //   RouteGenerator.scanPage,
          // );
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScanPage()),
            );
        },
      ),
    );
  }
}
