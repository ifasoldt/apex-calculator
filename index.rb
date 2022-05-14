require_relative 'constants'
require_relative 'kp'


get '/' do
  @kills_and_assists = 0
  erb :index
end

post '/' do
  @rank = params[:rank]
  @subrank = params[:subrank].to_i
  @placement = params[:placement].to_i
  @kills_and_assists = params[:kills_and_assists].to_i
  @participation = params[:participation].to_i
  calculator = ApexCalculator.new(
    params[:rank],
    params[:subrank],
    params[:placement],
    params[:kills_and_assists],
    params[:participation]
  )
  @rp = calculator.calculate
  erb :index
end

class ApexCalculator

  attr_reader :rank, :subrank, :placement, :kills_and_assists, :participation

  def initialize(rank, subrank, placement, kills_and_assists, participation)
    @rank = rank
    @subrank = subrank.to_i
    @placement = placement.to_i
    @kills_and_assists = kills_and_assists.to_i
    @participation = participation.to_i
  end

  def calculate
    (placement_rp + kill_rp - entry_cost).to_i
  end

  private

  def placement_rp
    PLACEMENT_RP[placement]
  end

  def kill_rp
    kill_rp_by_type_between(KP::KILL_OR_ASSIST_TYPE, 0, 2).to_i + 
    kill_rp_by_type_between(KP::KILL_OR_ASSIST_TYPE, 3, 5).to_i +
    kill_rp_by_type_between(KP::KILL_OR_ASSIST_TYPE, 6, 61).to_i +
    kill_rp_by_type_between(KP::PARTICIPATION_TYPE, 0, 2).to_i +
    kill_rp_by_type_between(KP::PARTICIPATION_TYPE, 3, 5).to_i +
    kill_rp_by_type_between(KP::PARTICIPATION_TYPE, 6, 61).to_i
  end

  def entry_cost
    (rank == 'masters' || rank == 'rookie') ? ENTRY_COST[rank] : ENTRY_COST[rank][subrank]
  end

  def base_kill_rp
    @base_kill_rp ||= BASE_KILL_RP[placement]
  end

  def kill_rp_by_type_between(type, start, finish)
    base_kill_rp * num_of_kp_by_type_between(type, start, finish) * DROPOFF_MULTIPLIER[start] * TYPE_PENALTY_MULTIPLIER[type]
  end

  def kill_points
    @kill_points ||= initialize_kill_points(kills_and_assists, participation)
  end

  def initialize_kill_points(kills_and_assists, participation)
    arr = []
    kills_and_assists.times { |n| arr.push(KP.new(n, KP::KILL_OR_ASSIST_TYPE)) }
    participation.times { |n| arr.push(KP.new(n + kills_and_assists, KP::PARTICIPATION_TYPE)) }
    arr
  end

  def num_of_kp_by_type_between(type, start, finish)
    kill_points.select { |kp| kp.type == type && kp.index.between?(start, finish) }.count
  end
end