module Event
  class ModificationsController < ApplicationController
    layout "admin_layout"

    def show
      @modification = Modification.find(params[:id])
      @registration = apply_modification
      @user = @registration.user.full_name
    end

    def commit
      @modification = Modification.find(params[:id])
      @regstration = apply_modification
      @user = @registration.user.full_name
    end

    private

    def apply_modification
      reg = @modification.registration
      reg.number_of_adults += @modification.delta_adults
      reg.number_of_youths += @modification.delta_youths
      reg.number_of_children += @modification.delta_children

      reg.lake_cruise_number += @modification.delta_lake_cruise

      reg.registration_fee += @modification.new_attendee_fee
      reg.lake_cruise_fee += @modification.new_lake_cruise_fee
      reg.total += @modification.modification_total
      reg
    end

    def modification_params
      params.require(:id)
        .permit(
          :cancellation,
          :delta_adults,
          :delta_children,
          :delta_lake_cruise,
          :delta_youths,
          :modification_total,
          :new_attendee_fee,
          :new_lake_cruise_fee,
          :new_total,
          :starting_adults,
          :starting_children,
          :starting_lake_cruise,
          :starting_youths,
          :status
        )
    end
  end
end
