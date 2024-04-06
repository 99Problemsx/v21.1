class Player
  attr_accessor :charmsActive
  attr_accessor :eleCharmsActive
  attr_accessor :charmlist
  attr_accessor :elementCharmlist
  attr_accessor :last_wish_time
  attr_accessor :link_charm_data
  attr_accessor :ball_for_apricorn
  attr_accessor :next_run
  attr_accessor :activeNature
  attr_accessor :natureList
  attr_accessor :maxCharms
  attr_accessor :active_count
	def initializeCharms
	@last_wish_time ||= 0
	@link_charm_data ||= [0, 0, [], nil] #Species, Chain Count, Fled Species/Chain, Placeholder for using an automatic evolution plugin.
	@ball_for_apricorn ||= 0
	@next_run ||= 0
    @charmlist ||= []
	@elementCharmlist ||= []
	@active_count ||= 0
	@activeNature ||= []
	@natureList ||= []
	@maxCharms ||= CharmCaseSettings::MAX_ACTIVE_CHARMS
	@charmsActive = {
		:APRICORNCHARM	  => false,
		:BALANCECHARM     => false,
		:BERRYCHARM       => false,
		:CATCHINGCHARM    => false,
		:CLOVERCHARM      => false,
		:COINCHARM        => false,
		:COLORCHARM		  => false,
		:CONTESTCHARM	  => false,
		:CORRUPTCHARM	  => false,
		:CRAFTINGCHARM	  => false,
		:DISABLECHARM     => false,
		:EASYCHARM		  => false,
		:EFFORTCHARM	  => false,
		:EXPALLCHARM	  => false,
		:EXPCHARM         => false,
	    :FRUGALCHARM      => false,
		:GENECHARM		  => false,
		:GOLDCHARM        => false,
		:HARDCHARM		  => false,
		:HEALINGCHARM     => false,
		:HEARTCHARM       => false,
		:IVCHARM          => false,
		:KEYCHARM         => false,
		:LINKCHARM		  => false,
		:LURECHARM        => false,
		:MERCYCHARM       => false,
		:MININGCHARM      => false,
		:NATURECHARM	  => false,
		:OVALCHARM        => false,
		:POINTSCHARM	  => false,
		:PROMOCHARM       => false,
		:PURIFYCHARM	  => false,
		:RESISTORCHARM	  => false,
		:ROAMINGCHARM	  => false,
		:SAFARICHARM	  => false,
		:SHINYCHARM       => false,
		:SLOTSCHARM       => false,
		:SMARTCHARM		  => false,
		:SPIRITCHARM      => false,
		:STABCHARM		  => false,
		:STEPCHARM		  => false,
		:TRADINGCHARM	  => false,
		:TRIPTRIADCHARM   => false,
		:TWINCHARM        => false,
		:VIRALCHARM       => false,
		:WISHINGCHARM     => false,

	:BUGCHARM         => false,
    :DARKCHARM        => false,
	:DRAGONCHARM      => false,
	:ELECTRICCHARM    => false,
	:FAIRYCHARM       => false,
    :FIGHTINGCHARM    => false,
	:FIRECHARM        => false,
	:FLYINGCHARM      => false,
    :GHOSTCHARM       => false,
    :GRASSCHARM       => false,
    :GROUNDCHARM      => false,
	:ICECHARM         => false,
	:NORMALCHARM      => false,
    :PSYCHICCHARM     => false,
    :POISONCHARM      => false,
    :ROCKCHARM        => false,
    :STEELCHARM       => false,
	:WATERCHARM       => false,
	:ELEMENTCHARM     => false
		}
	end
end

module GameData
  class Item
    def is_charm?
      charm_ids = [
        :APRICORNCHARM, :BALANCECHARM, :BERRYCHARM,  :CATCHINGCHARM, :CLOVERCHARM, :COINCHARM, :COLORCHARM,  :CONTESTCHARM, :CORRUPTCHARM,   :CRAFTINGCHARM, :DISABLECHARM,
		:EASYCHARM,		:EFFORTCHARM,  :EXPALLCHARM, :EXPCHARM,    	 :FRUGALCHARM, :GENECHARM, :GOLDCHARM,   :HARDCHARM,    :HEALINGCHARM,   :HEARTCHARM,    :IVCHARM,
		:KEYCHARM,      :LINKCHARM,    :LURECHARM,   :MERCYCHARM, 	 :MININGCHARM, :OVALCHARM, :POINTSCHARM, :PROMOCHARM,   :PURIFYCHARM,    :RESISTORCHARM, :ROAMINGCHARM,
		:SAFARICHARM,   :SHINYCHARM,   :SLOTSCHARM,  :SMARTCHARM, 	 :SPIRITCHARM, :STABCHARM, :STEPCHARM,   :TRADINGCHARM, :TRIPTRIADCHARM, :TWINCHARM,     :VIRALCHARM,   
		:WISHINGCHARM, :ELEMENTCHARM, :NATURECHARM
      ]
      charm = charm_ids.include?(self.id.to_sym)
      return charm
    end
	def is_echarm?
	echarm_ids = [
	    :BUGCHARM, 		:DARKCHARM,  :DRAGONCHARM, :ELECTRICCHARM, :FAIRYCHARM,
        :FIGHTINGCHARM, :FIRECHARM,  :FLYINGCHARM, :GHOSTCHARM,    :GRASSCHARM,
        :GROUNDCHARM,	:ICECHARM, 	 :NORMALCHARM, :PSYCHICCHARM,  :POISONCHARM,
        :ROCKCHARM, 	:STEELCHARM, :WATERCHARM
	]
	echarm = echarm_ids.include?(self.id.to_sym)
	return echarm
	end
  end
end