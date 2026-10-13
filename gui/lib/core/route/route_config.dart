enum AppRoute {
  onboarding('/onboarding'),
  home('/'),
  transfer('/transfer'),
  setting('/setting'),
  fileSelector('/file-selector');

  const AppRoute(this.path);
  final String path;
}
