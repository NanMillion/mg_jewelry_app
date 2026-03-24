bool canAccess({
  required String role,
  required List<String> allowed,
}) {
  return allowed.contains(role);
}