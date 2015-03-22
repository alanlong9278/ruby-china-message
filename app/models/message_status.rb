class MessageStatus
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel


  field :sender_id, type: Integer, default: 0
  field :recipenter_id, type: Integer, default: 0
  field :isread, type: Mongoid::Boolean, default: false
  field :is_byadmin, type: Integer, default: 0
  field :message_id, type: Integer


  belongs_to :sender, class_name: 'User', inverse_of: :send_messages
  belongs_to :recipenter, class_name: 'User', inverse_of: :received_messages
  belongs_to :message

  delegate :author, :created_at, :body, to: :message


  before_destroy :delete_message
  # 如果站内信的收件人和发件人都删除这封信，则在delete message_status的记录之前将message的记录也删除
  def delete_message
    if MessageStatus.where(message_id: self.message_id).count == 1
      self.message.destroy
    end
  end

  # 找出没被阅读的站内信
  def self.unread user
    where(isread: false, recipenter_id: user.id)
  end
end
