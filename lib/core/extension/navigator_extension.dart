import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../di.dart';

enum RouteTypes { cupertino, material }

Future<dynamic> push(
  Widget page, {
  RouteTypes routeType = RouteTypes.cupertino,
}) async {
  return await Navigator.push(_context, page.route(routeType));
}

Future<dynamic> pushReplacement(
  Widget page, {
  RouteTypes routeType = RouteTypes.cupertino,
}) async {
  return await Navigator.pushReplacement(_context, page.route(routeType));
}

Future<dynamic> pushAndRemoveUntil(
  Widget page, {
  RouteTypes routeType = RouteTypes.cupertino,
}) async {
  return await Navigator.pushAndRemoveUntil(
    _context,
    page.route(routeType),
    (route) => false,
  );
}

void pop({dynamic message}) => Navigator.pop(_context, message);

bool get canPop => Navigator.canPop(_context);

BuildContext get _context => mainKey.currentContext!;

extension on Widget {
  PageRoute route(RouteTypes routeType) {
    if (routeType == RouteTypes.cupertino) {
      return CupertinoPageRoute(builder: (_) => this);
    }
    return MaterialPageRoute(builder: (_) => this);
  }
}
