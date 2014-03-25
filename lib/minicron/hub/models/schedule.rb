class Minicron::Hub::Schedule < ActiveRecord::Base
  belongs_to :job

  # Format the schedule based on all it's components
  def formatted
    # If it's not a 'special' schedule then build up the full schedule string
    if read_attribute(:special) == '' || read_attribute(:special) == nil
      "#{read_attribute(:minute)} #{read_attribute(:hour)} #{read_attribute(:day_of_the_month)} #{read_attribute(:month)} #{read_attribute(:day_of_the_week)}"
    else
      read_attribute(:special)
    end
  end
end
