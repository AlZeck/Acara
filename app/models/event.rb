class Event < ApplicationRecord

  #Controlli sulle chiavi esterne
  belongs_to :user


  #Controlla che i seguenti campi non siano vuoti
  validates :where, presence: true
  validates :cords, presence: true
  validates :start, presence: true
  validates :end, presence: true
  validates :title, presence: true
  validates :description, presence: true


  #Immagine di Copertina
  has_one_attached :cover


  # TODO si potrebbe rimuovere il \s* dopo la virgola per evitare di avere spazi, evitandoci così di fare la strip ogni volta
  #Controlla che le coordinate siano effettivamente valide
  validates_format_of :cords, with: /^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/, :multiline => true


  #Controlla che l'evento non finisca prima di cominciare
  def startBeforeEnd
    if start.to_datetime > self.end.to_datetime
      errors.add(:start, "Event ends before it starts")
    end
  end
  validate :startBeforeEnd


  # TODO Controlla che la stringa di where corrisponda alle coordinate date
  # def whereIsCords
  #   gc_cords = Geocoder.search(self.where)

  #   if gc_cords[0].data["error"].nil?
  #     loc = self.cords.split(",")
  #     loc[0] = loc[0].to_d
  #     loc[1] = loc[1].split[0].to_d
  
  #     for elem in gc_cords
  #       if (elem.coordinates[0] - loc[0]).abs <= 0.01 && (elem.coordinates[1] - loc[1]).abs <= 0.01
  #         return
  #       end
  #     end
  #     errors.add(:start, "Event coordinates do not match with the specified place")

  #   else
  #     errors.add(:start, "Event place do not match with any coordinates")
  #   end
  # end
  # validate :whereIsCords


  #variabile indicante quanti utenti partecipano al dato evento
  def going
    Participation.where(event: self, value: "p").length
  end


  #variabile indicante quanti utenti sono interessati al dato evento
  def interested 
    Participation.where(event: self, value: "i").length
  end


  #variabile indicante i nomi dei tag del dato evento
  def tags 
    ht = HasTag.where(event: self)

    arr = []
    for elem in ht
      arr << Tag.find(elem.tag_id).name
    end

    return arr
  end


  #variabile indicante i commenti del dato evento (in ordine dentro una mappa)
  def comments
    commNoReply = Comment.where(event: self, previous_id: nil).sort_by(&:created_at)

    comments = []
    for elem in commNoReply
      comments << { comment: elem, replies: Comment.where(event: self, previous_id: elem.id).sort_by(&:created_at) }
    end

    return comments
  end


  #variabile indicante separatamente le coordinate di un evento
  def coords
    { lat: self.cords.split(',')[0], lng: self.cords.split(',')[1].strip }
  end

  # Default Event Image
  after_commit :add_default_cover, on: %i[create update]

  def add_default_cover
    unless cover.attached?
      cover.attach(
        io: File.open(
          Rails.root.join(
            "app", "assets", "images", "default_cover.jpg"
          )
        ),
        filename: "default_cover.jpg",
        content_type: "image/jpg",
      )
    end
  end
end
