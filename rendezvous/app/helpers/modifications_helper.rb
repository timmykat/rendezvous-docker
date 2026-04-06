module ModificationsHelper

  def active_modification(reg)
    reg.modifications.where(status: :pending).first
  end

  def modification_title(mod, name)
    if mod.applied?
      state = 'Applied'
    else
      state = 'Pending'
    end
    "#{state} modification for #{name}"
  end
end
