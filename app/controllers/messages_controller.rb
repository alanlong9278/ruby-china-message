class MessagesController < ApplicationController
  before_filter :require_user
  def index
    @sender = false
    @tab = params[:tab].nil? ? '0' : params[:tab]
    # 区分是其他用户发的站内信还是系统站内信
    case @tab
      when '0'
        @messages = current_user.received_messages.where(is_byadmin: 0)
      when '1'

        @messages = current_user.received_messages.where(is_byadmin: 1)
    end
    @messages = @messages.paginate page: params[:page], per_page: 20 unless @messages.nil?
  end

  def sender
    @sender = true
    @messages = current_user.send_messages
    @messages = @messages.recent.paginate page: params[:page], per_page: 20 unless @messages.nil?
  end
  def show
    @message = MessageStatus.find(params[:id])
    @message.isread = true
    @message.save
  end

  # 删除一封站内信
  def destroy
    @message = MessageStatus.find(params[:id])
    sender = params[:sender] unless params[:sender].nil?
    delete_message @message, sender
    respond_to do |format|
      format.html { redirect_referrer_or_default user_messages_path }
      format.js { render layout: false }
    end
  end

  # 清空所有邮件
  # 根据传入的params[:sender, :tab] 确定是发件箱，私信还是系统信件
  def clear
    sender = params[:sender] unless params[:sender].nil?
    tab = params[:tab] unless params[:tab].nil?
    if sender == 'true'
      messages = current_user.send_messages
    else
      if tab == '0'
        messages = current_user.received_messages.where(is_byadmin: 0)
      else
        messages = current_user.received_messages.where(is_byadmin: 1)
      end

    end
    messages.each do |message|
      delete_message message, sender
    end
    respond_to do |format|
      format.html { redirect_referrer_or_default user_messages_path }
      format.js { render layout: false }
    end
  end
  def create

    @message = Message.new(message_params)
    @message.body = params[:body] unless params[:body].nil?
    identity = params[:identity] unless params[:identity].nil?
    if identity == '1'
      @message.to = params[:to] unless params[:to].nil?
    else
      @message.to = User.all.map { |user| user.login}.join(';')
    end

    @message.author_id = current_user.id

    if @message.save
      flash[:notice] = "发送成功"
      redirect_to action: :index,tab: 0
    else
      render_404
    end

  end

  def new
    @message = Message.new
    @message.to = User.find(params[:recieved_id]).login unless params[:recieved_id].nil?
  end

  private
  def message_params
    params.require(:message).permit(:body, :to)
  end

  # 删除站内信的方案
  # 当收发双方都删除时，才真正删除记录
  # 不然只修改对应的收件人或发件人的id,设为0
  def delete_message message, sender
    if sender == 'false'
      if message.sender_id == 0
        message.destroy
      else
        message.recipenter_id = 0
        message.save
      end
    else
      if message.recipenter_id == 0
        message.destroy
      else
        message.sender_id = 0
        message.save
      end
    end
  end

end
