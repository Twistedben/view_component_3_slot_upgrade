# View Component Gem 3.0 Slot Upgrader Script

Per [ViewComponent 3.0 Changelog](https://viewcomponent.org/CHANGELOG.html#v300): BREAKING: Remove deprecated slots setter methods. Use with_SLOT_NAME instead.

A Ruby script for the View Component Gem by Github that updates existing html.erb files that have slot calls inside of them to prepend the prefix "_with" due to the breaking change of slot calling.

Clone the repo and move `update_slots.rb` into your app's directory.

Running the script can be done by being CDd into its path and calling it with `ruby update_slots.rb`.

After running the script, `ruby  update_slots.rb`, a text file will be created listing everything that has been changed.

By default, it will look inside Ruby on Rails app locations such as `app/views` and View Component directory `app/components`. If you'd like it to run elsewhere or somewhere more specific, when calling the script, add the folder's path after the script name: `ruby update_slots.rb ./app/views/devise ./app/views/notes`.

Will skip any component name before slot calls that match `f` or `form`, this way `form_with` and other form blocks are skipped. So ahead of time, update any components that you call with `|form|` inside to something like `|component|` or `|form_component|`.
## Types of Slots  

The type of slot calls this will automatically update:

1. Slot name with parameters: `dropdown.button(title: "View Dropdown") do` => `dropdown.with_button(title: "View Dropdown") do`

2. Slot names without parameters: `dropdown.button do` => `dropdown.with_button do`

3. Slot names without block but with parameters: `dropdown.button(classes: "test")` => `dropdown.with_button(classes: "test")`

4. Slot names with block, with out without parameters: `dropdown.button {"Test"}` => `dropdown.with_button {"Test"}`

5. Old slot names using with: `component.with(:header)` => `component.with_header`

6. Multiline slot names like: 

```ruby
  component.button(
    data: {
      "test"
    }
  )
```

```ruby
  component.with_button(
    data: {
      "test"
    }
  )
```

## Update Slots Output

Running the script will create a text file (`update_slots_output.txt`) in the same directory as the `update_slots.rb` file. This file is a log that tracks  all the slots that were updated and will look like this when finished running:

```txt
  Ignored form in ./app/components/chat_component.html.erb
  Updating ./app/components/forms/form.html.erb at line 11 with form_component.with_name
  Updating ./app/components/forms/form.html.erb at line 17 with form_component.with_assigned_to
  Updating ./app/components/forms/form.html.erb at line 24 with form_component.with_date_type
  Updating ./app/components/forms/form.html.erb at line 35 with form_component.with_date
  Updating ./app/components/forms/form.html.erb at line 45 with form_component.with_date
  Total files edited: 107
  Total number of view components with blocks found: 186
  Total slot occurrences changed: 357
  Total slot occurrences skipped: 0
```
