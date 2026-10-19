class Peer {
  final String name;
  final String platform;
  final String connectionType;
  final List<List<dynamic>> icon;

  const Peer({
    required this.name,
    required this.platform,
    required this.connectionType,
    required this.icon,
  });
}