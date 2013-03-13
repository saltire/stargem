class Noun
  attr_reader :id, :description, :notes, :words
  
  def initialize(nid, ndata)
    @id = nid
    @data = ndata
    
    @description = @data['desc'] || ''
    @notes = @data['notes'] || []
    @words = @data['words'] || []
  end
  
  def initial_locs
    @data['locs'] || []
  end
  
  def movable?
    @data['movable'] == true
  end
  
  def wearable?
    @data['wearable'] == true
  end
end