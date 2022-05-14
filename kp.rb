class KP
  PARTICIPATION_TYPE = 'participation'
  KILL_OR_ASSIST_TYPE = 'kill_or_assist'
  attr_reader :index, :type

  def initialize(index, type)
    @index = index
    @type = type
  end
end