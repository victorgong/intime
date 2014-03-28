class Ims::CardsController < Ims::BaseController
  before_filter :validate_sms!, only: [:give_page, :refuse]
  layout "ims/user"

  # 充值历史
  def index

  end

  # 给自己充值
  def recharge
    if current_user.isbindcard
      # API_NEED: 充值礼品卡接口
      @data = Ims::Giftcard.recharge(request, charge_no: params[:charge_no])
      # 置空欲充值卡号
      current_user.will_charge_no = nil
    else
      # 如果未绑定，则跳至绑卡页面
      current_user.will_charge_no = params[:charge_no]
      current_user.will_charge_type = params[:charge_type]
      redirect_to new_ims_account_path
    end
  end

  # 获赠礼品卡
  def gift_page
    # API_NEED: 根据礼品卡号，获取礼品卡相关信息
    @result = {}
  end

  # 赠送给别人
  def give
    # API_NEED: 赠送礼品卡接口
    @result = Ims::Giftcard.send(request, charge_no: params[:charge_no], comment: params[:comment], phone: params[:phone])
  end

  # 不接受，归还原有用户
  def refuse
    # API_NEED: 拒收并退回礼品卡
    Ims::Giftcard.refuse(request, charge_no: params[:charge_no])
  end

end