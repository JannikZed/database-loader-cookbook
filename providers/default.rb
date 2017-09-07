require 'csv'

def whyrun_supported?
  true
end

use_inline_resources

action :sync do
  # Defaults and Attribute Transformaton
  new_resource.table_name = new_resource.csv_filename.sub(/.csv$/, '') if new_resource.table_name.nil?
  table_selection = if new_resource.table_header
                      new_resource.table_header.join(',')
                    else
                      '*'
                    end
  Chef::Log.debug "Var table_selection: #{table_selection.inspect}"

  Chef::Log.info "sync Table: #{new_resource.table_name}"
  require 'mysql2'
  sql_client = Mysql2::Client.new(host: new_resource.host,
                                  username: new_resource.username,
                                  password: new_resource.password,
                                  database: new_resource.database,
                                  as: :array)
  sql_response = sql_client.query("SELECT #{table_selection} FROM #{new_resource.table_name}")
  sql_array = norm(sql_response)

  Chef::Log.info "used CSV File: #{new_resource.csv_filepath} #{new_resource.csv_filename}"
  csv_array = norm(CSV.read(new_resource.csv_filepath + new_resource.csv_filename))

  result_config = csv_array - sql_array
  result_database = sql_array - csv_array

  if result_config.any? | result_database.any?
    converge_by("delete:#{result_database.inspect} and \n insert:#{result_config.inspect}") do
      Chef::Log.info "Delete from db: #{result_database.inspect}"
      Chef::Log.info "Insert into db: #{result_config.inspect}"
      Chef::Log.info "Selected SQL Header Fieldnames: #{sql_response.fields}"
      update_config('delete', result_database, sql_response.fields, sql_client, new_resource.table_name) if result_database.any?
      update_config('insert', result_config, sql_response.fields, sql_client, new_resource.table_name) if result_config.any?
    end
 end
end

def norm(inp)
  arr = []
  inp.each do |row|
    arr_row = []
    row.each do |field|
      arr_row.push(field.to_s)
    end
    arr.push(arr_row)
  end
  arr
end

def update_config(action, data_array, field_array, sql_client, table_name)
  return_value = false
  Chef::Log.info "table_name: #{table_name}"
  data_array.each do |value_array|
    value_string = value_array.join('","')
    field_string = field_array.join(',')
    if value_array.length == field_array.length
      command = "INSERT INTO #{table_name} (#{field_string}) VALUES (\"#{value_string}\")" if action == 'insert'
      command = "DELETE FROM #{table_name} WHERE (#{field_string})=(\"#{value_string}\")" if action == 'delete'
      command = '' if action == 'update'
      return_value = sql_client.query(command)
    else
      Chef::Log.error 'CSV and SQL Table have not the same amount of fields'
      Chef::Log.error field_string.inspect
    end
  end
  return_value
end
