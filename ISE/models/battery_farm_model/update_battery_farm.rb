module BatteryFarmModel

  # Collect latest data from each launcher in the batteries
  def self.update_battery_farm

    BATTERY_FARM.each_key do |k|
      BATTERY_FARM[k].rounds_available = 0
    end

    FARM.each_pair do |k,v|
      BATTERY_FARM[v.battery_label].rounds_available += v.rounds_available
    end

  end

end ## end of module BatteryFarmModel
