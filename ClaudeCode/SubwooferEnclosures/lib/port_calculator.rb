# Port Calculator Module
# Calculates slot port dimensions for target tuning frequency

module PortCalculator
  # Speed of sound in inches/second at ~70°F
  SPEED_OF_SOUND = 13504.0  # inches/second (343 m/s)

  # Standard slot port configuration
  # Port uses box walls as two sides (L-shaped or U-shaped path)

  # Calculate port length from tuning frequency
  # Using the formula: Fb = (c / 2π) × √(Sp / (Vb × Lp))
  # Rearranged: Lp = (c² × Sp) / (4π² × Fb² × Vb)
  #
  # With end correction: Lv = Lp - (0.825 × √Sp)
  #
  # @param tuning_freq [Float] Target tuning frequency in Hz
  # @param box_volume [Float] Net box volume in cubic inches
  # @param port_area [Float] Port cross-sectional area in square inches
  # @return [Float] Port length in inches (including end correction)
  def self.port_length(tuning_freq, box_volume, port_area)
    # Convert to consistent units
    fb = tuning_freq.to_f
    vb = box_volume.to_f          # cubic inches
    sp = port_area.to_f           # square inches

    return 0 if fb <= 0 || vb <= 0 || sp <= 0

    # Calculate theoretical port length
    # Lp = (c² × Sp) / (4π² × Fb² × Vb)
    lp = (SPEED_OF_SOUND ** 2 * sp) / (4 * Math::PI ** 2 * fb ** 2 * vb)

    # Apply end correction (typically 0.825 × √Sp for flanged port)
    end_correction = 0.825 * Math.sqrt(sp)

    # Actual physical port length needed
    actual_length = lp - end_correction

    # Ensure minimum reasonable length
    [actual_length, 1.0].max
  end

  # Calculate tuning frequency from port dimensions
  # @param box_volume [Float] Net box volume in cubic inches
  # @param port_area [Float] Port cross-sectional area in square inches
  # @param port_length [Float] Physical port length in inches
  # @return [Float] Tuning frequency in Hz
  def self.tuning_frequency(box_volume, port_area, port_length)
    vb = box_volume.to_f
    sp = port_area.to_f
    lv = port_length.to_f

    return 0 if vb <= 0 || sp <= 0 || lv <= 0

    # Add end correction to get effective length
    end_correction = 0.825 * Math.sqrt(sp)
    lp = lv + end_correction

    # Fb = (c / 2π) × √(Sp / (Vb × Lp))
    (SPEED_OF_SOUND / (2 * Math::PI)) * Math.sqrt(sp / (vb * lp))
  end

  # Calculate minimum port area to avoid port noise
  # Rule of thumb: 12-16 sq in per cubic foot of box volume for daily drivers
  # Higher for SPL: 16-20 sq in per cubic foot
  # @param box_volume_cuft [Float] Box volume in cubic feet
  # @param power_level [Symbol] :daily, :sql, :spl
  # @return [Float] Minimum recommended port area in square inches
  def self.minimum_port_area(box_volume_cuft, power_level = :sql)
    multiplier = case power_level
                 when :daily then 12.0
                 when :sql   then 14.0
                 when :spl   then 18.0
                 else 14.0
                 end

    box_volume_cuft * multiplier
  end

  # Calculate slot port dimensions
  # Slot port uses one box wall as a side
  # @param port_area [Float] Required port area in square inches
  # @param max_width [Float] Maximum port width (typically internal box dimension)
  # @param material_thickness [Float] Material thickness in inches
  # @return [Hash] Port dimensions { width:, height:, wall_thickness: }
  def self.slot_port_dimensions(port_area, max_width, material_thickness = 0.75)
    # Port width is limited by box internal dimension minus some clearance
    # Reserve space for port wall
    usable_width = max_width - material_thickness - 0.5  # 0.5" clearance

    # Calculate port height needed for target area
    # Start with a reasonable width (usually full internal width is best for low tuning)
    port_width = [usable_width, 3.0].max  # Minimum 3" wide

    # Height = Area / Width
    port_height = port_area / port_width

    # If height is too small (< 2"), increase it and reduce width
    if port_height < 2.0
      port_height = 2.0
      port_width = port_area / port_height
    end

    # If height is too large (> 6"), cap it and adjust width
    if port_height > 6.0
      port_height = 6.0
      port_width = port_area / port_height
    end

    {
      width: port_width.round(3),
      height: port_height.round(3),
      area: (port_width * port_height).round(3),
      wall_thickness: material_thickness
    }
  end

  # Design complete slot port for enclosure
  # @param tuning_freq [Float] Target frequency in Hz
  # @param net_volume [Float] Net internal volume in cubic inches
  # @param box_internal_width [Float] Internal box width in inches
  # @param box_internal_depth [Float] Internal box depth in inches
  # @param power_level [Symbol] :daily, :sql, :spl
  # @param material_thickness [Float] Material thickness
  # @return [Hash] Complete port specification
  def self.design_slot_port(tuning_freq, net_volume, box_internal_width, box_internal_depth, power_level = :sql, material_thickness = 0.75)
    # Convert net volume to cubic feet for port area calculation
    net_volume_cuft = net_volume / 1728.0

    # Calculate minimum port area
    min_area = minimum_port_area(net_volume_cuft, power_level)

    # Get slot dimensions that fit the box
    slot = slot_port_dimensions(min_area, box_internal_width, material_thickness)

    # Calculate port length for tuning
    length = port_length(tuning_freq, net_volume, slot[:area])

    # Check if port fits in box depth
    # Slot port typically runs along back wall, then turns along side
    # Available length = depth + width (L-shaped path)
    available_path = box_internal_depth + box_internal_width - slot[:width] - (material_thickness * 2)

    port_fits = length <= available_path
    path_type = length <= box_internal_depth ? :straight : :l_shaped

    # Calculate port displacement
    port_volume = slot[:area] * length  # cubic inches
    port_volume_cuft = port_volume / 1728.0

    # Verify tuning frequency
    actual_tuning = tuning_frequency(net_volume, slot[:area], length)

    {
      tuning_frequency: tuning_freq,
      actual_tuning: actual_tuning.round(1),
      port_width: slot[:width],
      port_height: slot[:height],
      port_area: slot[:area],
      port_length: length.round(3),
      port_volume_cubic_inches: port_volume.round(2),
      port_volume_cubic_feet: port_volume_cuft.round(4),
      path_type: path_type,
      fits_in_box: port_fits,
      available_path_length: available_path.round(2),
      material_thickness: material_thickness,
      power_level: power_level
    }
  end

  # Calculate port displacement for volume calculations
  # @param port_spec [Hash] Port specification from design_slot_port
  # @return [Float] Port displacement in cubic feet
  def self.port_displacement(port_spec)
    # Port walls displacement (the MDF pieces that form the port)
    # This is separate from the air volume inside the port
    port_wall_length = port_spec[:port_length]
    port_wall_height = port_spec[:port_height]
    material = port_spec[:material_thickness]

    # One port wall piece (the divider between port and main chamber)
    wall_volume = port_wall_length * port_wall_height * material

    wall_volume / 1728.0  # Convert to cubic feet
  end

  # Suggest port adjustments if port doesn't fit
  # @param port_spec [Hash] Port specification
  # @param max_length [Float] Maximum available port path length
  # @return [Hash] Adjusted port specification or suggestions
  def self.suggest_adjustments(port_spec, max_length)
    return port_spec if port_spec[:fits_in_box]

    suggestions = []

    # Option 1: Increase port area to shorten length
    # Higher area = shorter length for same tuning
    current_area = port_spec[:port_area]
    needed_reduction = port_spec[:port_length] - max_length

    # Estimate new area needed (roughly proportional)
    new_area = current_area * (port_spec[:port_length] / max_length) * 1.1

    suggestions << {
      type: :increase_port_area,
      message: "Increase port area from #{current_area.round(1)} to ~#{new_area.round(1)} sq in",
      new_port_height: (new_area / port_spec[:port_width]).round(2)
    }

    # Option 2: Raise tuning frequency
    # Calculate what tuning would result from max length
    higher_tuning = tuning_frequency(
      port_spec[:port_volume_cubic_inches] / port_spec[:port_length] * 1728, # Estimate net volume
      port_spec[:port_area],
      max_length
    )

    suggestions << {
      type: :raise_tuning,
      message: "Raise tuning to ~#{higher_tuning.round(0)} Hz to fit port",
      new_tuning: higher_tuning.round(0)
    }

    # Option 3: External port
    suggestions << {
      type: :external_port,
      message: "Use external port extending #{needed_reduction.round(1)}\" outside box"
    }

    {
      fits: false,
      current_length: port_spec[:port_length],
      max_available: max_length,
      excess: needed_reduction.round(2),
      suggestions: suggestions
    }
  end

  # Calculate port velocity (for noise estimation)
  # @param port_area [Float] Port area in square inches
  # @param cone_area [Float] Total cone area in square inches
  # @param xmax [Float] One-way Xmax in mm
  # @param frequency [Float] Frequency in Hz
  # @return [Float] Port velocity in m/s
  def self.port_velocity(port_area, cone_area, xmax, frequency)
    # Convert units
    xmax_m = xmax / 1000.0  # mm to meters
    port_area_m2 = port_area * 0.00064516  # sq in to sq m
    cone_area_m2 = cone_area * 0.00064516

    # Peak cone velocity
    cone_velocity = 2 * Math::PI * frequency * xmax_m

    # Port velocity = cone velocity * (cone area / port area)
    cone_velocity * (cone_area_m2 / port_area_m2)
  end

  # Estimate if port will be noisy
  # Rule of thumb: > 25-30 m/s gets noisy
  # @param velocity [Float] Port velocity in m/s
  # @return [Symbol] :quiet, :moderate, :loud
  def self.noise_estimate(velocity)
    case velocity
    when 0..20 then :quiet
    when 20..30 then :moderate
    else :loud
    end
  end
end
