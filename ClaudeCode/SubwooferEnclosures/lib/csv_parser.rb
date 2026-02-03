# CSV Parser for Google Sheets Export
# Parses client form responses into structured data

require 'csv'

module CSVParser
  # Expected column headers (flexible matching)
  COLUMN_MAPPINGS = {
    # Client info
    timestamp: ['timestamp', 'date', 'submitted'],
    full_name: ['full name', 'name', 'client name', 'customer'],
    email: ['email', 'email address', 'e-mail'],
    phone: ['phone', 'phone number', 'contact', 'phone number for contact'],

    # Vehicle
    vehicle: ['year, make, model', 'vehicle', 'car', 'year make model'],
    location: ['enclosure location', 'location', 'install location'],

    # Available space
    max_width: ['max width', 'width', 'available width'],
    max_height: ['max height', 'height', 'available height'],
    max_depth: ['max depth', 'depth', 'available depth'],
    irregular_shapes: ['irregular shapes', 'wheel wells', 'irregular'],
    obstructions: ['obstructions', 'avoid', 'obstructions to avoid'],
    removable: ['removable', 'permanent', 'enclosure removable'],

    # Subwoofer details
    brand_model: ['brand/model', 'brand model', 'subwoofer', 'sub model', 'brand'],
    quantity: ['quantity', 'how many', 'num subs', 'number of subs', 'drivers'],
    voice_coil: ['voice coil', 'coil config', 'd1/d2/d4/svc', 'voice coil configuration'],
    recommended_type: ['recommended enclosure', 'enclosure type', 'recommended type'],
    manufacturer_volume: ['manufacturer recommended volume', 'recommended volume', 'volume & tuning'],

    # Amplifier
    amplifier: ['amplifier', 'amp', 'amp model', 'amplifier brand'],
    head_unit: ['head unit', 'radio', 'head unit brand'],
    wiring_impedance: ['impedance', 'wiring impedance', 'ohms'],
    electrical_upgrades: ['electrical', 'big 3', 'upgrades'],
    power_level: ['power level', 'daily power', 'power'],

    # Enclosure goals
    enclosure_type: ['enclosure type', 'type', 'sealed/ported'],
    primary_goal: ['primary goal', 'goal', 'sq/sql/spl'],
    target_frequency: ['target frequency', 'frequency range', 'target freq'],
    tuning_frequency: ['tuning frequency', 'desired tuning', 'tuning'],
    bandwidth: ['bandwidth', 'one-note', 'one note or wide'],

    # Port specs
    port_type: ['port type', 'slot/round/aero'],
    port_orientation: ['port orientation', 'port direction'],
    port_exit: ['port exit', 'exit location'],
    port_noise: ['port noise', 'acceptable noise', 'noise'],
    sacrifice_space: ['sacrifice space', 'willing to sacrifice'],

    # Orientation
    sub_orientation: ['sub orientation', 'subwoofer orientation', 'sub direction'],
    port_orientation_rel: ['port orientation same', 'same or different'],
    cabin_loading: ['cabin loading', 'loading method', 'seat firing'],
    rear_seats: ['rear seats', 'seats remain', 'seats in place'],

    # Build preferences
    double_baffle: ['double baffle', 'baffle'],
    extra_bracing: ['extra bracing', 'bracing'],
    separate_chambers: ['separate chambers', 'chambers'],
    terminal_towers: ['terminal towers', 'terminals'],

    # Listening
    listening_preferences: ['listening preferences', 'music genres', 'genres'],

    # Bandpass specific
    bandpass_ratio: ['bandpass ratio', 'chamber ratio', 'sealed:ported']
  }

  # Parse CSV file and return array of client data hashes
  def self.parse(filepath)
    raise "File not found: #{filepath}" unless File.exist?(filepath)

    rows = CSV.read(filepath, headers: true, liberal_parsing: true)
    headers = rows.headers.map { |h| h&.downcase&.strip }

    # Map headers to our fields
    field_indices = {}
    COLUMN_MAPPINGS.each do |field, possible_names|
      possible_names.each do |name|
        idx = headers.index { |h| h&.include?(name.downcase) }
        if idx
          field_indices[field] = idx
          break
        end
      end
    end

    # Parse each row
    clients = []
    rows.each_with_index do |row, row_idx|
      next if row.to_a.all?(&:nil?)  # Skip empty rows

      client = parse_row(row, field_indices, row_idx)
      clients << client if client
    end

    clients
  end

  # Parse single row into client data hash
  def self.parse_row(row, field_indices, row_idx)
    data = {}

    # Extract each field
    field_indices.each do |field, idx|
      data[field] = row[idx]&.strip
    end

    # Clean and validate data
    client = {
      row_number: row_idx + 2,  # +2 for header row and 0-indexing
      timestamp: data[:timestamp],
      client_info: {
        name: data[:full_name] || "Client #{row_idx + 1}",
        email: data[:email],
        phone: data[:phone]
      },
      vehicle: {
        description: data[:vehicle],
        location: data[:location] || 'Trunk'
      },
      available_space: {
        max_width: parse_number(data[:max_width]) || 36,
        max_height: parse_number(data[:max_height]) || 15,
        max_depth: parse_number(data[:max_depth]) || 20,
        irregular_shapes: parse_boolean(data[:irregular_shapes]),
        obstructions: data[:obstructions],
        removable: parse_boolean(data[:removable], default: true)
      },
      subwoofer: {
        brand_model: data[:brand_model] || "Unknown 12",
        quantity: parse_number(data[:quantity], default: 1).to_i,
        voice_coil: data[:voice_coil] || 'D2',
        recommended_type: parse_enclosure_type(data[:recommended_type]),
        manufacturer_volume: data[:manufacturer_volume]
      },
      amplifier: {
        model: data[:amplifier],
        head_unit: data[:head_unit],
        impedance: data[:wiring_impedance],
        electrical_upgrades: data[:electrical_upgrades],
        power_level: parse_power_level(data[:power_level])
      },
      enclosure_goals: {
        type: parse_enclosure_type(data[:enclosure_type]),
        primary_goal: parse_goal(data[:primary_goal]),
        target_frequency_range: data[:target_frequency],
        tuning_frequency: parse_tuning(data[:tuning_frequency]),
        bandwidth: data[:bandwidth]
      },
      port_specs: {
        type: parse_port_type(data[:port_type]),
        orientation: data[:port_orientation],
        exit_location: data[:port_exit],
        noise_tolerance: data[:port_noise],
        sacrifice_space: parse_boolean(data[:sacrifice_space])
      },
      orientation: {
        sub_orientation: data[:sub_orientation] || 'rear',
        port_orientation: data[:port_orientation_rel] || 'same',
        cabin_loading: data[:cabin_loading],
        rear_seats_remain: parse_boolean(data[:rear_seats])
      },
      build_preferences: {
        double_baffle: parse_boolean(data[:double_baffle], default: true),
        extra_bracing: parse_boolean(data[:extra_bracing]),
        separate_chambers: parse_boolean(data[:separate_chambers]),
        terminal_towers: parse_boolean(data[:terminal_towers])
      },
      listening_preferences: data[:listening_preferences],
      bandpass_ratio: data[:bandpass_ratio] || "1:2"
    }

    # Determine final enclosure type
    client[:final_enclosure_type] = determine_enclosure_type(client)

    # Parse target volume from manufacturer recommendations
    client[:target_volume] = parse_target_volume(
      client[:subwoofer][:manufacturer_volume],
      client[:final_enclosure_type]
    )

    client
  end

  # Parse number from string
  def self.parse_number(str, default: nil)
    return default if str.nil? || str.empty?

    # Handle ranges like "31-33" by taking average
    if str.include?('-') && str.match?(/\d+-\d+/)
      parts = str.scan(/\d+\.?\d*/).map(&:to_f)
      return parts.sum / parts.length if parts.length >= 2
    end

    # Extract first number
    match = str.match(/\d+\.?\d*/)
    match ? match[0].to_f : default
  end

  # Parse boolean from string
  def self.parse_boolean(str, default: false)
    return default if str.nil? || str.empty?

    str.downcase.match?(/yes|true|1|y/) ? true : default
  end

  # Parse enclosure type
  def self.parse_enclosure_type(str)
    return :ported if str.nil?

    case str.downcase
    when /sealed/
      :sealed
    when /ported|vented/
      :ported
    when /bandpass|4th|fourth/
      :bandpass_4th
    when /5th|fifth/
      :bandpass_5th
    when /6th|sixth/
      :bandpass_6th
    else
      :ported  # Default
    end
  end

  # Parse primary goal
  def self.parse_goal(str)
    return :sql if str.nil?

    case str.downcase
    when /sq\b|sound quality/
      :sq
    when /sql|quality.*loud/
      :sql
    when /spl|loud/
      :spl
    when /daily/
      :daily
    else
      :sql
    end
  end

  # Parse power level
  def self.parse_power_level(str)
    return :sql if str.nil?

    case str.downcase
    when /daily|low|normal/
      :daily
    when /moderate|medium|sql/
      :sql
    when /high|full|spl|max/
      :spl
    else
      :sql
    end
  end

  # Parse port type
  def self.parse_port_type(str)
    return :slot if str.nil?

    case str.downcase
    when /slot/
      :slot
    when /round|aero/
      :aero
    when /external/
      :external
    else
      :slot
    end
  end

  # Parse tuning frequency
  def self.parse_tuning(str)
    return 32 if str.nil? || str.empty?

    # Extract number, handle "32 hz" or just "32"
    num = parse_number(str)
    num || 32
  end

  # Determine final enclosure type based on all inputs
  def self.determine_enclosure_type(client)
    # Priority: explicit type > recommended type
    explicit = client[:enclosure_goals][:type]
    recommended = client[:subwoofer][:recommended_type]

    # Use explicit if set, otherwise recommended, otherwise default to ported
    explicit || recommended || :ported
  end

  # Parse target volume from manufacturer specs
  def self.parse_target_volume(str, enclosure_type)
    return default_volume(enclosure_type) if str.nil? || str.empty?

    # Handle ranges like "2.0-3.0" or "31-33" (could be Hz or cu ft)
    numbers = str.scan(/\d+\.?\d*/).map(&:to_f)

    if numbers.length >= 2
      # If numbers are small (< 20), probably cubic feet
      # If large (> 20), probably Hz tuning frequency
      if numbers.max < 20
        return (numbers[0] + numbers[1]) / 2  # Average of range
      end
    elsif numbers.length == 1
      return numbers[0] if numbers[0] < 20
    end

    default_volume(enclosure_type)
  end

  # Default volume based on enclosure type
  def self.default_volume(enclosure_type)
    case enclosure_type
    when :sealed
      1.25
    when :ported
      2.0
    when :bandpass_4th
      3.0
    else
      2.0
    end
  end

  # Convert parsed client data to EnclosureConfig
  def self.to_enclosure_config(client, sub_specs)
    require_relative 'enclosure_calculator'

    EnclosureCalculator::EnclosureConfig.new(
      enclosure_type: client[:final_enclosure_type],
      target_volume: client[:target_volume],
      tuning_frequency: client[:enclosure_goals][:tuning_frequency],
      num_subs: client[:subwoofer][:quantity],
      sub_specs: sub_specs,
      max_width: client[:available_space][:max_width],
      max_height: client[:available_space][:max_height],
      max_depth: client[:available_space][:max_depth],
      material_thickness: 0.75,
      double_baffle: client[:build_preferences][:double_baffle],
      extra_bracing: client[:build_preferences][:extra_bracing],
      separate_chambers: client[:build_preferences][:separate_chambers],
      power_level: client[:amplifier][:power_level] || client[:enclosure_goals][:primary_goal],
      bandpass_ratio: client[:bandpass_ratio]
    )
  end
end
