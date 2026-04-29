class BloodRequest {
  final String id;
  final String hospitalName;
  final String bloodGroup;
  final String units;
  final String contactNumber;
  final String location;
  final String postedTime;
  final String note;
  final bool isUrgent;

  BloodRequest({
    required this.id,
    required this.hospitalName,
    required this.bloodGroup,
    required this.units,
    required this.contactNumber,
    required this.location,
    required this.postedTime,
    this.note = '',
    this.isUrgent = false,
  });
}
