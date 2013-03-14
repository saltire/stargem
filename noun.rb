class Noun
  attr_reader :id, :name, :desc, :shortname, :shortdesc, :notes, :words, :locs
  attr_writer :desc, :notes
  
  def initialize(nid, ndata)
    @id = nid
    @data = ndata
    
    def add_vars(vars, default)
      vars.each {|var| instance_variable_set "@#{var}", @data[var] || default}
    end
        
    add_vars %w(name desc shortname shortdesc), ''
    add_vars %w(notes words locs), []
  end
  
  def movable?
    !!@data['movable']
  end
  
  def wearable?
    !!@data['wearable']
  end
  
  def visible?
    !!@data['visible']
  end
end