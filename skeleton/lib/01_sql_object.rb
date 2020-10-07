require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @array if defined? @array
    array = DBConnection.execute2(<<-SQL)
    SELECT 
    * 
    FROM #{self.table_name}
    SQL
    .first.map! { |ele| ele.to_sym }
    @array = array
     
  end

  def self.finalize!
    self.columns.each do |column| 
      define_method(column) do 
        self.attributes[column] 
      end 
      define_method("#{column}=")  do |val|
        self.attributes[column] = val
      end 
    end 
    
  end

  def self.table_name=(table_name)
    return "#{table_name}s".downcase
  end

  def self.table_name
    return "#{self}s".downcase
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
    SELECT 
    #{table_name}.*
    FROM 
    #{table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    
    results.map do |hash| 
      self.new(hash)
    end 
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id)
    SELECT 
    #{table_name}.*
    FROM 
    #{table_name}
    WHERE #{table_name}.id = ?
    SQL
    parse_all(data).first
    
  end

  def initialize(params = {})
    params.each do |key,value| 
      name = key.to_sym 
      if self.class.columns.include?(name)
        self.send("#{name}=", value)
      else 
        raise "unknown attribute '#{name}'"
      end 
    end 

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.attributes.values 
  end

  def insert
    columns = self.class.columns.shift
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
