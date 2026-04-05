module ModificationsHelper

  def new_total(field)
    @modification.send("starting_#{field}") + @modification.send("delta_#{field}")
  end

  def grand_total
    @registration.total + @modification.modification_total
  end
end
