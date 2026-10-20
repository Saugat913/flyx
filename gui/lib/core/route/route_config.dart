enum AppRoute {
  onboarding('/onboarding'),

  home('/'),
  transfer('/transfer'),
  setting('/setting'),

  // Send features
  fileSelector('/file-selector'),
  shareCode('/share-code'),
  discoverReceiver('/discover-receiver'),
  activeTransfer('/active-transfer'),
  transferModeSelection('/transfer-mode-selection'),

  // Receive features
  receiveModeSelection('/receive-mode-selection'),
  enterCode('/enter-code'),
  waitSender('/wait-sender'),
  receiveTransfer('/receive-transfer');

  const AppRoute(this.path);
  final String path;
}
