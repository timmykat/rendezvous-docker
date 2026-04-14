module Event
  class ModificationsController < ApplicationController
    layout "admin_layout"

    def show
      @modification = Modification.find(params[:id])
      reg = @modification.registration

      unless reg
        flash_alert 'There is no registration attached to that modification!'
        redirect_to(admin_dashboard_path) and return
      end

      @user_name = reg.user.full_name

      if @modification.pending?
        @modified_registration = modify('preview', reg)
        @current_registration = reg.reload
      else
        @current_registration = reg
      end
    end

    def apply
      @modification = Modification.find(params[:id])
      @registration = Event::Registration.find_by(id: params[:registration_id])
      reg = @registration
      unless @modification.applied?
        reg = modify('apply', @registration)
      end
      @registration = reg
      unless @modification.applied? || @registration.save
        flash_alert "Update error: #{@registration.errors.full_messages}"
        redirect_to event_modification_path(@modification, registration_id: reg.id) and return
      end

      @modification.status = :applied
      @modification.save

      unless @modification
        flash_alert "FAILURE | no modification"
        return
      end

      email = @registration.user.email

      payment_link = create_payment_link(
        email: @registration.user.email,
        registration_id: @registration.id,
        modification_id: @modification.id
      )
      redirect_to admin_dashboard_path
    end

    def send_payment_link
      create_payment_link(params)
      redirect_to admin_dashboard_path
    end


    def create_payment_link(params)
      email = params[:email]
      reg_id = params[:registration_id]
      mod_id = params[:modification_id]
      reg = Event::Registration.find_by(id: reg_id)
      mod = Event::Modification.find_by(id: mod_id)

      unless reg && mod
          Rails.logger.error("Missing reg or mod")
          return
        end

      square_params = {
        ticket_name: "Update - 2026 Citroen Rendezvous Registration",
        modification: mod,
        reference_id: reg_id,
        fee_period: reg.late_period? ? :late : :early,
        email: email
      }

      begin
        payment_link = ::RendezvousSquare::Apis::Checkout
            .create_square_modification_payment_link(square_params)

        RendezvousMailer.send_modification_payment_link(email, mod.id, payment_link).deliver_later
        payment_link
      rescue Square::Errors::ApiError => e
        Rails.logger.error("Square error: #{e.message}")
      rescue => e
        Rails.logger.error("Unexpected error: #{e.class} - #{e.message}")
      end
    end

    private

    def modify(action, registration)
      if action == 'preview'
        reg = registration.dup
      elsif action == 'apply'
        reg = registration
      else
        raise ArgumentError, "Unknown action: #{action}"
      end

      Event::Registration::AGE_GROUPS.each do |age|
        plural = age.pluralize
        number = "number_of_#{plural}"
        delta = "delta_#{plural}"
        reg.send("#{number}=",
          reg.send(number) + @modification.send(delta)
        )
      end

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
