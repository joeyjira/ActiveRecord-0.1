require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns

    all_col = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        0
    SQL

    @columns = all_col.first.map!(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |col_name|
      define_method(col_name) do
        self.attributes[col_name]
      end

      define_method("#{col_name}=") do |item|
        self.attributes[col_name] =  item
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @name = table_name
  end

  def self.table_name
    # ...
    @name ||= "#{self}".tableize
  end

  def self.all
    # ...
    table = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    parse_all(table)
  end

  def self.parse_all(results)
    # ...
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    # ...
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    parse_all(result).first
  end

  def initialize(params = {})
    # ...
    params.each do |key, value|
      key = key.to_sym

      if self.class.columns.include?(key)
        self.send("#{key}=", value)
      else
        raise "unknown attribute 'favorite_band'"
      end
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    self.class.columns.map { |method| self.send(method) }
  end

  def insert
    # ...
    column = self.class.columns.drop(1)
    col_names = column.map(&:to_s).join(", ")
    question_marks = (["?"] * column.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
