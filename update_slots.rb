require 'fileutils'

total_files = 0
total_slot_name_changes = 0
total_skipped = 0
total_view_components_found = 0

# Where to look for files
dirs = ARGV.empty? ? ['./app/views', './app/components'] : ARGV

dirs.each do |dir|
  Dir.glob("#{dir}/**/*.html.erb").each do |file|
    data = File.read(file)
    changes_made = false

    # Extract the matching view component blocks into variable
    component_vars = data.scan(/render\(.*?\.new.*? do \|(\w+)\|/m).flatten.uniq

    # Update number of View Components themselves that have been found
    total_view_components_found += component_vars.count

    # Process each view component block
    component_vars.each do |component_var|
      # Extract the slots inside the component block 
      slots = data.scan(/<%\s*#{component_var}\.(\w+)/)

      total_slot_name_changes += slots.count # Count the number of slots inside that block

      # Process each slot
      slots.each do |slot|
        slot_name = slot.first  # extract the actual slot name from the array
        if slot_name == 'each' || slot_name.start_with?('with_')
          total_skipped += 1
          total_slot_name_changes -= 1 
        else
          # Slots match these patterns
          slot_regex = /<%\s*#{component_var}\.#{slot_name}(\s*\(.*?\)\s*do|\s*do|\s*do\s*)/
          
          # For each occurrence of the slot, replace it with "with_" prefix
          while data =~ slot_regex
            data.gsub!(slot_regex, "<% #{component_var}.with_#{slot_name}#{$1}")
            changes_made = true
          end
        end
      end
    end

    if changes_made
      # Track a file has been edited
      total_files += 1

      # Write the modified data back to the file
      File.write(file, data)
    end
  end
end

puts "Total files edited: #{total_files}"
puts "Total number of view components with blocks found: #{total_view_components_found}"
puts "Total slot occurrences changed: #{total_slot_name_changes}"
puts "Total occurrences skipped: #{total_skipped}"