class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  # message 对应字段
  field :author_id, type: Integer, default: 0
  field :body
  field :to


  # 表单之间从属关系
  belongs_to :author, class_name: 'User'
  has_many :message_statuses, class_name: 'MessageStatus'

  validates_presence_of :body, :to

  after_save :add_message_status

  # 往MessageStatus 中插入数据
  def add_message_status
    return if to.blank?
    is_byadmin = User.find(author_id).admin? ? 1 : 0
    to.split(';').each do |recipent|
      reciever = User.where(login: recipent).first

      MessageStatus.create(is_byadmin: is_byadmin, recipenter_id: reciever.id, sender_id: author_id, message_id: self.id)
    end
  end

end
