class Noun
  attr_reader :id, :description, :notes, :locs, :words
  
  def initialize(nid, ndata)
    @id = nid
    @data = ndata
    
    @description = @data['desc'] || ''
    @notes = @data['notes'] || []
    @locs = @data['locs'] || []
    @words = @data['words'] || []
  end
  
  def movable?
    @data['movable'] == true
  end
  
  def wearable?
    @data['wearable'] == true
  end
end