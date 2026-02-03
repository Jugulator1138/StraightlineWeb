# Subwoofer Database Module
# Contains common subwoofer specifications and web lookup functionality

require 'net/http'
require 'json'
require 'uri'

module SubwooferDatabase
  # Common subwoofer specifications
  # Format: "brand_model" => { specs }
  # All measurements in inches, volume in cubic inches

  KNOWN_SUBS = {
    # Skar Audio
    "skar_vxf_12" => {
      brand: "Skar Audio",
      model: "VXF-12",
      size: 12,
      cutout_diameter: 11.06,
      mounting_depth: 6.26,
      displacement: 0.11,  # cubic feet
      recommended_sealed: { min: 1.25, max: 1.75 },  # cubic feet
      recommended_ported: { min: 2.0, max: 3.0 },    # cubic feet
      recommended_tuning: { min: 30, max: 36 },      # Hz
      xmax: 18,  # mm one-way
      fs: 34.4,  # Hz
      qts: 0.49,
      vas: 68.5  # liters
    },
    "skar_vxf_15" => {
      brand: "Skar Audio",
      model: "VXF-15",
      size: 15,
      cutout_diameter: 13.94,
      mounting_depth: 7.68,
      displacement: 0.17,
      recommended_sealed: { min: 2.0, max: 2.75 },
      recommended_ported: { min: 3.5, max: 5.0 },
      recommended_tuning: { min: 28, max: 34 },
      xmax: 18,
      fs: 31.2,
      qts: 0.51,
      vas: 118.6
    },
    "skar_evl_12" => {
      brand: "Skar Audio",
      model: "EVL-12",
      size: 12,
      cutout_diameter: 10.94,
      mounting_depth: 6.5,
      displacement: 0.10,
      recommended_sealed: { min: 1.0, max: 1.5 },
      recommended_ported: { min: 1.75, max: 2.5 },
      recommended_tuning: { min: 32, max: 38 },
      xmax: 14,
      fs: 36.8,
      qts: 0.52,
      vas: 42.5
    },
    "skar_evl_15" => {
      brand: "Skar Audio",
      model: "EVL-15",
      size: 15,
      cutout_diameter: 13.82,
      mounting_depth: 7.25,
      displacement: 0.15,
      recommended_sealed: { min: 1.75, max: 2.5 },
      recommended_ported: { min: 2.75, max: 4.0 },
      recommended_tuning: { min: 30, max: 36 },
      xmax: 14,
      fs: 32.5,
      qts: 0.48,
      vas: 85.2
    },
    "skar_zvx_12" => {
      brand: "Skar Audio",
      model: "ZVX-12",
      size: 12,
      cutout_diameter: 11.14,
      mounting_depth: 8.07,
      displacement: 0.15,
      recommended_sealed: { min: 1.5, max: 2.0 },
      recommended_ported: { min: 2.5, max: 4.0 },
      recommended_tuning: { min: 28, max: 34 },
      xmax: 24,
      fs: 32.5,
      qts: 0.44,
      vas: 75.3
    },
    "skar_zvx_15" => {
      brand: "Skar Audio",
      model: "ZVX-15",
      size: 15,
      cutout_diameter: 14.02,
      mounting_depth: 9.02,
      displacement: 0.22,
      recommended_sealed: { min: 2.25, max: 3.0 },
      recommended_ported: { min: 4.0, max: 6.0 },
      recommended_tuning: { min: 26, max: 32 },
      xmax: 24,
      fs: 29.8,
      qts: 0.46,
      vas: 132.4
    },
    "skar_sdr_12" => {
      brand: "Skar Audio",
      model: "SDR-12",
      size: 12,
      cutout_diameter: 10.83,
      mounting_depth: 5.51,
      displacement: 0.08,
      recommended_sealed: { min: 0.875, max: 1.25 },
      recommended_ported: { min: 1.5, max: 2.25 },
      recommended_tuning: { min: 34, max: 40 },
      xmax: 10,
      fs: 38.2,
      qts: 0.65,
      vas: 32.8
    },

    # Sundown Audio
    "sundown_x_12" => {
      brand: "Sundown Audio",
      model: "X-12",
      size: 12,
      cutout_diameter: 11.125,
      mounting_depth: 7.25,
      displacement: 0.13,
      recommended_sealed: { min: 1.25, max: 1.75 },
      recommended_ported: { min: 2.0, max: 3.5 },
      recommended_tuning: { min: 30, max: 36 },
      xmax: 20,
      fs: 33.5,
      qts: 0.47,
      vas: 62.4
    },
    "sundown_x_15" => {
      brand: "Sundown Audio",
      model: "X-15",
      size: 15,
      cutout_diameter: 14.0,
      mounting_depth: 8.5,
      displacement: 0.19,
      recommended_sealed: { min: 2.0, max: 2.75 },
      recommended_ported: { min: 3.5, max: 5.5 },
      recommended_tuning: { min: 28, max: 34 },
      xmax: 20,
      fs: 30.2,
      qts: 0.49,
      vas: 105.8
    },
    "sundown_sa_12" => {
      brand: "Sundown Audio",
      model: "SA-12",
      size: 12,
      cutout_diameter: 10.875,
      mounting_depth: 6.375,
      displacement: 0.09,
      recommended_sealed: { min: 1.0, max: 1.5 },
      recommended_ported: { min: 1.5, max: 2.5 },
      recommended_tuning: { min: 32, max: 38 },
      xmax: 13,
      fs: 35.8,
      qts: 0.55,
      vas: 45.2
    },
    "sundown_sa_15" => {
      brand: "Sundown Audio",
      model: "SA-15",
      size: 15,
      cutout_diameter: 13.75,
      mounting_depth: 7.125,
      displacement: 0.14,
      recommended_sealed: { min: 1.75, max: 2.5 },
      recommended_ported: { min: 2.5, max: 4.0 },
      recommended_tuning: { min: 30, max: 36 },
      xmax: 13,
      fs: 32.4,
      qts: 0.52,
      vas: 78.6
    },

    # American Bass
    "american_bass_xfl_12" => {
      brand: "American Bass",
      model: "XFL-12",
      size: 12,
      cutout_diameter: 10.875,
      mounting_depth: 7.5,
      displacement: 0.12,
      recommended_sealed: { min: 1.25, max: 1.75 },
      recommended_ported: { min: 2.0, max: 3.5 },
      recommended_tuning: { min: 30, max: 36 },
      xmax: 18,
      fs: 34.2,
      qts: 0.48,
      vas: 58.3
    },
    "american_bass_hd_12" => {
      brand: "American Bass",
      model: "HD-12",
      size: 12,
      cutout_diameter: 10.625,
      mounting_depth: 6.0,
      displacement: 0.09,
      recommended_sealed: { min: 1.0, max: 1.5 },
      recommended_ported: { min: 1.75, max: 2.5 },
      recommended_tuning: { min: 34, max: 40 },
      xmax: 12,
      fs: 37.5,
      qts: 0.58,
      vas: 38.4
    },

    # Kicker
    "kicker_compr_12" => {
      brand: "Kicker",
      model: "CompR 12",
      size: 12,
      cutout_diameter: 10.875,
      mounting_depth: 5.875,
      displacement: 0.08,
      recommended_sealed: { min: 0.75, max: 1.25 },
      recommended_ported: { min: 1.5, max: 2.25 },
      recommended_tuning: { min: 35, max: 42 },
      xmax: 10,
      fs: 39.2,
      qts: 0.62,
      vas: 28.5
    },
    "kicker_l7r_12" => {
      brand: "Kicker",
      model: "L7R 12",
      size: 12,
      cutout_diameter: 10.625, # square sub
      mounting_depth: 6.75,
      displacement: 0.11,
      recommended_sealed: { min: 1.0, max: 1.5 },
      recommended_ported: { min: 2.0, max: 3.0 },
      recommended_tuning: { min: 32, max: 38 },
      xmax: 15,
      fs: 35.5,
      qts: 0.52,
      vas: 48.2,
      is_square: true
    },

    # JL Audio
    "jl_12w6v3" => {
      brand: "JL Audio",
      model: "12W6v3",
      size: 12,
      cutout_diameter: 10.71,
      mounting_depth: 5.92,
      displacement: 0.086,
      recommended_sealed: { min: 0.875, max: 1.25 },
      recommended_ported: { min: 1.5, max: 2.0 },
      recommended_tuning: { min: 32, max: 38 },
      xmax: 13.2,
      fs: 33.2,
      qts: 0.45,
      vas: 45.8
    },
    "jl_12w7" => {
      brand: "JL Audio",
      model: "12W7AE",
      size: 12,
      cutout_diameter: 10.71,
      mounting_depth: 6.69,
      displacement: 0.11,
      recommended_sealed: { min: 1.0, max: 1.5 },
      recommended_ported: { min: 1.75, max: 2.5 },
      recommended_tuning: { min: 30, max: 36 },
      xmax: 18,
      fs: 31.5,
      qts: 0.44,
      vas: 52.3
    },

    # Rockford Fosgate
    "rockford_p3d4_12" => {
      brand: "Rockford Fosgate",
      model: "P3D4-12",
      size: 12,
      cutout_diameter: 10.9375,
      mounting_depth: 6.5,
      displacement: 0.095,
      recommended_sealed: { min: 1.0, max: 1.5 },
      recommended_ported: { min: 1.5, max: 2.25 },
      recommended_tuning: { min: 33, max: 40 },
      xmax: 14,
      fs: 36.8,
      qts: 0.55,
      vas: 42.1
    },
    "rockford_t1d4_12" => {
      brand: "Rockford Fosgate",
      model: "T1D4-12",
      size: 12,
      cutout_diameter: 10.9375,
      mounting_depth: 7.0625,
      displacement: 0.12,
      recommended_sealed: { min: 1.25, max: 1.75 },
      recommended_ported: { min: 1.75, max: 2.75 },
      recommended_tuning: { min: 32, max: 38 },
      xmax: 16,
      fs: 34.5,
      qts: 0.48,
      vas: 55.8
    },

    # DC Audio
    "dc_level3_12" => {
      brand: "DC Audio",
      model: "Level 3 12",
      size: 12,
      cutout_diameter: 10.875,
      mounting_depth: 6.875,
      displacement: 0.11,
      recommended_sealed: { min: 1.0, max: 1.5 },
      recommended_ported: { min: 2.0, max: 3.0 },
      recommended_tuning: { min: 32, max: 38 },
      xmax: 16,
      fs: 35.2,
      qts: 0.52,
      vas: 48.5
    },
    "dc_level5_12" => {
      brand: "DC Audio",
      model: "Level 5 12",
      size: 12,
      cutout_diameter: 11.0,
      mounting_depth: 8.25,
      displacement: 0.16,
      recommended_sealed: { min: 1.5, max: 2.25 },
      recommended_ported: { min: 3.0, max: 5.0 },
      recommended_tuning: { min: 28, max: 34 },
      xmax: 22,
      fs: 31.8,
      qts: 0.44,
      vas: 72.4
    },

    # Deaf Bonce
    "deaf_bonce_apocalypse_12" => {
      brand: "Deaf Bonce",
      model: "Apocalypse DB-SA2612",
      size: 12,
      cutout_diameter: 10.75,
      mounting_depth: 6.5,
      displacement: 0.10,
      recommended_sealed: { min: 1.0, max: 1.5 },
      recommended_ported: { min: 2.0, max: 3.0 },
      recommended_tuning: { min: 32, max: 38 },
      xmax: 14,
      fs: 35.5,
      qts: 0.54,
      vas: 46.2
    },

    # Taramps
    "taramps_bass_12" => {
      brand: "Taramps",
      model: "Bass 400 12",
      size: 12,
      cutout_diameter: 10.625,
      mounting_depth: 5.5,
      displacement: 0.07,
      recommended_sealed: { min: 0.75, max: 1.0 },
      recommended_ported: { min: 1.25, max: 2.0 },
      recommended_tuning: { min: 36, max: 44 },
      xmax: 9,
      fs: 42.5,
      qts: 0.68,
      vas: 24.8
    }
  }

  # Normalize input string to match database keys
  def self.normalize_key(input)
    input.to_s.downcase
         .gsub(/[^a-z0-9]/, '_')
         .gsub(/_+/, '_')
         .gsub(/^_|_$/, '')
  end

  # Search for subwoofer in database
  def self.find(brand_model)
    normalized = normalize_key(brand_model)

    # Direct match
    return KNOWN_SUBS[normalized] if KNOWN_SUBS.key?(normalized)

    # Partial match
    KNOWN_SUBS.each do |key, specs|
      return specs if normalized.include?(key) || key.include?(normalized)
    end

    # Fuzzy match - check if key words match
    input_words = normalized.split('_')
    KNOWN_SUBS.each do |key, specs|
      key_words = key.split('_')
      matches = (input_words & key_words).length
      return specs if matches >= 2
    end

    nil
  end

  # Get default specs based on size when sub not found
  def self.default_specs_for_size(size)
    size = size.to_i
    case size
    when 8
      {
        cutout_diameter: 7.125,
        mounting_depth: 3.75,
        displacement: 0.03,
        recommended_sealed: { min: 0.35, max: 0.5 },
        recommended_ported: { min: 0.5, max: 0.75 },
        recommended_tuning: { min: 40, max: 50 }
      }
    when 10
      {
        cutout_diameter: 9.125,
        mounting_depth: 4.75,
        displacement: 0.05,
        recommended_sealed: { min: 0.5, max: 0.875 },
        recommended_ported: { min: 0.875, max: 1.5 },
        recommended_tuning: { min: 35, max: 42 }
      }
    when 12
      {
        cutout_diameter: 10.875,
        mounting_depth: 5.75,
        displacement: 0.08,
        recommended_sealed: { min: 0.875, max: 1.5 },
        recommended_ported: { min: 1.5, max: 2.5 },
        recommended_tuning: { min: 32, max: 38 }
      }
    when 15
      {
        cutout_diameter: 13.875,
        mounting_depth: 7.0,
        displacement: 0.14,
        recommended_sealed: { min: 1.75, max: 2.75 },
        recommended_ported: { min: 3.0, max: 5.0 },
        recommended_tuning: { min: 28, max: 34 }
      }
    when 18
      {
        cutout_diameter: 17.125,
        mounting_depth: 9.5,
        displacement: 0.25,
        recommended_sealed: { min: 3.0, max: 4.5 },
        recommended_ported: { min: 5.0, max: 8.0 },
        recommended_tuning: { min: 25, max: 32 }
      }
    else
      # Extrapolate for uncommon sizes
      {
        cutout_diameter: size - 1.125,
        mounting_depth: size * 0.5,
        displacement: (size / 12.0) ** 2 * 0.08,
        recommended_sealed: { min: (size / 12.0) ** 2 * 0.875, max: (size / 12.0) ** 2 * 1.5 },
        recommended_ported: { min: (size / 12.0) ** 2 * 1.5, max: (size / 12.0) ** 2 * 2.5 },
        recommended_tuning: { min: 500 / size, max: 600 / size }
      }
    end
  end

  # Load custom specs from JSON file
  def self.load_custom_specs(filepath)
    return {} unless File.exist?(filepath)
    JSON.parse(File.read(filepath), symbolize_names: true)
  rescue JSON::ParserError => e
    puts "Warning: Could not parse custom specs file: #{e.message}"
    {}
  end

  # Save custom specs to JSON file
  def self.save_custom_specs(filepath, specs)
    File.write(filepath, JSON.pretty_generate(specs))
  end

  # Interactive prompt for manual specs entry
  def self.prompt_for_specs(brand_model, size)
    puts "\n" + "="*60
    puts "Subwoofer not found in database: #{brand_model}"
    puts "Please enter specifications manually (or press Enter for defaults)"
    puts "="*60

    defaults = default_specs_for_size(size)
    specs = { brand: brand_model.split(/\s+/).first, model: brand_model, size: size }

    print "Cutout diameter (inches) [#{defaults[:cutout_diameter]}]: "
    input = gets.chomp
    specs[:cutout_diameter] = input.empty? ? defaults[:cutout_diameter] : input.to_f

    print "Mounting depth (inches) [#{defaults[:mounting_depth]}]: "
    input = gets.chomp
    specs[:mounting_depth] = input.empty? ? defaults[:mounting_depth] : input.to_f

    print "Displacement (cubic feet) [#{defaults[:displacement]}]: "
    input = gets.chomp
    specs[:displacement] = input.empty? ? defaults[:displacement] : input.to_f

    print "Recommended ported volume MIN (cubic feet) [#{defaults[:recommended_ported][:min]}]: "
    input = gets.chomp
    ported_min = input.empty? ? defaults[:recommended_ported][:min] : input.to_f

    print "Recommended ported volume MAX (cubic feet) [#{defaults[:recommended_ported][:max]}]: "
    input = gets.chomp
    ported_max = input.empty? ? defaults[:recommended_ported][:max] : input.to_f
    specs[:recommended_ported] = { min: ported_min, max: ported_max }

    print "Recommended sealed volume MIN (cubic feet) [#{defaults[:recommended_sealed][:min]}]: "
    input = gets.chomp
    sealed_min = input.empty? ? defaults[:recommended_sealed][:min] : input.to_f

    print "Recommended sealed volume MAX (cubic feet) [#{defaults[:recommended_sealed][:max]}]: "
    input = gets.chomp
    sealed_max = input.empty? ? defaults[:recommended_sealed][:max] : input.to_f
    specs[:recommended_sealed] = { min: sealed_min, max: sealed_max }

    print "Recommended tuning frequency MIN (Hz) [#{defaults[:recommended_tuning][:min]}]: "
    input = gets.chomp
    tuning_min = input.empty? ? defaults[:recommended_tuning][:min] : input.to_f

    print "Recommended tuning frequency MAX (Hz) [#{defaults[:recommended_tuning][:max]}]: "
    input = gets.chomp
    tuning_max = input.empty? ? defaults[:recommended_tuning][:max] : input.to_f
    specs[:recommended_tuning] = { min: tuning_min, max: tuning_max }

    specs
  end

  # Extract size from brand/model string
  def self.extract_size(brand_model)
    # Look for common size patterns
    match = brand_model.match(/(\d{1,2})["']?\s*(inch)?/i) ||
            brand_model.match(/[-_\s](\d{1,2})[-_\s]?[dD]?[12]?$/i) ||
            brand_model.match(/[-_\s](\d{1,2})$/)

    match ? match[1].to_i : 12  # Default to 12" if not found
  end
end
