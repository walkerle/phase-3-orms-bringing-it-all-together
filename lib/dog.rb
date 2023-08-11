class Dog

  attr_accessor :name, :breed, :id

  def initialize name:, breed:, id: nil
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save # Ruby => SQL
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
  
      DB[:conn].execute(sql, self.name, self.breed)
  
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

    self
  end

  def self.create name:, breed: # Ruby => Create Ruby instance => SQL
    dog = self.new name: name, breed: breed # Create Ruby instance
    dog.save # Ruby => SQL
  end

  def self.new_from_db row # SQL => Ruby
    # Dog class is an array of Dog class instances
    # row is an instance of the Dog class
    self.new id: row[0], name: row[1], breed: row[2]
  end

  def self.all # SQL => Ruby
    sql = 'SELECT * FROM dogs'

    DB[:conn].execute(sql).map do |row|
      self.new_from_db row
    end
    # returns an array of Dog class instances
  end

  def self.find_by_name name # SQL => Ruby
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db row
    end.first
    # .execute.map returns an array of the Dog class instance
    # .first returns only the Dog class instance which contains the row data
  end

  def self.find id # SQL => Ruby
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db row
    end.first
  end

  def self.find_or_create_by name:, breed: # SQL => Ruby
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
    SQL

    # if DB[:conn].execute(sql, name, breed).first
    #   self.find_by_name name
    # else
    #   self.create name: name, breed: breed
    # end

    # Alternate
    row = DB[:conn].execute(sql, name, breed).first

    if row
      self.new_from_db row
    else
      self.create name: name, breed: breed
    end
  end

  def update # Ruby => SQL
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL

    DB[:conn].execute sql, self.name, self.breed, self.id
  end

end
