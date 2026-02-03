#!/usr/bin/env ruby
# Subwoofer Enclosure Designer
# Main runner script - processes CSV from Google Forms and generates SketchUp models

require_relative 'lib/subwoofer_database'
require_relative 'lib/port_calculator'
require_relative 'lib/enclosure_calculator'
require_relative 'lib/sketchup_builder'
require_relative 'lib/cut_list_generator'
require_relative 'lib/csv_parser'

class EnclosureDesigner
  BASE_DIR = File.dirname(__FILE__)
  CSV_DIR = File.join(BASE_DIR, 'CSV_Imports')
  SKP_DIR = File.join(BASE_DIR, 'Generated_SKP')
  CUTLIST_DIR = File.join(BASE_DIR, 'CutLists')
  CUSTOM_SUBS_FILE = File.join(BASE_DIR, 'SubwooferDatabase', 'custom_subs.json')

  def initialize
    @custom_subs = SubwooferDatabase.load_custom_specs(CUSTOM_SUBS_FILE)
  end

  # Process a single client from parsed CSV data
  def process_client(client_data)
    puts "\n#{'='*60}"
    puts "Processing: #{client_data[:client_info][:name]}"
    puts "#{'='*60}"

    # Look up subwoofer specs
    sub_specs = lookup_subwoofer(client_data[:subwoofer][:brand_model])

    # Create enclosure configuration
    config = CSVParser.to_enclosure_config(client_data, sub_specs)

    # Display configuration
    display_config(client_data, config, sub_specs)

    # Design the enclosure
    puts "\nCalculating enclosure design..."
    design = EnclosureCalculator.design(config)

    # Display design results
    display_design(design)

    # Generate panels
    puts "\nGenerating panel list..."
    panels = EnclosureCalculator.generate_panels(design, config)

    # Generate cut list
    cut_list = CutListGenerator.generate_cut_list(panels)

    # Nest panels on sheets
    puts "Optimizing panel layout on sheets..."
    sheets = CutListGenerator.nest_panels(cut_list)
    usage = CutListGenerator.calculate_usage(sheets)

    puts "  Sheets required: #{usage[:num_sheets]}"
    puts "  Material efficiency: #{usage[:efficiency_percent]}%"

    # Generate outputs
    client_name = client_data[:client_info][:name]

    # SketchUp script
    puts "\nGenerating SketchUp script..."
    skp_result = SketchupBuilder.write_script(design, panels, config, client_name, SKP_DIR)
    puts "  Script: #{skp_result[:script_path]}"

    # Cut list HTML
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    safe_name = client_name.gsub(/[^a-zA-Z0-9]/, '_')
    html_path = File.join(CUTLIST_DIR, "#{safe_name}_cutlist_#{timestamp}.html")
    CutListGenerator.generate_html_report(cut_list, sheets, usage, design, config, client_name, html_path)
    puts "  Cut list HTML: #{html_path}"

    # Text cut list
    txt_path = File.join(CUTLIST_DIR, "#{safe_name}_cutlist_#{timestamp}.txt")
    File.write(txt_path, CutListGenerator.generate_text_report(cut_list, sheets, usage, design, config, client_name))
    puts "  Cut list TXT: #{txt_path}"

    {
      client: client_data,
      config: config,
      design: design,
      panels: panels,
      cut_list: cut_list,
      sheets: sheets,
      usage: usage,
      outputs: {
        sketchup_script: skp_result[:script_path],
        skp_path: skp_result[:skp_path],
        cut_list_html: html_path,
        cut_list_txt: txt_path
      }
    }
  end

  # Look up subwoofer specs
  def lookup_subwoofer(brand_model)
    puts "\nLooking up subwoofer: #{brand_model}"

    # Check custom database first
    custom_key = SubwooferDatabase.normalize_key(brand_model)
    if @custom_subs[custom_key]
      puts "  Found in custom database"
      return @custom_subs[custom_key]
    end

    # Check built-in database
    specs = SubwooferDatabase.find(brand_model)
    if specs
      puts "  Found: #{specs[:brand]} #{specs[:model]}"
      puts "  Cutout: #{specs[:cutout_diameter]}\", Depth: #{specs[:mounting_depth]}\""
      return specs
    end

    # Not found - prompt for manual entry
    puts "  Not found in database"
    size = SubwooferDatabase.extract_size(brand_model)
    puts "  Detected size: #{size}\""

    specs = SubwooferDatabase.prompt_for_specs(brand_model, size)

    # Save to custom database
    @custom_subs[custom_key] = specs
    SubwooferDatabase.save_custom_specs(CUSTOM_SUBS_FILE, @custom_subs)
    puts "  Saved to custom database for future use"

    specs
  end

  # Display configuration
  def display_config(client_data, config, sub_specs)
    puts "\n--- Client Info ---"
    puts "  Name: #{client_data[:client_info][:name]}"
    puts "  Vehicle: #{client_data[:vehicle][:description]}"
    puts "  Location: #{client_data[:vehicle][:location]}"

    puts "\n--- Subwoofer ---"
    puts "  Model: #{client_data[:subwoofer][:brand_model]}"
    puts "  Quantity: #{config.num_subs}"
    puts "  Cutout: #{sub_specs[:cutout_diameter]}\" | Depth: #{sub_specs[:mounting_depth]}\""

    puts "\n--- Available Space ---"
    puts "  Max: #{config.max_width}\"W x #{config.max_height}\"H x #{config.max_depth}\"D"

    puts "\n--- Build Specs ---"
    puts "  Type: #{config.enclosure_type}"
    puts "  Target Volume: #{config.target_volume} cu ft"
    puts "  Tuning: #{config.tuning_frequency} Hz" if config.enclosure_type == :ported
    puts "  Double Baffle: #{config.double_baffle ? 'Yes' : 'No'}"
    puts "  Extra Bracing: #{config.extra_bracing ? 'Yes' : 'No'}"
    puts "  Separate Chambers: #{config.separate_chambers ? 'Yes' : 'No'}"
  end

  # Display design results
  def display_design(design)
    puts "\n--- Design Results ---"
    puts "  External: #{design[:external_dimensions][:width]}\"W x #{design[:external_dimensions][:height]}\"H x #{design[:external_dimensions][:depth]}\"D"
    puts "  Internal: #{design[:internal_dimensions][:width].round(2)}\"W x #{design[:internal_dimensions][:height].round(2)}\"H x #{design[:internal_dimensions][:depth].round(2)}\"D"

    if design[:net_volume_cu_ft]
      puts "  Net Volume: #{design[:net_volume_cu_ft]} cu ft"
    end

    if design[:port]
      puts "\n  --- Port ---"
      puts "  Tuning: #{design[:port][:actual_tuning]} Hz"
      puts "  Size: #{design[:port][:port_width].round(2)}\"W x #{design[:port][:port_height].round(2)}\"H"
      puts "  Length: #{design[:port][:port_length].round(2)}\""
      puts "  Area: #{design[:port][:port_area].round(1)} sq in"
      puts "  Path: #{design[:port][:path_type]}"
      puts "  Fits: #{design[:port][:fits_in_box] ? 'Yes' : 'NO - May need adjustment!'}"
    end

    if design[:sealed_chamber]
      puts "\n  --- Bandpass Chambers ---"
      puts "  Sealed: #{design[:sealed_chamber][:net_volume_cu_ft]} cu ft"
      puts "  Ported: #{design[:ported_chamber][:net_volume_cu_ft]} cu ft"
    end
  end

  # Process CSV file
  def process_csv(filepath)
    puts "Reading CSV: #{filepath}"
    clients = CSVParser.parse(filepath)
    puts "Found #{clients.length} client(s)"

    results = []
    clients.each do |client|
      result = process_client(client)
      results << result
    end

    results
  end

  # Interactive mode - process single client manually
  def interactive_mode
    puts "\n#{'='*60}"
    puts "INTERACTIVE ENCLOSURE DESIGNER"
    puts "#{'='*60}"

    client_data = gather_interactive_input
    process_client(client_data)
  end

  # Gather input interactively
  def gather_interactive_input
    print "\nClient Name: "
    name = gets.chomp
    name = "Test Client" if name.empty?

    print "Subwoofer Brand/Model (e.g., 'Skar VXF 12'): "
    sub_model = gets.chomp
    sub_model = "Skar VXF 12" if sub_model.empty?

    print "Number of subwoofers [1]: "
    num_subs = gets.chomp
    num_subs = num_subs.empty? ? 1 : num_subs.to_i

    print "Enclosure type (sealed/ported/bandpass) [ported]: "
    enc_type = gets.chomp.downcase
    enc_type = 'ported' if enc_type.empty?

    print "Max Width (inches) [36]: "
    width = gets.chomp
    width = width.empty? ? 36 : width.to_f

    print "Max Height (inches) [15]: "
    height = gets.chomp
    height = height.empty? ? 15 : height.to_f

    print "Max Depth (inches) [20]: "
    depth = gets.chomp
    depth = depth.empty? ? 20 : depth.to_f

    print "Target Volume (cu ft) [2.0]: "
    volume = gets.chomp
    volume = volume.empty? ? 2.0 : volume.to_f

    tuning = 32
    if enc_type == 'ported' || enc_type == 'bandpass'
      print "Tuning Frequency (Hz) [32]: "
      tuning = gets.chomp
      tuning = tuning.empty? ? 32 : tuning.to_f
    end

    print "Double Baffle? (y/n) [y]: "
    double_baffle = gets.chomp.downcase
    double_baffle = double_baffle.empty? || double_baffle == 'y'

    print "Extra Bracing? (y/n) [n]: "
    bracing = gets.chomp.downcase
    bracing = bracing == 'y'

    print "Separate Chambers? (y/n) [n]: "
    separate = gets.chomp.downcase
    separate = separate == 'y'

    # Build client data hash
    {
      client_info: { name: name, email: nil, phone: nil },
      vehicle: { description: "Custom Build", location: "Trunk" },
      available_space: {
        max_width: width,
        max_height: height,
        max_depth: depth,
        irregular_shapes: false,
        obstructions: nil,
        removable: true
      },
      subwoofer: {
        brand_model: sub_model,
        quantity: num_subs,
        voice_coil: 'D2',
        recommended_type: nil,
        manufacturer_volume: nil
      },
      amplifier: { power_level: :sql },
      enclosure_goals: {
        type: CSVParser.parse_enclosure_type(enc_type),
        primary_goal: :sql,
        tuning_frequency: tuning
      },
      build_preferences: {
        double_baffle: double_baffle,
        extra_bracing: bracing,
        separate_chambers: separate,
        terminal_towers: false
      },
      final_enclosure_type: CSVParser.parse_enclosure_type(enc_type),
      target_volume: volume,
      bandpass_ratio: "1:2"
    }
  end

  # Main entry point
  def self.run(args = ARGV)
    designer = new

    if args.empty?
      # Check for CSV files in import directory
      csv_files = Dir.glob(File.join(CSV_DIR, '*.csv'))

      if csv_files.empty?
        puts "No CSV files found in #{CSV_DIR}"
        puts "Starting interactive mode..."
        designer.interactive_mode
      else
        puts "Found CSV files:"
        csv_files.each_with_index { |f, i| puts "  #{i + 1}. #{File.basename(f)}" }
        puts "  #{csv_files.length + 1}. Interactive mode"

        print "\nSelect option: "
        choice = gets.chomp.to_i

        if choice > 0 && choice <= csv_files.length
          designer.process_csv(csv_files[choice - 1])
        else
          designer.interactive_mode
        end
      end
    elsif args[0] == '-i' || args[0] == '--interactive'
      designer.interactive_mode
    elsif File.exist?(args[0])
      designer.process_csv(args[0])
    else
      puts "Usage: ruby enclosure_designer.rb [csv_file]"
      puts "       ruby enclosure_designer.rb -i    # Interactive mode"
      puts "\nOr place CSV files in: #{CSV_DIR}"
    end
  end
end

# Run if executed directly
if __FILE__ == $0
  EnclosureDesigner.run
end
