# Enclosure Calculator Module
# Calculates volumes, dimensions, and material requirements

require_relative 'port_calculator'
require_relative 'subwoofer_database'

module EnclosureCalculator
  # Standard material thickness
  DEFAULT_THICKNESS = 0.75  # 3/4" MDF

  # Enclosure configuration structure
  EnclosureConfig = Struct.new(
    :enclosure_type,      # :sealed, :ported, :bandpass_4th
    :target_volume,       # cubic feet (per chamber for bandpass)
    :tuning_frequency,    # Hz (for ported)
    :num_subs,
    :sub_specs,           # Hash from SubwooferDatabase
    :max_width,           # inches
    :max_height,          # inches
    :max_depth,           # inches
    :material_thickness,
    :double_baffle,       # boolean
    :extra_bracing,       # boolean
    :separate_chambers,   # boolean (for multiple subs)
    :power_level,         # :daily, :sql, :spl
    :bandpass_ratio,      # sealed:ported ratio for 4th order (e.g., "1:2")
    keyword_init: true
  )

  # Panel definition structure
  Panel = Struct.new(
    :name,
    :width,
    :height,
    :quantity,
    :has_cutout,
    :cutout_diameter,
    :cutout_offset_x,
    :cutout_offset_y,
    :notes,
    keyword_init: true
  )

  # Calculate gross external volume
  def self.external_volume(width, height, depth)
    width * height * depth
  end

  # Calculate internal volume (accounting for material thickness)
  def self.internal_volume(width, height, depth, thickness = DEFAULT_THICKNESS)
    internal_w = width - (2 * thickness)
    internal_h = height - (2 * thickness)
    internal_d = depth - (2 * thickness)

    internal_w * internal_h * internal_d
  end

  # Calculate internal dimensions
  def self.internal_dimensions(width, height, depth, thickness = DEFAULT_THICKNESS)
    {
      width: width - (2 * thickness),
      height: height - (2 * thickness),
      depth: depth - (2 * thickness)
    }
  end

  # Calculate bracing displacement
  # Window brace with 45° corners
  def self.bracing_displacement(internal_width, internal_height, thickness = DEFAULT_THICKNESS, window_opening_percent = 0.6)
    # Window brace is a rectangular frame
    # Opening is ~60% of dimension on each side
    window_w = internal_width * window_opening_percent
    window_h = internal_height * window_opening_percent

    # Frame dimensions
    frame_w = internal_width
    frame_h = internal_height

    # Frame volume = total area - window opening
    frame_area = (frame_w * frame_h) - (window_w * window_h)

    # 45° corner blocks (4 corners)
    # Each corner block is roughly a triangle with legs = (1 - window_opening_percent) / 2 * dimension
    corner_leg = (1 - window_opening_percent) / 2
    corner_area = 4 * (0.5 * (internal_width * corner_leg) * (internal_height * corner_leg))

    # Total brace volume
    (frame_area + corner_area) * thickness
  end

  # Calculate double baffle displacement
  def self.double_baffle_displacement(baffle_width, baffle_height, thickness = DEFAULT_THICKNESS, cutout_diameter = 0, num_cutouts = 1)
    baffle_area = baffle_width * baffle_height

    # Subtract cutout areas
    cutout_area = num_cutouts * (Math::PI * (cutout_diameter / 2) ** 2)

    (baffle_area - cutout_area) * thickness
  end

  # Calculate terminal cup displacement
  def self.terminal_cup_displacement
    # Typical terminal cup is about 3" x 3" x 1.5" deep
    3.0 * 3.0 * 1.5
  end

  # Calculate net internal volume
  def self.net_volume(config)
    int_dims = internal_dimensions(config.max_width, config.max_height, config.max_depth, config.material_thickness)

    gross_internal = int_dims[:width] * int_dims[:height] * int_dims[:depth]

    # Subtract displacements
    displacements = 0.0

    # Subwoofer displacement
    if config.sub_specs && config.sub_specs[:displacement]
      sub_disp_cu_in = config.sub_specs[:displacement] * 1728  # Convert cu ft to cu in
      displacements += sub_disp_cu_in * config.num_subs
    end

    # Double baffle displacement
    if config.double_baffle
      displacements += double_baffle_displacement(
        int_dims[:width],
        int_dims[:height],
        config.material_thickness,
        config.sub_specs ? config.sub_specs[:cutout_diameter] : 10.875,
        config.num_subs
      )
    end

    # Bracing displacement
    if config.extra_bracing
      displacements += bracing_displacement(int_dims[:width], int_dims[:height], config.material_thickness)
    end

    # Terminal cup
    displacements += terminal_cup_displacement

    gross_internal - displacements
  end

  # Convert cubic inches to cubic feet
  def self.to_cubic_feet(cubic_inches)
    cubic_inches / 1728.0
  end

  # Convert cubic feet to cubic inches
  def self.to_cubic_inches(cubic_feet)
    cubic_feet * 1728.0
  end

  # Design sealed enclosure
  def self.design_sealed(config)
    target_vol_cu_in = to_cubic_inches(config.target_volume)
    target_per_sub = target_vol_cu_in / (config.separate_chambers ? 1 : config.num_subs)

    int_dims = internal_dimensions(config.max_width, config.max_height, config.max_depth, config.material_thickness)

    # Calculate actual net volume
    actual_net = net_volume(config)
    actual_net_cuft = to_cubic_feet(actual_net)

    # Per-sub volume if separate chambers
    per_sub_vol = config.separate_chambers ? actual_net_cuft / config.num_subs : actual_net_cuft

    # Check if target fits
    fits_target = per_sub_vol >= config.target_volume * 0.95  # 5% tolerance

    {
      enclosure_type: :sealed,
      external_dimensions: {
        width: config.max_width,
        height: config.max_height,
        depth: config.max_depth
      },
      internal_dimensions: int_dims,
      gross_internal_volume_cu_in: int_dims[:width] * int_dims[:height] * int_dims[:depth],
      net_volume_cu_in: actual_net,
      net_volume_cu_ft: actual_net_cuft.round(3),
      per_sub_volume_cu_ft: per_sub_vol.round(3),
      target_volume_cu_ft: config.target_volume,
      meets_target: fits_target,
      num_subs: config.num_subs,
      separate_chambers: config.separate_chambers,
      double_baffle: config.double_baffle,
      extra_bracing: config.extra_bracing,
      material_thickness: config.material_thickness
    }
  end

  # Design ported enclosure
  def self.design_ported(config)
    sealed_design = design_sealed(config)

    int_dims = sealed_design[:internal_dimensions]

    # Design port
    port_spec = PortCalculator.design_slot_port(
      config.tuning_frequency,
      sealed_design[:net_volume_cu_in],
      int_dims[:width],
      int_dims[:depth],
      config.power_level,
      config.material_thickness
    )

    # Subtract port wall displacement from net volume
    port_wall_disp = PortCalculator.port_displacement(port_spec)
    adjusted_net = sealed_design[:net_volume_cu_in] - (port_wall_disp * 1728)

    # Recalculate port with adjusted volume
    port_spec = PortCalculator.design_slot_port(
      config.tuning_frequency,
      adjusted_net,
      int_dims[:width],
      int_dims[:depth],
      config.power_level,
      config.material_thickness
    )

    {
      enclosure_type: :ported,
      external_dimensions: sealed_design[:external_dimensions],
      internal_dimensions: int_dims,
      gross_internal_volume_cu_in: sealed_design[:gross_internal_volume_cu_in],
      net_volume_cu_in: adjusted_net,
      net_volume_cu_ft: to_cubic_feet(adjusted_net).round(3),
      per_sub_volume_cu_ft: (to_cubic_feet(adjusted_net) / config.num_subs).round(3),
      target_volume_cu_ft: config.target_volume,
      target_tuning_hz: config.tuning_frequency,
      port: port_spec,
      num_subs: config.num_subs,
      separate_chambers: config.separate_chambers,
      double_baffle: config.double_baffle,
      extra_bracing: config.extra_bracing,
      material_thickness: config.material_thickness
    }
  end

  # Design 4th order bandpass enclosure
  def self.design_bandpass_4th(config)
    # Parse ratio (e.g., "1:2" means sealed:ported = 1:2)
    ratio_parts = config.bandpass_ratio.to_s.split(':').map(&:to_f)
    sealed_ratio = ratio_parts[0] || 1.0
    ported_ratio = ratio_parts[1] || 2.0
    total_ratio = sealed_ratio + ported_ratio

    total_vol_cu_in = internal_volume(config.max_width, config.max_height, config.max_depth, config.material_thickness)

    # Subtract divider panel
    divider_thickness = config.material_thickness
    int_dims = internal_dimensions(config.max_width, config.max_height, config.max_depth, config.material_thickness)
    divider_volume = int_dims[:width] * int_dims[:height] * divider_thickness

    usable_volume = total_vol_cu_in - divider_volume

    # Split volume according to ratio
    sealed_volume = usable_volume * (sealed_ratio / total_ratio)
    ported_volume = usable_volume * (ported_ratio / total_ratio)

    # Calculate depths for each chamber
    sealed_depth = (sealed_volume / (int_dims[:width] * int_dims[:height]))
    ported_depth = (ported_volume / (int_dims[:width] * int_dims[:height]))

    # Subtract sub displacement from sealed chamber
    sub_disp = config.sub_specs ? config.sub_specs[:displacement] * 1728 * config.num_subs : 0
    sealed_net = sealed_volume - sub_disp

    # Design port for ported chamber
    port_spec = PortCalculator.design_slot_port(
      config.tuning_frequency,
      ported_volume,
      int_dims[:width],
      ported_depth,
      config.power_level,
      config.material_thickness
    )

    # Subtract port displacement
    port_wall_disp = PortCalculator.port_displacement(port_spec) * 1728
    ported_net = ported_volume - port_wall_disp

    {
      enclosure_type: :bandpass_4th,
      external_dimensions: {
        width: config.max_width,
        height: config.max_height,
        depth: config.max_depth
      },
      internal_dimensions: int_dims,
      bandpass_ratio: config.bandpass_ratio,
      sealed_chamber: {
        gross_volume_cu_in: sealed_volume,
        net_volume_cu_in: sealed_net,
        net_volume_cu_ft: to_cubic_feet(sealed_net).round(3),
        depth: sealed_depth.round(3)
      },
      ported_chamber: {
        gross_volume_cu_in: ported_volume,
        net_volume_cu_in: ported_net,
        net_volume_cu_ft: to_cubic_feet(ported_net).round(3),
        depth: ported_depth.round(3),
        port: port_spec
      },
      divider_position: sealed_depth + config.material_thickness,  # From front
      target_tuning_hz: config.tuning_frequency,
      num_subs: config.num_subs,
      double_baffle: config.double_baffle,
      extra_bracing: config.extra_bracing,
      material_thickness: config.material_thickness
    }
  end

  # Main design entry point
  def self.design(config)
    case config.enclosure_type
    when :sealed
      design_sealed(config)
    when :ported
      design_ported(config)
    when :bandpass_4th, :bandpass
      design_bandpass_4th(config)
    else
      raise ArgumentError, "Unknown enclosure type: #{config.enclosure_type}"
    end
  end

  # Generate panel list for enclosure
  def self.generate_panels(design_result, config)
    panels = []
    t = config.material_thickness
    ext = design_result[:external_dimensions]
    int_dims = design_result[:internal_dimensions]

    case design_result[:enclosure_type]
    when :sealed, :ported
      # Front baffle (with sub cutouts)
      panels << Panel.new(
        name: "Front Baffle",
        width: ext[:width],
        height: ext[:height],
        quantity: config.double_baffle ? 2 : 1,
        has_cutout: true,
        cutout_diameter: config.sub_specs ? config.sub_specs[:cutout_diameter] : 10.875,
        cutout_offset_x: ext[:width] / 2,
        cutout_offset_y: ext[:height] / 2,
        notes: config.double_baffle ? "Double baffle - cut 2 identical pieces" : nil
      )

      # Back panel (with terminal cup cutout)
      panels << Panel.new(
        name: "Back Panel",
        width: ext[:width],
        height: ext[:height],
        quantity: 1,
        has_cutout: true,
        cutout_diameter: 3.0,  # Terminal cup
        cutout_offset_x: ext[:width] / 2,
        cutout_offset_y: ext[:height] - 3.0,
        notes: "Terminal cup cutout"
      )

      # Top panel
      panels << Panel.new(
        name: "Top Panel",
        width: ext[:width],
        height: ext[:depth] - (2 * t),
        quantity: 1,
        has_cutout: false
      )

      # Bottom panel
      panels << Panel.new(
        name: "Bottom Panel",
        width: ext[:width],
        height: ext[:depth] - (2 * t),
        quantity: 1,
        has_cutout: false
      )

      # Left side
      panels << Panel.new(
        name: "Left Side",
        width: ext[:depth],
        height: ext[:height] - (2 * t),
        quantity: 1,
        has_cutout: false
      )

      # Right side
      panels << Panel.new(
        name: "Right Side",
        width: ext[:depth],
        height: ext[:height] - (2 * t),
        quantity: 1,
        has_cutout: false
      )

      # Port wall (ported only)
      if design_result[:enclosure_type] == :ported && design_result[:port]
        port = design_result[:port]
        panels << Panel.new(
          name: "Port Wall",
          width: port[:port_length],
          height: port[:port_height],
          quantity: 1,
          has_cutout: false,
          notes: "Slot port divider wall"
        )

        # Port end cap if L-shaped
        if port[:path_type] == :l_shaped
          panels << Panel.new(
            name: "Port End Cap",
            width: port[:port_width] + t,
            height: port[:port_height],
            quantity: 1,
            has_cutout: false,
            notes: "Closes port at turn"
          )
        end
      end

      # Bracing
      if config.extra_bracing
        panels << Panel.new(
          name: "Window Brace",
          width: int_dims[:width],
          height: int_dims[:height],
          quantity: 1,
          has_cutout: true,
          cutout_diameter: [int_dims[:width], int_dims[:height]].min * 0.6,  # 60% window
          cutout_offset_x: int_dims[:width] / 2,
          cutout_offset_y: int_dims[:height] / 2,
          notes: "Window brace with 45° corner blocks"
        )
      end

      # Separate chamber divider
      if config.separate_chambers && config.num_subs > 1
        panels << Panel.new(
          name: "Chamber Divider",
          width: ext[:depth] - (2 * t),
          height: ext[:height] - (2 * t),
          quantity: config.num_subs - 1,
          has_cutout: false,
          notes: "Divides chambers for each subwoofer"
        )
      end

    when :bandpass_4th
      # Similar but with divider between chambers
      # Front baffle (sealed chamber - no visible cutout, sub fires into ported chamber)
      panels << Panel.new(
        name: "Front Panel (Sealed)",
        width: ext[:width],
        height: ext[:height],
        quantity: 1,
        has_cutout: false,
        notes: "Sealed chamber front - no cutouts"
      )

      # Back panel (ported chamber - port exit)
      panels << Panel.new(
        name: "Back Panel (Ported)",
        width: ext[:width],
        height: ext[:height],
        quantity: 1,
        has_cutout: true,
        cutout_diameter: nil,  # Rectangular port opening
        notes: "Port exit opening: #{design_result[:ported_chamber][:port][:port_width].round(2)}\" x #{design_result[:ported_chamber][:port][:port_height].round(2)}\""
      )

      # Chamber divider (sub mounts here, fires into ported chamber)
      panels << Panel.new(
        name: "Chamber Divider/Baffle",
        width: ext[:width] - (2 * t),
        height: ext[:height] - (2 * t),
        quantity: config.double_baffle ? 2 : 1,
        has_cutout: true,
        cutout_diameter: config.sub_specs ? config.sub_specs[:cutout_diameter] : 10.875,
        cutout_offset_x: (ext[:width] - (2 * t)) / 2,
        cutout_offset_y: (ext[:height] - (2 * t)) / 2,
        notes: "Sub mounts here, fires into ported chamber"
      )

      # Top, bottom, sides
      panels << Panel.new(name: "Top Panel", width: ext[:width], height: ext[:depth] - (2 * t), quantity: 1, has_cutout: false)
      panels << Panel.new(name: "Bottom Panel", width: ext[:width], height: ext[:depth] - (2 * t), quantity: 1, has_cutout: false)
      panels << Panel.new(name: "Left Side", width: ext[:depth], height: ext[:height] - (2 * t), quantity: 1, has_cutout: false)
      panels << Panel.new(name: "Right Side", width: ext[:depth], height: ext[:height] - (2 * t), quantity: 1, has_cutout: false)

      # Port wall for ported chamber
      port = design_result[:ported_chamber][:port]
      panels << Panel.new(
        name: "Port Wall",
        width: port[:port_length],
        height: port[:port_height],
        quantity: 1,
        has_cutout: false,
        notes: "Ported chamber slot port"
      )
    end

    panels
  end

  # Calculate total material needed
  def self.calculate_material(panels, kerf = 0.125)
    total_area = 0.0
    panel_list = []

    panels.each do |panel|
      # Add kerf to each dimension for cutting
      cut_width = panel.width + kerf
      cut_height = panel.height + kerf
      area = cut_width * cut_height * panel.quantity

      total_area += area
      panel_list << {
        name: panel.name,
        width: panel.width.round(3),
        height: panel.height.round(3),
        cut_width: cut_width.round(3),
        cut_height: cut_height.round(3),
        quantity: panel.quantity,
        area_each: (panel.width * panel.height).round(2),
        total_area: area.round(2),
        has_cutout: panel.has_cutout,
        notes: panel.notes
      }
    end

    # Standard sheet is 48" x 96" = 4608 sq in
    sheet_area = 48.0 * 96.0
    sheets_needed = (total_area / sheet_area).ceil

    {
      panels: panel_list,
      total_area_sq_in: total_area.round(2),
      total_area_sq_ft: (total_area / 144.0).round(2),
      sheet_size: "48\" x 96\" (4' x 8')",
      sheets_needed: sheets_needed,
      utilization_percent: ((total_area / (sheets_needed * sheet_area)) * 100).round(1),
      kerf_width: kerf
    }
  end

  # Optimize external dimensions to hit target volume
  def self.optimize_dimensions(target_volume_cuft, max_width, max_height, max_depth, config)
    target_cu_in = to_cubic_inches(target_volume_cuft)
    t = config.material_thickness

    # Start with max dimensions and reduce to hit target
    # Priority: reduce depth first (most flexible), then width, then height

    best_dims = { width: max_width, height: max_height, depth: max_depth }
    best_diff = Float::INFINITY

    # Try reducing depth
    (max_depth * 10).to_i.downto((4 * t * 10).to_i) do |d10|
      depth = d10 / 10.0
      test_config = config.dup
      test_config.max_depth = depth

      vol = net_volume(test_config)
      diff = (vol - target_cu_in).abs

      if diff < best_diff
        best_diff = diff
        best_dims = { width: max_width, height: max_height, depth: depth }
      end

      break if vol <= target_cu_in
    end

    best_dims
  end
end
