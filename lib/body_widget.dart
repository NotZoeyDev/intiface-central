import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/log_widget.dart';
import 'package:intiface_central/navigation_cubit.dart';
import 'package:intiface_central/news_widget.dart';
import 'package:intiface_central/settings_widget.dart';
import 'package:intiface_central/util/intiface_util.dart';

class NavigationDestination {
  final bool Function(NavigationState state) stateCheck;
  final void Function(NavigationCubit cubit) navigate;
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final Widget Function() widgetProvider;

  NavigationDestination(this.stateCheck, this.navigate, this.icon, this.selectedIcon, this.title, this.widgetProvider);
}

class BodyWidget extends StatelessWidget {
  const BodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var destinations = [
      NavigationDestination((state) => state is NavigationStateNews, (NavigationCubit cubit) => cubit.goNews(),
          Icons.newspaper_outlined, Icons.newspaper, 'News', () => const NewsWidget()),
      NavigationDestination((state) => state is NavigationStateDevices, (NavigationCubit cubit) => cubit.goDevices(),
          Icons.vibration_outlined, Icons.vibration, 'Devices', () => const NewsWidget()),
      NavigationDestination((state) => state is NavigationStateSettings, (NavigationCubit cubit) => cubit.goSettings(),
          Icons.settings_outlined, Icons.settings, 'Settings', () => const SettingWidget()),
      NavigationDestination((state) => state is NavigationStateLogs, (NavigationCubit cubit) => cubit.goLogs(),
          Icons.text_snippet_outlined, Icons.text_snippet, 'Log', () => const LogWidget()),
      NavigationDestination((state) => state is NavigationStateAbout, (NavigationCubit cubit) => cubit.goAbout(),
          Icons.help_outlined, Icons.help, 'About', () => const NewsWidget()),
    ];

    return BlocBuilder<NavigationCubit, NavigationState>(builder: (context, state) {
      var navCubit = BlocProvider.of<NavigationCubit>(context);
      var selectedIndex = 0;
      for (var element in destinations) {
        if (element.stateCheck(state)) {
          break;
        }
        selectedIndex += 1;
      }
      if (selectedIndex >= destinations.length) {
        selectedIndex = 0;
      }

      if (isDesktop()) {
        return Expanded(
            child: Row(children: <Widget>[
          NavigationRail(
              selectedIndex: selectedIndex,
              groupAlignment: -1.0,
              onDestinationSelected: (int index) {
                destinations[index].navigate(navCubit);
              },
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map((v) => NavigationRailDestination(icon: Icon(v.icon), label: Text(v.title)))
                  .toList()),
          Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [destinations[selectedIndex].widgetProvider()]))
        ]));
      }
      return Expanded(
          child: Column(children: <Widget>[
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center, children: [destinations[selectedIndex].widgetProvider()])),
        BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (int index) {
              destinations[index].navigate(navCubit);
            },
            type: BottomNavigationBarType.fixed,
            items: destinations
                .map((dest) => BottomNavigationBarItem(
                    icon: Icon(dest.icon), activeIcon: Icon(dest.selectedIcon), label: dest.title))
                .toList())
      ]));
    });
  }
}