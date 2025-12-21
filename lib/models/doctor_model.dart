class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final String image;
  final double rating;
  final String distance;
  final int experience;
  final String degree;
  final bool isAvailable;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.image,
    required this.rating,
    required this.distance,
    required this.experience,
    required this.degree,
    this.isAvailable = true,
  });
}