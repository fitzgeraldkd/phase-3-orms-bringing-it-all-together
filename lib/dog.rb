class Dog
  
  attr_accessor :id, :name, :breed

  def self.all
    sql = "SELECT * FROM dogs"
    DB[:conn].execute(sql).map do |row|
      new_from_db(row)
    end
  end

  def self.create_table
    sql = "CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.create(attributes)
    self.new(attributes).save
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name=? LIMIT 1"
    row = DB[:conn].execute(sql, name)[0]
    new_from_db(row)
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find(id)
    sql = "SELECT * FROM dogs WHERE id=? LIMIT 1"
    row = DB[:conn].execute(sql, id)[0]
    new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name=? AND breed=? LIMIT 1"
    results = DB[:conn].execute(sql, name, breed)
    if results.length == 0
      create(name: name, breed: breed)
    else
      new_from_db(results[0])
    end
    
  end

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def save
    if !@id
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, @name, @breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    else
      update
      self
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @breed, @id)
  end
end
