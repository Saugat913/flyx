enum AppRoute {
  onboarding('/onboarding'),
  home('/'),
  transfer('/transfer'),
  setting('/setting'),
  fileSelector('/file-selector'),
  transferModeSelection('/transfer-mode-selection');

  const AppRoute(this.path);
  final String path;
}
