class FlightData {
  final double pitch;
  final double roll;
  final double heading;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? speed;
  final double? verticalSpeed;
  final int? satelliteCount;

  final double? targetAltitude;
  final double? targetSpeed;
  final double? targetHeading;
  final double? baroPressure;
  final double? mach;
  final double? ias;

  const FlightData({
    this.pitch = 0,
    this.roll = 0,
    this.heading = 0,
    this.latitude,
    this.longitude,
    this.altitude,
    this.speed,
    this.verticalSpeed,
    this.satelliteCount,
    this.targetAltitude,
    this.targetSpeed,
    this.targetHeading,
    this.baroPressure,
    this.mach,
    this.ias,
  });
}
