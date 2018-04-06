require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.


# check this out for guidance
# https://github.com/appacademy/curriculum/blob/master/sql/projects/active_record_lite/instructions/active-record-lite-i.md
# class method ::columns

class SQLObject
  def self.columns
    # DBConnection::execute2 method returns an array
    # This gives you all the column names and VALUES
    # but also the first element is a list of the column
    # names so get the first one
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      SQL
      # first element is a list of the names of columns
      # so grab the 1st one and map to symbols
      @columns = cols.first.map { |name| name.to_sym }
      @columns
    end

  def self.finalize!
    # ::columns, using define_method (twice) to create a
    # getter and setter method for each column,
    # just like my_attr_accessor. But this time, instead of
    # dynamically creating an instance variable, store everything
    # in the #attributes hash.
    self.columns.each do | column_name |
      # USE SYNTAX FROM 00_ATTR_
      define_method(column_name) do
        self.attributes[column_name]
        end
      define_method("#{column_name}=") do |value|
        self.attributes[column_name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    # debugger
    @table_name || self.name.to_s.underscore  + "s"
  end

    # SELECT
    #   cats.*
    # FROM
    #   cats
  def self.all
    # returns a hash
    table = DBConnection.execute(<<-SQL)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    SQL

    # print table
    # To turn each of the Hashes into Humans,
    # write a SQLObject::parse_all method.
    # Iterate through the results, using
    # new to create a new instance for each

    # Now we can call ::parse_all from inside ::all and
    # make all the specs pass!
    parse_all(table)
  end

  def self.parse_all(results)
    # results is an array of hashes
    # [{"id"=>1, "name"=>"Breakfast", "owner_id"=>1},
    # {"id"=>2, "name"=>"Earl", "owner_id"=>2} ...

    # new what? SQLObject.new?
    # That's not right, we want Human.all to return Human objects,
    # and Cat.all to return Cat objects.
    # Hint: inside the ::parse_all class method, what is self?
    array_of_objects = [ ]
    results.each do | row |
      # new --> def initialize(params = {})
      # [{"id"=>1, "name"=>"Breakfast", "owner_id"=>1}, {"id"=>2, "name"=>"Earl", "owner_id"=>2} ...
      # debugger
      array_of_objects << self.new(row)
    end
    array_of_objects
  end

  def self.find(id)
    # class SQLObject
    # def self.find(id)
    # self.all.find { |obj| obj.id == id }
    # inefficient

    # Instead, write a new SQL query that will
    # fetch at most one record.
    # self.table_name.id
    result = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{table_name}.id = ?
    SQL
    result.empty? ? nil : self.new(result.first)
  end

  # cat = Cat.new(name: "Gizmo", owner_id: 123)
  # cat.name #=> "Gizmo"
  # cat.owner_id #=> 123
  def initialize(params = {})
    # Your #initialize method should iterate through each of the
    # attr_name, value pairs.
    params.each do | attr_name, value |
      # For each attr_name,
      # it should first convert the name to a symbol
      attr_name = attr_name.to_sym
      # check whether the attr_name is among the columns
      # Hint: we need to call ::columns on a class object
      # not the instance.
      # For example, we can call Dog::columns but not dog.columns.
      if self.class.columns.include?(attr_name)
        # calls appropriate setter method for each item in params
        # Use #send; avoid using @attributes or
        # attributes inside #initialize.
        self.send("#{attr_name}=", value)
      else
        # If it is not, raise an error
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  # google
  # def __target_object__
  #  @__target_object__ ||= @callable.call
  # end
  def attributes
    @attributes ||= { }
  end

  def attribute_values
    @attributes.values
  end

  def insert

    # col_names: I took the array of ::columns of the class
    # = [:id, :name, :owner_id]
    cols  = self.class.columns
    # and joined it with commas.
    column_names = cols.map{ |col| col.to_s}.join(", ")

    # question_marks: I built an array of question marks
    # (["?"] * n) and joined it with commas.
    # What determines the number of question marks?
    n = cols.length
    question_marks = (["?"] * n).join(", ")

    DBConnection.execute(<<-SQL, attribute_values)
    INSERT INTO
      #{table_name} (#{column_names})
    VALUES
      (#{question_marks}
    SQLS
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
