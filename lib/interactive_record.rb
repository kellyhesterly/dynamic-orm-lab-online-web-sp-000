require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end

  def attr_accessor
    self.column_names.each do |col_name|
      attr_accessor col_name.to_sym
    end
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|name| name == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    attr_accessor.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
  end
end
