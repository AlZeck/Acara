class Flag < ApplicationRecord

  #Controlli sulle chiavi esterne
  belongs_to :user
  belongs_to :flaggedComment, optional: true, class_name: "Flag"
  belongs_to :flaggedEvent, optional: true, class_name: "Flag"
  belongs_to :flaggedUser, optional: true, class_name: "Flag"


  #Controlla che la ragione sia tra quelle accettate (e conseguentemente che non sia vuota)
  validates :reason, :inclusion => {:in => ["Dangerous Activity & Self Injury", "Harassment & Trolling", "Nudity & Pornography", "Bullying", "Misleading Event/User", "Spam", "Other...", "Verification"]}


  #Controlla che il flag sia relativo ad una sola cosa (uno solo non nil)
  def flaggedContent
    if !(
      !flaggedComment_id.nil? && flaggedEvent_id.nil? && flaggedUser_id.nil? ||
      flaggedComment_id.nil? && !flaggedEvent_id.nil? && flaggedUser_id.nil? ||
      flaggedComment_id.nil? && flaggedEvent_id.nil? && !flaggedUser_id.nil?
    )
      errors.add(:id, "Flag covers more/less than it should")
    end
  end
  validate :flaggedContent


  #variabile indicante la lista di ragioni selezionabili in un flag
  def reasons
    return ["Dangerous Activity & Self Injury", "Harassment & Trolling", "Nudity & Pornography", "Bullying", "Misleading Event/User", "Spam", "Other..."]
  end

end
