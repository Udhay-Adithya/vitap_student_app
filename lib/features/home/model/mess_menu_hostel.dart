enum MessMenuHostel { mens, ladies }

extension MessMenuHostelX on MessMenuHostel {
  String get apiType => switch (this) {
    MessMenuHostel.mens => 'mh',
    MessMenuHostel.ladies => 'lh',
  };

  String get label => switch (this) {
    MessMenuHostel.mens => "Men's Hostel",
    MessMenuHostel.ladies => "Ladies' Hostel",
  };
}

MessMenuHostel messMenuHostelFromCode(String? code) {
  switch (code?.trim().toLowerCase()) {
    case 'lh':
      return MessMenuHostel.ladies;
    case 'mh':
    default:
      return MessMenuHostel.mens;
  }
}
