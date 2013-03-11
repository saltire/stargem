class Room
  attr_reader :id, :description, :notes, :exits
  
  def initialize(rid, rdata)
    @id = rid
    @data = rdata
    
    @description = @data['desc'] || ''
    @notes = @data['desc'] || []
    @exits = @data['exits'] || []
  end
  
  def is_start?
    @data['start'] == true
  end
  
  def visited?
    @visited == true
  end

  def visit
    @visited = true
  end
  
end