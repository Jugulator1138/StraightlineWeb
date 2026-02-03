# SketchUp Model Builder
# Generates .skp files for subwoofer enclosures

module SketchupBuilder
  # Generate Ruby script that SketchUp can execute
  # This creates a .rb file that when loaded in SketchUp, builds the model
  def self.generate_sketchup_script(design_result, panels, config, client_name, output_path)
    ext = design_result[:external_dimensions]
    int_dims = design_result[:internal_dimensions]
    t = config.material_thickness

    script = <<~RUBY
      # SketchUp Enclosure Builder Script
      # Generated for: #{client_name}
      # Enclosure Type: #{design_result[:enclosure_type]}
      # Generated: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}

      # Clear the model
      model = Sketchup.active_model
      model.start_operation('Build Enclosure', true)

      # Delete all existing entities
      model.entities.clear!

      # Set units to inches
      model.options["UnitsOptions"]["LengthUnit"] = 0  # Inches

      entities = model.entities
      materials = model.materials

      # Create materials
      mdf_material = materials.add("MDF")
      mdf_material.color = Sketchup::Color.new(194, 178, 128)  # MDF tan color

      cutout_material = materials.add("Cutout")
      cutout_material.color = Sketchup::Color.new(50, 50, 50)  # Dark for cutouts

      port_material = materials.add("Port")
      port_material.color = Sketchup::Color.new(100, 100, 100)  # Gray for port

      # Dimensions
      WIDTH = #{ext[:width]}
      HEIGHT = #{ext[:height]}
      DEPTH = #{ext[:depth]}
      THICKNESS = #{t}
      INTERNAL_W = #{int_dims[:width]}
      INTERNAL_H = #{int_dims[:height]}
      INTERNAL_D = #{int_dims[:depth]}

      # Helper method to create a box
      def create_panel(entities, origin, width, height, depth, material, name)
        x, y, z = origin

        # Create the 8 corners
        pts = [
          [x, y, z],
          [x + width, y, z],
          [x + width, y + depth, z],
          [x, y + depth, z],
          [x, y, z + height],
          [x + width, y, z + height],
          [x + width, y + depth, z + height],
          [x, y + depth, z + height]
        ]

        group = entities.add_group
        grp_ents = group.entities

        # Bottom face
        face = grp_ents.add_face(pts[0], pts[1], pts[2], pts[3])
        face.pushpull(height)

        group.name = name
        group.material = material

        group
      end

      # Helper to create circular cutout
      def create_circular_cutout(group, center_x, center_y, diameter, face_z)
        entities = group.entities
        center = Geom::Point3d.new(center_x, face_z, center_y)
        normal = Geom::Vector3d.new(0, 1, 0)
        radius = diameter / 2.0

        # Create circle on the face
        edges = entities.add_circle(center, normal, radius, 48)
        face = entities.add_face(edges)
        face.erase! if face
      end

      # Create enclosure panels
      puts "Building enclosure panels..."

      #{generate_panel_creation_code(design_result, panels, config)}

      #{generate_port_code(design_result, config) if design_result[:enclosure_type] == :ported}

      #{generate_bracing_code(design_result, config) if config.extra_bracing}

      #{generate_bandpass_divider_code(design_result, config) if design_result[:enclosure_type] == :bandpass_4th}

      # Create exploded view group
      puts "Creating exploded view..."
      exploded_group = entities.add_group
      exploded_group.name = "Exploded View"
      exploded_offset = WIDTH + 20  # 20" gap

      #{generate_exploded_view_code(panels, config)}

      # Add dimensions
      puts "Adding dimensions..."
      #{generate_dimension_code(design_result)}

      # Add text labels
      puts "Adding labels..."
      #{generate_label_code(design_result, config, client_name)}

      model.commit_operation
      puts "Enclosure model complete!"

      # Save the model
      save_path = "#{output_path.gsub('\\', '/')}"
      model.save(save_path)
      puts "Model saved to: \#{save_path}"
    RUBY

    script
  end

  # Generate panel creation code
  def self.generate_panel_creation_code(design_result, panels, config)
    ext = design_result[:external_dimensions]
    t = config.material_thickness
    code = []

    # Assembled enclosure group
    code << "assembled = entities.add_group"
    code << "assembled.name = 'Assembled Enclosure'"
    code << "asm_ents = assembled.entities"
    code << ""

    # Front baffle
    code << "# Front Baffle"
    code << "front_baffle = create_panel(asm_ents, [0, 0, 0], WIDTH, HEIGHT, THICKNESS, mdf_material, 'Front Baffle')"

    # Add subwoofer cutouts
    if config.sub_specs
      cutout_d = config.sub_specs[:cutout_diameter]
      code << "# Subwoofer cutout(s)"

      if config.num_subs == 1
        code << "create_circular_cutout(front_baffle, WIDTH/2, HEIGHT/2, #{cutout_d}, 0)"
      elsif config.num_subs == 2
        # Side by side
        spacing = ext[:width] / 3
        code << "create_circular_cutout(front_baffle, #{spacing}, HEIGHT/2, #{cutout_d}, 0)"
        code << "create_circular_cutout(front_baffle, #{spacing * 2}, HEIGHT/2, #{cutout_d}, 0)"
      else
        # Multiple subs - arrange in grid
        config.num_subs.times do |i|
          x_pos = (i + 1) * ext[:width] / (config.num_subs + 1)
          code << "create_circular_cutout(front_baffle, #{x_pos}, HEIGHT/2, #{cutout_d}, 0)"
        end
      end
    end

    # Double baffle
    if config.double_baffle
      code << ""
      code << "# Double Baffle (second layer)"
      code << "double_baffle = create_panel(asm_ents, [0, THICKNESS, 0], WIDTH, HEIGHT, THICKNESS, mdf_material, 'Double Baffle')"
      if config.sub_specs
        cutout_d = config.sub_specs[:cutout_diameter]
        if config.num_subs == 1
          code << "create_circular_cutout(double_baffle, WIDTH/2, HEIGHT/2, #{cutout_d}, THICKNESS)"
        elsif config.num_subs == 2
          spacing = ext[:width] / 3
          code << "create_circular_cutout(double_baffle, #{spacing}, HEIGHT/2, #{cutout_d}, THICKNESS)"
          code << "create_circular_cutout(double_baffle, #{spacing * 2}, HEIGHT/2, #{cutout_d}, THICKNESS)"
        end
      end
    end

    baffle_depth = config.double_baffle ? t * 2 : t

    # Back panel
    code << ""
    code << "# Back Panel"
    code << "back_panel = create_panel(asm_ents, [0, DEPTH - THICKNESS, 0], WIDTH, HEIGHT, THICKNESS, mdf_material, 'Back Panel')"
    code << "# Terminal cup cutout"
    code << "create_circular_cutout(back_panel, WIDTH/2, HEIGHT - 3, 3.0, DEPTH - THICKNESS)"

    # Top panel
    code << ""
    code << "# Top Panel"
    code << "top_panel = create_panel(asm_ents, [0, #{baffle_depth}, HEIGHT - THICKNESS], WIDTH, THICKNESS, DEPTH - #{baffle_depth} - THICKNESS, mdf_material, 'Top Panel')"

    # Bottom panel
    code << ""
    code << "# Bottom Panel"
    code << "bottom_panel = create_panel(asm_ents, [0, #{baffle_depth}, 0], WIDTH, THICKNESS, DEPTH - #{baffle_depth} - THICKNESS, mdf_material, 'Bottom Panel')"

    # Left side
    code << ""
    code << "# Left Side"
    code << "left_side = create_panel(asm_ents, [0, #{baffle_depth}, THICKNESS], THICKNESS, HEIGHT - (2 * THICKNESS), DEPTH - #{baffle_depth} - THICKNESS, mdf_material, 'Left Side')"

    # Right side
    code << ""
    code << "# Right Side"
    code << "right_side = create_panel(asm_ents, [WIDTH - THICKNESS, #{baffle_depth}, THICKNESS], THICKNESS, HEIGHT - (2 * THICKNESS), DEPTH - #{baffle_depth} - THICKNESS, mdf_material, 'Right Side')"

    code.join("\n")
  end

  # Generate port construction code
  def self.generate_port_code(design_result, config)
    return "" unless design_result[:port]

    port = design_result[:port]
    t = config.material_thickness
    baffle_depth = config.double_baffle ? t * 2 : t

    code = []
    code << ""
    code << "# === SLOT PORT ==="
    code << "# Port dimensions: #{port[:port_width].round(2)}\"W x #{port[:port_height].round(2)}\"H x #{port[:port_length].round(2)}\"L"
    code << "# Tuning: #{port[:actual_tuning]} Hz"
    code << ""

    # Port wall (divider between port and main chamber)
    code << "# Port Divider Wall"
    code << "port_wall = create_panel(asm_ents, [THICKNESS, #{baffle_depth}, THICKNESS], THICKNESS, #{port[:port_height]}, #{port[:port_length]}, port_material, 'Port Wall')"

    if port[:path_type] == :l_shaped
      # Add end cap for L-shaped port
      code << ""
      code << "# Port End Cap (L-shaped turn)"
      # Position at the end of the straight section
      code << "port_end = create_panel(asm_ents, [THICKNESS, #{baffle_depth + port[:port_length]}, THICKNESS], #{port[:port_width] + t}, #{port[:port_height]}, THICKNESS, port_material, 'Port End Cap')"
    end

    code.join("\n")
  end

  # Generate bracing code
  def self.generate_bracing_code(design_result, config)
    int_dims = design_result[:internal_dimensions]
    t = config.material_thickness
    baffle_depth = config.double_baffle ? t * 2 : t

    # Window brace dimensions
    window_pct = 0.6
    window_w = int_dims[:width] * window_pct
    window_h = int_dims[:height] * window_pct
    frame_border = (1 - window_pct) / 2

    code = []
    code << ""
    code << "# === WINDOW BRACE ==="
    code << "# Positioned at middle of enclosure depth"
    code << ""

    # Create brace as a group with window cutout
    mid_depth = baffle_depth + (int_dims[:depth] / 2)

    code << "brace_group = asm_ents.add_group"
    code << "brace_group.name = 'Window Brace'"
    code << "brace_ents = brace_group.entities"
    code << ""
    code << "# Outer frame"
    code << "brace_pts = ["
    code << "  [THICKNESS, #{mid_depth}, THICKNESS],"
    code << "  [WIDTH - THICKNESS, #{mid_depth}, THICKNESS],"
    code << "  [WIDTH - THICKNESS, #{mid_depth}, HEIGHT - THICKNESS],"
    code << "  [THICKNESS, #{mid_depth}, HEIGHT - THICKNESS]"
    code << "]"
    code << "outer_face = brace_ents.add_face(brace_pts)"
    code << ""
    code << "# Window opening"
    code << "window_margin_x = #{(int_dims[:width] * frame_border).round(3)}"
    code << "window_margin_z = #{(int_dims[:height] * frame_border).round(3)}"
    code << "window_pts = ["
    code << "  [THICKNESS + window_margin_x, #{mid_depth}, THICKNESS + window_margin_z],"
    code << "  [WIDTH - THICKNESS - window_margin_x, #{mid_depth}, THICKNESS + window_margin_z],"
    code << "  [WIDTH - THICKNESS - window_margin_x, #{mid_depth}, HEIGHT - THICKNESS - window_margin_z],"
    code << "  [THICKNESS + window_margin_x, #{mid_depth}, HEIGHT - THICKNESS - window_margin_z]"
    code << "]"
    code << "window_face = brace_ents.add_face(window_pts)"
    code << "window_face.erase! if window_face"
    code << ""
    code << "# Extrude brace"
    code << "outer_face.pushpull(THICKNESS) if outer_face"
    code << "brace_group.material = mdf_material"

    code.join("\n")
  end

  # Generate bandpass divider code
  def self.generate_bandpass_divider_code(design_result, config)
    return "" unless design_result[:enclosure_type] == :bandpass_4th

    t = config.material_thickness
    divider_pos = design_result[:divider_position]

    code = []
    code << ""
    code << "# === BANDPASS CHAMBER DIVIDER ==="
    code << "# Subwoofer mounts on this panel, fires into ported chamber"
    code << ""
    code << "divider = create_panel(asm_ents, [THICKNESS, #{divider_pos}, THICKNESS], INTERNAL_W, INTERNAL_H, THICKNESS, mdf_material, 'Chamber Divider')"

    # Add sub cutout
    if config.sub_specs
      cutout_d = config.sub_specs[:cutout_diameter]
      code << "create_circular_cutout(divider, INTERNAL_W/2 + THICKNESS, INTERNAL_H/2 + THICKNESS, #{cutout_d}, #{divider_pos})"
    end

    code.join("\n")
  end

  # Generate exploded view code
  def self.generate_exploded_view_code(panels, config)
    code = []
    offset_y = 0
    gap = 5  # inches between exploded panels

    code << "exp_ents = exploded_group.entities"
    code << ""

    panels.each_with_index do |panel, idx|
      code << "# #{panel.name}"
      code << "exp_panel_#{idx} = create_panel(exp_ents, [WIDTH + 20, #{offset_y}, 0], #{panel.width}, #{panel.height}, THICKNESS, mdf_material, '#{panel.name} (exploded)')"

      if panel.has_cutout && panel.cutout_diameter && panel.cutout_diameter > 0
        code << "create_circular_cutout(exp_panel_#{idx}, #{panel.cutout_offset_x || panel.width / 2}, #{panel.cutout_offset_y || panel.height / 2}, #{panel.cutout_diameter}, #{offset_y})"
      end

      offset_y += panel.height + gap
      code << ""
    end

    code.join("\n")
  end

  # Generate dimension annotations
  def self.generate_dimension_code(design_result)
    ext = design_result[:external_dimensions]

    code = []
    code << "# Add dimension text"
    code << "dim_group = entities.add_group"
    code << "dim_group.name = 'Dimensions'"
    code << ""

    # Overall dimensions text
    code << "# Width dimension"
    code << "pt1 = Geom::Point3d.new(0, -3, -1)"
    code << "vec = Geom::Vector3d.new(0, 0, 1)"
    code << "dim_group.entities.add_text('Width: #{ext[:width]}\"', pt1)"
    code << ""
    code << "# Height dimension"
    code << "pt2 = Geom::Point3d.new(-3, 0, HEIGHT/2)"
    code << "dim_group.entities.add_text('Height: #{ext[:height]}\"', pt2)"
    code << ""
    code << "# Depth dimension"
    code << "pt3 = Geom::Point3d.new(WIDTH + 3, DEPTH/2, -1)"
    code << "dim_group.entities.add_text('Depth: #{ext[:depth]}\"', pt3)"

    code.join("\n")
  end

  # Generate label code
  def self.generate_label_code(design_result, config, client_name)
    code = []

    code << "# Project info label"
    code << "info_pt = Geom::Point3d.new(0, -10, HEIGHT + 5)"
    code << "info_text = 'Client: #{client_name}\\n'"
    code << "info_text += 'Type: #{design_result[:enclosure_type].to_s.capitalize}\\n'"

    if design_result[:enclosure_type] == :ported && design_result[:port]
      code << "info_text += 'Tuning: #{design_result[:port][:actual_tuning]} Hz\\n'"
    end

    code << "info_text += 'Net Volume: #{design_result[:net_volume_cu_ft] || design_result.dig(:ported_chamber, :net_volume_cu_ft)} cu ft\\n'"
    code << "info_text += 'Subs: #{config.num_subs}x #{config.sub_specs ? config.sub_specs[:model] : 'Unknown'}'"
    code << "entities.add_text(info_text, info_pt)"

    code.join("\n")
  end

  # Write the complete SketchUp script file
  def self.write_script(design_result, panels, config, client_name, output_dir)
    # Create unique filename based on client and timestamp
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    safe_name = client_name.gsub(/[^a-zA-Z0-9]/, '_')

    skp_filename = "#{safe_name}_#{design_result[:enclosure_type]}_#{timestamp}.skp"
    rb_filename = "#{safe_name}_#{design_result[:enclosure_type]}_#{timestamp}_builder.rb"

    skp_path = File.join(output_dir, skp_filename)
    rb_path = File.join(output_dir, rb_filename)

    script_content = generate_sketchup_script(design_result, panels, config, client_name, skp_path)

    File.write(rb_path, script_content)

    {
      script_path: rb_path,
      skp_path: skp_path,
      skp_filename: skp_filename
    }
  end
end
