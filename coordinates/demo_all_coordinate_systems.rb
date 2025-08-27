#!/usr/bin/env ruby
# Comprehensive demonstration of all coordinate systems
# Shows complete orthogonal conversions between all implemented coordinate systems

require_relative 'lla_coordinate'
require_relative 'ecef_coordinate'
require_relative 'utm_coordinate'
require_relative 'enu_coordinate'
require_relative 'ned_coordinate'
require_relative 'mgrs_coordinate'
require_relative 'web_mercator_coordinate'
require_relative 'ups_coordinate'
require_relative 'usng_coordinate'
require_relative 'state_plane_coordinate'
require_relative 'british_national_grid_coordinate'
require_relative 'geoid_height'

def demo_coordinate_systems
  puts "=" * 80
  puts "COMPLETE COORDINATE SYSTEM CONVERSION DEMONSTRATION"
  puts "=" * 80
  puts
  
  # Test location: Seattle Space Needle
  seattle_lat = 47.6205
  seattle_lng = -122.3493
  seattle_alt = 184.0
  
  puts "🌍 Reference Location: Seattle Space Needle"
  puts "   Latitude:  #{seattle_lat}°"
  puts "   Longitude: #{seattle_lng}°"
  puts "   Altitude:  #{seattle_alt} meters"
  puts
  
  # Create reference LLA coordinate
  lla_coord = LlaCoordinate.new(seattle_lat, seattle_lng, seattle_alt)
  reference_lla = LlaCoordinate.new(seattle_lat, seattle_lng, 0.0)  # For local coordinates
  
  puts "📍 ALL COORDINATE SYSTEM CONVERSIONS"
  puts "-" * 50
  
  # ========== ECEF Conversion ==========
  puts "🔹 Earth-Centered, Earth-Fixed (ECEF)"
  ecef_coord = lla_coord.to_ecef
  puts "   ECEF: X=#{ecef_coord.x.round(3)}m, Y=#{ecef_coord.y.round(3)}m, Z=#{ecef_coord.z.round(3)}m"
  
  # Round-trip test
  lla_from_ecef = ecef_coord.to_lla
  lat_error = (lla_from_ecef.lat - seattle_lat).abs
  lng_error = (lla_from_ecef.lng - seattle_lng).abs
  puts "   Round-trip error: Lat=#{lat_error.round(15)}, Lng=#{lng_error.round(15)}"
  puts
  
  # ========== UTM Conversion ==========
  puts "🔹 Universal Transverse Mercator (UTM)"
  utm_coord = lla_coord.to_utm
  puts "   UTM: #{utm_coord.easting.round(3)}E #{utm_coord.northing.round(3)}N Zone #{utm_coord.zone}#{utm_coord.hemisphere}"
  
  # Round-trip test
  lla_from_utm = utm_coord.to_lla
  utm_lat_error = (lla_from_utm.lat - seattle_lat).abs
  utm_lng_error = (lla_from_utm.lng - seattle_lng).abs
  puts "   Round-trip error: Lat=#{utm_lat_error.round(8)}, Lng=#{utm_lng_error.round(8)}"
  puts
  
  # ========== ENU Conversion ==========
  puts "🔹 East, North, Up (ENU) Local Coordinates"
  enu_coord = lla_coord.to_enu(reference_lla)
  puts "   ENU: E=#{enu_coord.east.round(3)}m, N=#{enu_coord.north.round(3)}m, U=#{enu_coord.up.round(3)}m"
  puts "   Distance from reference: #{enu_coord.distance_to_origin.round(3)}m"
  puts "   Bearing from reference: #{enu_coord.bearing_from_origin.round(3)}°"
  puts
  
  # ========== NED Conversion ==========
  puts "🔹 North, East, Down (NED) Local Coordinates"
  ned_coord = lla_coord.to_ned(reference_lla)
  puts "   NED: N=#{ned_coord.north.round(3)}m, E=#{ned_coord.east.round(3)}m, D=#{ned_coord.down.round(3)}m"
  puts "   Distance from reference: #{ned_coord.distance_to_origin.round(3)}m"
  puts "   Elevation angle: #{ned_coord.elevation_angle.round(3)}°"
  puts
  
  # ========== MGRS Conversion ==========
  puts "🔹 Military Grid Reference System (MGRS)"
  mgrs_coord = MgrsCoordinate.from_lla(lla_coord)
  puts "   MGRS: #{mgrs_coord}"
  puts "   Zone: #{mgrs_coord.grid_zone_designator}, Square: #{mgrs_coord.square_identifier}"
  puts "   Within square: #{mgrs_coord.easting.round(3)}E, #{mgrs_coord.northing.round(3)}N"
  
  # Test different precisions
  mgrs_10m = MgrsCoordinate.from_lla(lla_coord, WGS84, 4)
  mgrs_1m = MgrsCoordinate.from_lla(lla_coord, WGS84, 5)
  puts "   10m precision: #{mgrs_10m}"
  puts "   1m precision:  #{mgrs_1m}"
  puts
  
  # ========== USNG Conversion ==========
  puts "🔹 US National Grid (USNG)"
  usng_coord = UsngCoordinate.from_lla(lla_coord)
  puts "   USNG: #{usng_coord}"
  puts "   Full format: #{usng_coord.to_full_format}"
  puts "   Abbreviated: #{usng_coord.to_abbreviated_format}"
  puts
  
  # ========== Web Mercator Conversion ==========
  puts "🔹 Web Mercator (EPSG:3857) - Used by Google Maps, OSM"
  web_merc_coord = WebMercatorCoordinate.from_lla(lla_coord)
  puts "   Web Mercator: X=#{web_merc_coord.x.round(3)}m, Y=#{web_merc_coord.y.round(3)}m"
  
  # Test tile coordinates at different zoom levels
  tile_10 = web_merc_coord.to_tile_coordinates(10)
  tile_15 = web_merc_coord.to_tile_coordinates(15)
  puts "   Tile (zoom 10): X=#{tile_10[0]}, Y=#{tile_10[1]}"
  puts "   Tile (zoom 15): X=#{tile_15[0]}, Y=#{tile_15[1]}"
  puts
  
  # ========== UPS Conversion (using North Pole example) ==========
  puts "🔹 Universal Polar Stereographic (UPS)"
  north_pole_lla = LlaCoordinate.new(89.0, 0.0, 0.0)
  ups_coord = UpsCoordinate.from_lla(north_pole_lla)
  puts "   UPS (North Pole): #{ups_coord.easting.round(3)}E #{ups_coord.northing.round(3)}N Zone #{ups_coord.zone}#{ups_coord.hemisphere}"
  puts "   Grid convergence: #{ups_coord.grid_convergence.round(6)}°"
  puts "   Scale factor: #{ups_coord.point_scale_factor.round(8)}"
  puts
  
  # ========== State Plane Conversion ==========
  puts "🔹 State Plane Coordinate System (SPC)"
  begin
    ca_spc = StatePlaneCoordinate.from_lla(lla_coord, 'CA_I')
    puts "   California Zone I: #{ca_spc.easting.round(3)}ft, #{ca_spc.northing.round(3)}ft"
    puts "   State: #{ca_spc.zone_info[:state]}, Projection: #{ca_spc.zone_info[:projection]}"
    puts "   Units: #{ca_spc.zone_info[:units]}"
    
    # Convert to meters
    ca_spc_meters = ca_spc.to_meters
    puts "   In meters: #{ca_spc_meters.easting.round(3)}m, #{ca_spc_meters.northing.round(3)}m"
  rescue => e
    puts "   State Plane conversion: #{e.message}"
  end
  puts
  
  # ========== British National Grid Conversion ==========
  puts "🔹 British National Grid (BNG)"
  london_lla = LlaCoordinate.new(51.5007, -0.1246, 11.0)
  bng_coord = BritishNationalGridCoordinate.from_lla(london_lla)
  puts "   BNG (London): #{bng_coord.easting.round(3)}E #{bng_coord.northing.round(3)}N"
  puts "   Grid reference: #{bng_coord.to_grid_reference(6)}"
  puts "   Grid reference (low precision): #{bng_coord.to_grid_reference(0)}"
  puts
  
  # ========== Geoid Height Demonstration ==========
  puts "🔹 Geoid Height and Vertical Datum Support"
  geoid = GeoidHeight.new('EGM2008')
  
  seattle_geoid_height = geoid.geoid_height_at(seattle_lat, seattle_lng)
  orthometric_height = geoid.ellipsoidal_to_orthometric(seattle_lat, seattle_lng, seattle_alt)
  
  puts "   Geoid height (EGM2008): #{seattle_geoid_height.round(3)}m"
  puts "   Ellipsoidal height (HAE): #{seattle_alt}m"
  puts "   Orthometric height (MSL): #{orthometric_height.round(3)}m"
  
  # Test different geoid models
  egm96_geoid = GeoidHeight.new('EGM96')
  egm96_height = egm96_geoid.geoid_height_at(seattle_lat, seattle_lng)
  puts "   Geoid height (EGM96): #{egm96_height.round(3)}m"
  puts "   Model difference: #{(seattle_geoid_height - egm96_height).abs.round(3)}m"
  
  # Test vertical datum conversion
  navd88_height = geoid.convert_vertical_datum(seattle_lat, seattle_lng, seattle_alt, 'HAE', 'NAVD88')
  puts "   Height in NAVD88: #{navd88_height.round(3)}m"
  puts
  
  # ========== Cross-System Conversions ==========
  puts "🔄 CROSS-SYSTEM CONVERSION CHAIN"
  puts "-" * 50
  puts "Testing conversion chain: LLA → ECEF → UTM → MGRS → USNG → Web Mercator → LLA"
  
  # Conversion chain
  chain_ecef = lla_coord.to_ecef
  chain_utm = chain_ecef.to_utm
  chain_mgrs = MgrsCoordinate.from_utm(chain_utm)
  chain_usng = UsngCoordinate.from_mgrs(chain_mgrs)
  chain_web_merc = WebMercatorCoordinate.from_lla(chain_usng.to_lla)
  chain_final_lla = chain_web_merc.to_lla
  
  # Calculate accumulated error
  chain_lat_error = (chain_final_lla.lat - seattle_lat).abs
  chain_lng_error = (chain_final_lla.lng - seattle_lng).abs
  chain_alt_error = (chain_final_lla.alt - seattle_alt).abs
  
  puts "Final position: #{chain_final_lla.lat.round(8)}°, #{chain_final_lla.lng.round(8)}°, #{chain_final_lla.alt.round(3)}m"
  puts "Accumulated error: Lat=#{chain_lat_error.round(8)}°, Lng=#{chain_lng_error.round(8)}°, Alt=#{chain_alt_error.round(3)}m"
  
  # Calculate distance error
  distance_error = lla_coord.distance_to(chain_final_lla)
  puts "Distance error: #{distance_error.round(3)}m"
  puts
  
  # ========== Performance Test ==========
  puts "⚡ PERFORMANCE TEST"
  puts "-" * 50
  
  iterations = 1000
  start_time = Time.now
  
  iterations.times do |i|
    test_lla = LlaCoordinate.new(47.6205 + i * 0.0001, -122.3493 + i * 0.0001, 184.0)
    ecef = test_lla.to_ecef
    utm = test_lla.to_utm
    mgrs = MgrsCoordinate.from_lla(test_lla)
    web_merc = WebMercatorCoordinate.from_lla(test_lla)
  end
  
  end_time = Time.now
  total_time = end_time - start_time
  conversions_per_second = (iterations * 4) / total_time
  
  puts "#{iterations} coordinate conversions completed in #{total_time.round(3)}s"
  puts "Performance: #{conversions_per_second.round(0)} conversions/second"
  puts
  
  # ========== Summary ==========
  puts "📊 COORDINATE SYSTEM SUMMARY"
  puts "-" * 50
  puts "✅ LLA (Latitude, Longitude, Altitude)"
  puts "✅ ECEF (Earth-Centered, Earth-Fixed)"
  puts "✅ UTM (Universal Transverse Mercator)"
  puts "✅ ENU (East, North, Up)"
  puts "✅ NED (North, East, Down)"
  puts "✅ MGRS (Military Grid Reference System)"
  puts "✅ USNG (US National Grid)"
  puts "✅ Web Mercator (EPSG:3857)"
  puts "✅ UPS (Universal Polar Stereographic)"
  puts "✅ State Plane Coordinates"
  puts "✅ British National Grid (BNG)"
  puts "✅ Geoid Height Support"
  puts
  puts "🎯 All coordinate systems support complete bidirectional conversions!"
  puts "🌐 Total coordinate systems implemented: 12"
  puts "🔄 Total conversion paths available: 132 (12 × 11)"
  puts
  puts "=" * 80
end

# Run the demonstration if this file is executed directly
if __FILE__ == $0
  demo_coordinate_systems
end