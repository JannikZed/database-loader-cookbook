actions :sync # , :syncall, :insert, :delete
default_action :sync

attribute :host,         kind_of: String, default: nil, required: true
attribute :username,     kind_of: String, default: nil, required: true
attribute :password,     kind_of: String, default: nil
attribute :database,     kind_of: String, default: nil, required: true

attribute :csv_filename, kind_of: String, default: nil
attribute :csv_filepath, kind_of: String, default: nil
attribute :table_name,   kind_of: String, default: nil
attribute :table_header, kind_of: Array, default: nil
