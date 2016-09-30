require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    if @column_names.nil?

      all_rows = DBConnection.execute2(<<-SQL)
        SELECT *
        FROM #{table_name}
      SQL


      @column_names = all_rows[0]
      @column_names.map! { |name| name.to_sym }
    end

    @column_names
  end

  def self.finalize!
    columns.each do |col_title|

      define_method("#{col_title}") do
        attributes[col_title]
      end

      define_method("#{col_title}=") do |val|
        attributes[col_title] = val
      end

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{self}".tableize
  end

  def self.all
    # ...

  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    params.each_pair do |attr_name, value|
    attr_name_sym = attr_name.to_sym

    unless self.class.columns.include?(attr_name_sym)
      raise "unknown attribute '#{attr_name}'"
    end

      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
