class Room
  attr_reader :id, :name, :desc, :notes, :exits
  attr_writer :description, :notes
  
  def initialize(rid, rdata)
    @id = rid
    @data = rdata
    
    def add_vars(vars, default)
      vars.each {|var| instance_variable_set "@#{var}", @data[var] || default}
    end
        
    add_vars %w(name desc), ''
    add_vars %w(notes exits), []
  end
  
  def is_start?
    !!@data['start']
  end
  
  def visited?
    !!@visited
  end

  def visit
    @visited = true
  end
  
end