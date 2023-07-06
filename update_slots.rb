require 'fileutils'

# Script's stats
total_files = 0
total_slot_name_changes = 0
total_skipped = 0
total_view_components_found = 0

# Where to look for files
dirs = ARGV.empty? ? ['./app/views', './app/components'] : ARGV

# Open a new file for writing.
output_file = File.open("update_slots_output.txt", "w")

dirs.each do |dir|
  Dir.glob("#{dir}/**/*.html.erb").each do |file|
    data = File.read(file)
    changes_made = false

    # Extract the matching view component blocks into variable
    component_names = data.scan(/render\(.*?\.new.*?\)\s*do \|(\w+)\|/m).flatten.uniq

    # Update number of View Components themselves that have been found
    total_view_components_found += component_names.count

    # Process each view component block
    component_names.each do |component_name|
      # Extract the slots inside the component block, finding slot calls like: "component.with(:slot_name)" and newer ones like "component.slot_name"
      slots = data.scan(/\s*#{component_name}\.(with\(\s*:\s*)?(\w+)/)
      
      # If regex accidentally captures a form_with or form_for, skip it
      if component_name == "form" || component_name == "f"
        output_file.puts "Ignored #{component_name} in #{file}"
        next
      end

      total_slot_name_changes += slots.count # Count the number of slots inside that block

      # Process each slot
      slots.each do |slot|
        # extract the "with" and actual slot name from the array
        with, slot_name1, slot_name2 = slot
        slot_name = slot_name1 || slot_name2

        if slot_name == 'each' || slot_name&.start_with?('with_')
          total_skipped += 1
          total_slot_name_changes -= 1 
        else
          use_parentheses = "" # Account for: "component.slot_name(" 
          # If the slot name was found in a `with` call, use a different replacement regular expression.
          if with
            slot_regex = /\s*#{component_name}\.with\(:#{slot_name}\)(.*)/
          elsif data.match(/\s*#{component_name}\.#{slot_name}\s*\{/)
            slot_regex = /\s*#{component_name}\.#{slot_name}(\s*\{.*?\}\s*%>)(.*)/
          elsif data.match(/\s*#{component_name}\.#{slot_name}\s*\($/)
            slot_regex = /\s*#{component_name}\.#{slot_name}\s*\((.*)/
            use_parentheses = "("
          else
            slot_regex = /\s*#{component_name}\.#{slot_name}(\s*(\(\s*.*?\))?\s*(do)?|\s*do|\s*do\s*)/ms
          end
          lines = data.split("\n")
          
          # For each occurrence of the slot, replace it with "with_" prefix
          lines.each_with_index do |line, index|
            if line.match(slot_regex)
              output_file.puts "Updating #{file} at line #{index + 1} with #{component_name}.with_#{slot_name}"
              line.gsub!(slot_regex) { |match| " #{component_name}.with_#{slot_name}#{use_parentheses}#{$1}" }
              changes_made = true
            end
          end
          
          if changes_made
            # Combine the lines back into a single string and write back to the file
            data = lines.join("\n")
            File.write(file, data)
          end
        end
      end
    end

    total_files += 1 if changes_made # Track a file has been edited
  end
end

files_edited_str = "Total files edited: #{total_files}"
vc_blocks_found_str = "Total number of view components with blocks found: #{total_view_components_found}"
slot_changes_str = "Total slot occurrences changed: #{total_slot_name_changes}"
occurrences_skipped_str = "Total slot occurrences skipped: #{total_skipped}"

outputs_string = [files_edited_str, vc_blocks_found_str, slot_changes_str, occurrences_skipped_str]

outputs_string.each do |string|
  output_file.puts string 
end

puts "More details for specific changes can be found inside #{output_file.path}"

output_file.close