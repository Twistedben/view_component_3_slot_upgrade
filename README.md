# View Component Gem 3.0 Slot Upgrader Script

Per [ViewComponent 3.0 Changelog](https://viewcomponent.org/CHANGELOG.html#v300): BREAKING: Remove deprecated slots setter methods. Use with_SLOT_NAME instead.

A Ruby script for the View Component Gem by Github that updates existing html.erb files that have slot calls inside of them to prepend the prefix "_with" due to the breaking change of slot calling.

Clone the script and move `update_slots.rb` into your app's directory.

Running the script can be done by being CDd into its path and calling it with `ruby update_slots.rb`.

After running the script, `ruby  update_slots.rb`, a text file will be created listing everything that has been changed.

By default, it will look inside Ruby on Rails app locations such as `app/views` and View Component directory `app/components`. If you'd like it to run elsewhere or somewhere more specific, when calling the script, add the folder's path after the script name: `ruby update_slots.rb ./app/views/devise ./app/views/notes`.

## Types of Slots  

The type of slot calls this will automatically update:

1. Slot name with parameters: `dropdown.button(title: "View Dropdown") do` => `dropdown.with_button(title: "View Dropdown") do`

2. Slot names without parameters: `dropdown.button do` => `dropdown.with_button do`

3. Slot names with block: `dropdown.button {"Test"}` => `dropdown.with_button {"Test"}`

4. Old slot names using with: `component.with(:header)` => `component.with_header`
