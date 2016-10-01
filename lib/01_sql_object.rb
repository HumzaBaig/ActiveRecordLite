require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
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
    results =
      DBConnection.execute(<<-SQL)
      SELECT #{self.table_name}.*
      FROM #{self.table_name}
      SQL

    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map do |hash|
      self.new(hash)
    end
  end

  def self.find(id)
    arr = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{self.table_name}
      WHERE id = ?
    SQL

    self.new(arr.first) unless arr.first.nil?
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
    self.class.columns.map do |col|
      self.send("#{col}")
    end
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = (["?"] * self.class.columns.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_string = self.class.columns[1..-1].join("= ?, ").concat("= ?")
    id = self.id

    DBConnection.execute(<<-SQL, *attribute_values.drop(1), id)
      UPDATE #{self.class.table_name}
      SET #{set_string}
      WHERE id = ?
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end
