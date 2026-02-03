# Cut List and Nesting Generator
# Creates optimized cut lists and nesting layouts for 4x8 sheets

module CutListGenerator
  # Standard sheet dimensions
  SHEET_WIDTH = 48.0   # inches
  SHEET_LENGTH = 96.0  # inches
  KERF = 0.125         # 1/8" blade kerf

  # Panel for nesting
  NestPanel = Struct.new(:name, :width, :height, :quantity, :placed, :x, :y, :rotated, keyword_init: true)

  # Generate cut list from panels
  def self.generate_cut_list(panels, material_thickness = 0.75)
    cut_list = []

    panels.each do |panel|
      panel.quantity.times do |i|
        cut_list << {
          name: panel.quantity > 1 ? "#{panel.name} (#{i + 1}/#{panel.quantity})" : panel.name,
          width: panel.width.round(3),
          height: panel.height.round(3),
          area_sq_in: (panel.width * panel.height).round(2),
          has_cutout: panel.has_cutout,
          cutout_info: panel.has_cutout ? {
            diameter: panel.cutout_diameter,
            offset_x: panel.cutout_offset_x,
            offset_y: panel.cutout_offset_y
          } : nil,
          notes: panel.notes
        }
      end
    end

    # Sort by area (largest first for better nesting)
    cut_list.sort_by { |p| -p[:area_sq_in] }
  end

  # Simple bin-packing nesting algorithm
  # Uses First-Fit Decreasing Height (FFDH) algorithm
  def self.nest_panels(panels, sheet_width = SHEET_WIDTH, sheet_length = SHEET_LENGTH, kerf = KERF)
    # Create NestPanel objects from cut list
    nest_panels = panels.map do |p|
      NestPanel.new(
        name: p[:name],
        width: p[:width] + kerf,
        height: p[:height] + kerf,
        quantity: 1,
        placed: false,
        x: nil,
        y: nil,
        rotated: false
      )
    end

    # Sort by height (tallest first)
    nest_panels.sort_by! { |p| -[p.width, p.height].max }

    sheets = []
    current_sheet = new_sheet(sheet_width, sheet_length)

    nest_panels.each do |panel|
      placed = false

      # Try to place on existing sheets
      sheets.each do |sheet|
        if place_panel(sheet, panel)
          placed = true
          break
        end
      end

      # Try current sheet
      if !placed && place_panel(current_sheet, panel)
        placed = true
      end

      # Start new sheet if needed
      unless placed
        sheets << current_sheet unless current_sheet[:panels].empty?
        current_sheet = new_sheet(sheet_width, sheet_length)

        unless place_panel(current_sheet, panel)
          # Panel doesn't fit on sheet - error
          panel.placed = false
          puts "WARNING: Panel '#{panel.name}' (#{panel.width}\" x #{panel.height}\") doesn't fit on sheet!"
        end
      end
    end

    # Add final sheet if it has panels
    sheets << current_sheet unless current_sheet[:panels].empty?

    sheets
  end

  # Create new sheet structure
  def self.new_sheet(width, length)
    {
      width: width,
      length: length,
      panels: [],
      free_rectangles: [{ x: 0, y: 0, width: width, height: length }],
      used_area: 0
    }
  end

  # Try to place panel on sheet using guillotine algorithm
  def self.place_panel(sheet, panel)
    best_rect = nil
    best_fit = Float::INFINITY
    should_rotate = false

    sheet[:free_rectangles].each do |rect|
      # Try normal orientation
      if panel.width <= rect[:width] && panel.height <= rect[:height]
        waste = (rect[:width] - panel.width) * rect[:height] + (rect[:height] - panel.height) * panel.width
        if waste < best_fit
          best_fit = waste
          best_rect = rect
          should_rotate = false
        end
      end

      # Try rotated orientation
      if panel.height <= rect[:width] && panel.width <= rect[:height]
        waste = (rect[:width] - panel.height) * rect[:height] + (rect[:height] - panel.width) * panel.height
        if waste < best_fit
          best_fit = waste
          best_rect = rect
          should_rotate = true
        end
      end
    end

    return false unless best_rect

    # Place the panel
    if should_rotate
      panel.width, panel.height = panel.height, panel.width
      panel.rotated = true
    end

    panel.x = best_rect[:x]
    panel.y = best_rect[:y]
    panel.placed = true

    # Add to sheet
    sheet[:panels] << panel.dup
    sheet[:used_area] += panel.width * panel.height

    # Split the free rectangle
    split_rectangle(sheet, best_rect, panel.width, panel.height)

    true
  end

  # Split free rectangle after placing panel (guillotine cut)
  def self.split_rectangle(sheet, rect, panel_width, panel_height)
    sheet[:free_rectangles].delete(rect)

    # Create right remainder
    if rect[:width] - panel_width > KERF
      sheet[:free_rectangles] << {
        x: rect[:x] + panel_width,
        y: rect[:y],
        width: rect[:width] - panel_width,
        height: rect[:height]
      }
    end

    # Create top remainder
    if rect[:height] - panel_height > KERF
      sheet[:free_rectangles] << {
        x: rect[:x],
        y: rect[:y] + panel_height,
        width: panel_width,
        height: rect[:height] - panel_height
      }
    end

    # Merge adjacent free rectangles (optimization)
    merge_free_rectangles(sheet)
  end

  # Merge adjacent free rectangles
  def self.merge_free_rectangles(sheet)
    # Simple merge - could be optimized further
    merged = true
    while merged
      merged = false
      sheet[:free_rectangles].each_with_index do |r1, i|
        sheet[:free_rectangles].each_with_index do |r2, j|
          next if i >= j

          # Check if rectangles can be merged horizontally
          if r1[:y] == r2[:y] && r1[:height] == r2[:height]
            if (r1[:x] + r1[:width] - r2[:x]).abs < 0.01
              r1[:width] += r2[:width]
              sheet[:free_rectangles].delete_at(j)
              merged = true
              break
            elsif (r2[:x] + r2[:width] - r1[:x]).abs < 0.01
              r1[:x] = r2[:x]
              r1[:width] += r2[:width]
              sheet[:free_rectangles].delete_at(j)
              merged = true
              break
            end
          end

          # Check if rectangles can be merged vertically
          if r1[:x] == r2[:x] && r1[:width] == r2[:width]
            if (r1[:y] + r1[:height] - r2[:y]).abs < 0.01
              r1[:height] += r2[:height]
              sheet[:free_rectangles].delete_at(j)
              merged = true
              break
            elsif (r2[:y] + r2[:height] - r1[:y]).abs < 0.01
              r1[:y] = r2[:y]
              r1[:height] += r2[:height]
              sheet[:free_rectangles].delete_at(j)
              merged = true
              break
            end
          end
        end
        break if merged
      end
    end
  end

  # Calculate material usage statistics
  def self.calculate_usage(sheets)
    total_sheet_area = sheets.length * SHEET_WIDTH * SHEET_LENGTH
    total_used = sheets.sum { |s| s[:used_area] }
    total_waste = total_sheet_area - total_used

    {
      num_sheets: sheets.length,
      total_sheet_area_sq_in: total_sheet_area.round(2),
      total_sheet_area_sq_ft: (total_sheet_area / 144.0).round(2),
      used_area_sq_in: total_used.round(2),
      used_area_sq_ft: (total_used / 144.0).round(2),
      waste_area_sq_in: total_waste.round(2),
      waste_area_sq_ft: (total_waste / 144.0).round(2),
      efficiency_percent: ((total_used / total_sheet_area) * 100).round(1)
    }
  end

  # Generate HTML cut list report
  def self.generate_html_report(cut_list, sheets, usage, design_result, config, client_name, output_path)
    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Cut List - #{client_name}</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 20px; }
          h1, h2, h3 { color: #333; }
          table { border-collapse: collapse; width: 100%; margin: 20px 0; }
          th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
          th { background-color: #4a4a4a; color: white; }
          tr:nth-child(even) { background-color: #f9f9f9; }
          .sheet-diagram { border: 2px solid #333; margin: 20px 0; position: relative; background: #f5f5dc; }
          .panel-box { position: absolute; border: 1px solid #666; background: rgba(194, 178, 128, 0.7); font-size: 10px; overflow: hidden; display: flex; align-items: center; justify-content: center; text-align: center; }
          .panel-box.rotated { background: rgba(178, 194, 128, 0.7); }
          .summary-box { background: #e8e8e8; padding: 15px; border-radius: 5px; margin: 10px 0; }
          .specs { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; }
          .spec-item { padding: 5px; }
          .spec-label { font-weight: bold; color: #666; }
          @media print { .no-print { display: none; } }
        </style>
      </head>
      <body>
        <h1>Subwoofer Enclosure Cut List</h1>

        <div class="summary-box">
          <h2>Project Summary</h2>
          <div class="specs">
            <div class="spec-item"><span class="spec-label">Client:</span> #{client_name}</div>
            <div class="spec-item"><span class="spec-label">Date:</span> #{Time.now.strftime("%Y-%m-%d")}</div>
            <div class="spec-item"><span class="spec-label">Enclosure Type:</span> #{design_result[:enclosure_type].to_s.capitalize}</div>
            <div class="spec-item"><span class="spec-label">Subwoofers:</span> #{config.num_subs}x #{config.sub_specs ? config.sub_specs[:model] : 'Custom'}</div>
            <div class="spec-item"><span class="spec-label">External Dimensions:</span> #{design_result[:external_dimensions][:width]}" W x #{design_result[:external_dimensions][:height]}" H x #{design_result[:external_dimensions][:depth]}" D</div>
            <div class="spec-item"><span class="spec-label">Net Volume:</span> #{design_result[:net_volume_cu_ft] || design_result.dig(:ported_chamber, :net_volume_cu_ft)} cu ft</div>
            #{design_result[:enclosure_type] == :ported ? "<div class=\"spec-item\"><span class=\"spec-label\">Tuning:</span> #{design_result[:port][:actual_tuning]} Hz</div>" : ''}
            <div class="spec-item"><span class="spec-label">Material:</span> 3/4" MDF</div>
          </div>
        </div>

        #{design_result[:enclosure_type] == :ported ? port_specs_html(design_result[:port]) : ''}

        <h2>Cut List</h2>
        <table>
          <tr>
            <th>#</th>
            <th>Panel Name</th>
            <th>Width</th>
            <th>Height</th>
            <th>Area (sq in)</th>
            <th>Cutouts</th>
            <th>Notes</th>
          </tr>
          #{cut_list.map.with_index { |p, i| cut_list_row(p, i + 1) }.join("\n")}
        </table>

        <div class="summary-box">
          <h3>Material Summary</h3>
          <div class="specs">
            <div class="spec-item"><span class="spec-label">Sheets Required:</span> #{usage[:num_sheets]} (4' x 8' x 3/4" MDF)</div>
            <div class="spec-item"><span class="spec-label">Material Used:</span> #{usage[:used_area_sq_ft]} sq ft</div>
            <div class="spec-item"><span class="spec-label">Waste:</span> #{usage[:waste_area_sq_ft]} sq ft</div>
            <div class="spec-item"><span class="spec-label">Efficiency:</span> #{usage[:efficiency_percent]}%</div>
          </div>
        </div>

        <h2>Nesting Layout</h2>
        <p>Sheet size: 48" x 96" (4' x 8'). Kerf: 1/8". Green tint indicates rotated panels.</p>

        #{sheets.map.with_index { |sheet, i| sheet_diagram_html(sheet, i + 1) }.join("\n")}

        <h2>Cutting Instructions</h2>
        <ol>
          <li>Mark out all panels on sheets as shown in diagrams above</li>
          <li>Cut largest panels first to minimize waste handling</li>
          <li>Account for 1/8" kerf in all measurements</li>
          <li>Label each panel after cutting</li>
          <li>Cut circular openings using router or jigsaw after panel is cut</li>
          <li>Sand all edges before assembly</li>
        </ol>

        <div class="no-print">
          <h2>Assembly Order</h2>
          <ol>
            <li>Glue and clamp bottom to sides</li>
            <li>Add back panel</li>
            #{design_result[:enclosure_type] == :ported ? '<li>Install port wall(s)</li>' : ''}
            #{config.extra_bracing ? '<li>Install window brace</li>' : ''}
            <li>Add top panel</li>
            <li>Install front baffle#{config.double_baffle ? ' (both layers)' : ''}</li>
            <li>Install terminal cup</li>
            <li>Allow 24 hours for glue to cure</li>
            <li>Seal all joints with silicone</li>
          </ol>
        </div>

        <footer style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #ccc; color: #666;">
          Generated by Subwoofer Enclosure Designer | #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}
        </footer>
      </body>
      </html>
    HTML

    File.write(output_path, html)
    output_path
  end

  # Generate port specs HTML section
  def self.port_specs_html(port)
    <<~HTML
      <div class="summary-box">
        <h3>Port Specifications</h3>
        <div class="specs">
          <div class="spec-item"><span class="spec-label">Port Type:</span> Slot Port</div>
          <div class="spec-item"><span class="spec-label">Port Width:</span> #{port[:port_width].round(2)}"</div>
          <div class="spec-item"><span class="spec-label">Port Height:</span> #{port[:port_height].round(2)}"</div>
          <div class="spec-item"><span class="spec-label">Port Length:</span> #{port[:port_length].round(2)}"</div>
          <div class="spec-item"><span class="spec-label">Port Area:</span> #{port[:port_area].round(2)} sq in</div>
          <div class="spec-item"><span class="spec-label">Path Type:</span> #{port[:path_type].to_s.gsub('_', ' ').capitalize}</div>
        </div>
      </div>
    HTML
  end

  # Generate cut list table row
  def self.cut_list_row(panel, num)
    cutout_text = if panel[:has_cutout] && panel[:cutout_info]
                    if panel[:cutout_info][:diameter]
                      "#{panel[:cutout_info][:diameter]}\" dia @ (#{panel[:cutout_info][:offset_x]&.round(2)}\", #{panel[:cutout_info][:offset_y]&.round(2)}\")"
                    else
                      "See notes"
                    end
                  else
                    "-"
                  end

    <<~HTML
      <tr>
        <td>#{num}</td>
        <td>#{panel[:name]}</td>
        <td>#{panel[:width]}"</td>
        <td>#{panel[:height]}"</td>
        <td>#{panel[:area_sq_in]}</td>
        <td>#{cutout_text}</td>
        <td>#{panel[:notes] || '-'}</td>
      </tr>
    HTML
  end

  # Generate sheet diagram HTML
  def self.sheet_diagram_html(sheet, num)
    scale = 6  # pixels per inch

    panels_html = sheet[:panels].map do |panel|
      rotated_class = panel.rotated ? ' rotated' : ''
      <<~HTML
        <div class="panel-box#{rotated_class}" style="left: #{panel.x * scale}px; top: #{panel.y * scale}px; width: #{(panel.width - KERF) * scale}px; height: #{(panel.height - KERF) * scale}px;">
          #{panel.name.gsub(/\s+\(\d+\/\d+\)/, '')}<br>#{(panel.width - KERF).round(1)}" x #{(panel.height - KERF).round(1)}"
        </div>
      HTML
    end.join("\n")

    efficiency = ((sheet[:used_area] / (sheet[:width] * sheet[:length])) * 100).round(1)

    <<~HTML
      <h3>Sheet #{num} (#{efficiency}% used)</h3>
      <div class="sheet-diagram" style="width: #{sheet[:width] * scale}px; height: #{sheet[:length] * scale}px;">
        #{panels_html}
      </div>
    HTML
  end

  # Generate text-only cut list
  def self.generate_text_report(cut_list, sheets, usage, design_result, config, client_name)
    report = []
    report << "=" * 60
    report << "SUBWOOFER ENCLOSURE CUT LIST"
    report << "=" * 60
    report << ""
    report << "Client: #{client_name}"
    report << "Date: #{Time.now.strftime("%Y-%m-%d")}"
    report << "Enclosure Type: #{design_result[:enclosure_type].to_s.capitalize}"
    report << "External: #{design_result[:external_dimensions][:width]}\" x #{design_result[:external_dimensions][:height]}\" x #{design_result[:external_dimensions][:depth]}\""
    report << "Net Volume: #{design_result[:net_volume_cu_ft] || design_result.dig(:ported_chamber, :net_volume_cu_ft)} cu ft"

    if design_result[:enclosure_type] == :ported
      report << "Tuning: #{design_result[:port][:actual_tuning]} Hz"
      report << ""
      report << "PORT SPECS:"
      report << "  Width: #{design_result[:port][:port_width].round(2)}\""
      report << "  Height: #{design_result[:port][:port_height].round(2)}\""
      report << "  Length: #{design_result[:port][:port_length].round(2)}\""
    end

    report << ""
    report << "-" * 60
    report << "CUT LIST (all dimensions in inches)"
    report << "-" * 60
    report << ""
    report << sprintf("%-30s %10s %10s %10s", "Panel", "Width", "Height", "Qty")
    report << "-" * 60

    cut_list.each do |panel|
      report << sprintf("%-30s %10.3f %10.3f %10s",
                        panel[:name][0..29],
                        panel[:width],
                        panel[:height],
                        panel[:notes] || "")
    end

    report << ""
    report << "-" * 60
    report << "MATERIAL SUMMARY"
    report << "-" * 60
    report << "Sheets needed: #{usage[:num_sheets]} (4' x 8' x 3/4\" MDF)"
    report << "Material used: #{usage[:used_area_sq_ft]} sq ft"
    report << "Waste: #{usage[:waste_area_sq_ft]} sq ft"
    report << "Efficiency: #{usage[:efficiency_percent]}%"
    report << ""
    report << "=" * 60

    report.join("\n")
  end
end
