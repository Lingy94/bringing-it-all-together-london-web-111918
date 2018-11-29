require_relative "../config/environment.rb"

class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed text
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.create(attr)
    new_dog = Dog.new(attr)
    new_dog.save
    new_dog
  end

  def self.find_by_id(x)
    sql = "SELECT * FROM dogs where id = ?"
    search_result = DB[:conn].execute(sql, x)
    found_dog = Dog.new(id: search_result[0][0],name: search_result[0][1], breed: search_result[0][2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs where name = ?"
    search_result = DB[:conn].execute(sql, name)
      found_dog = Dog.new(id: search_result[0][0],name: search_result[0][1], breed: search_result[0][2])
    end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = #{self.id}"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
  end

  def save
    if self.id
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = #{self.id}"
        DB[:conn].execute(sql, self.name, self.breed)
      else
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
      end
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
  end

  def find_by_id(id)
    sql = "select * from dogs where id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dogs.new(result[0], result[1], result[2])
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = Dog.new(id: id, name: name, breed: breed)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? and breed = ? LIMIT 1
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    p dog
    if dog.empty?
      dog = Dog.create(name: name, breed: breed)
    else
      dog = Dog.new(id: dog[0][0], name: dog[0][1], breed: [0][2])
    end
    p "end of method"
    dog
  end

end
