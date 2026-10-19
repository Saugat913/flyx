enum AppRoute {
  onboarding('/onboarding'),


  home('/'),
  transfer('/transfer'),
  setting('/setting'),

  //Send features
  fileSelector('/file-selector'),
  shareCode('/share-code'),
  discoverReceiver('/discover-receiver'),

  transferModeSelection('/transfer-mode-selection');

  const AppRoute(this.path);
  final String path;
}
