class Room
  attr_reader :id
  
  def initialize(rid, rdata)
    @id = rid
    @data = rdata
  end
  
  def is_start?
    true if @data['start']
  end
  
  def visit
    @visited = true
  end
end