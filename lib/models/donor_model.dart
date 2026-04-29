class Donor {
  final String name;
  final String bloodGroup;
  final String location;
  final String phoneNumber;
  final String lastDonated;
  final bool isAvailable;

  Donor({
    required this.name,
    required this.bloodGroup,
    required this.location,
    required this.phoneNumber,
    required this.lastDonated,
    this.isAvailable = true,
  });
}
