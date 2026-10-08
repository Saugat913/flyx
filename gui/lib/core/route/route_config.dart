enum AppRoute {
  onboarding('/onboarding'),
  home('/'),
  transfer('/transfer'),
  setting('/setting');

  const AppRoute(this.path);
  final String path;
}
