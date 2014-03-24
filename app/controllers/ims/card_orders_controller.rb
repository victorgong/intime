class Ims::CardOrdersController < Ims::BaseController

  def index
    # API_NEED: 获取礼品卡订单的列表
  end

  def create
    # API_NEED: 创建购买礼品卡的订单
    params[:type]
    params[:num]
    pay
  end

  def show
    # API_NEED: 获取某张礼品卡订单的详情
    @price = 500
    @code = 'AF135GBGQS'
  end

  def paid

  end
private
  def pay
    @out_trade_no = 'AF135GBGQS' #订单号
    @transport_fee = 23.00 #运费
    @product_fee = 100.00 #售价
    @total_fee = 123.00 #合计
    @timestamp_val = Time.now.to_i #时间戳
    @noncestr_val = (1..9).map{ ('a'..'z').to_a.sample }.join('') #随机码
    @notify_url = 'http://freebird.ngrok.com/ims/card_orders/paid'
    # API_NEED: 对礼品卡付款之后，接收微信付款支付结果
    # 成功后进行订单状态修改等操作
    @package_val = {
    	# bank: "WX",	body: "商品描述",	partner: Setting.wx.partner_id,	out_trade_no: ,	total_fee: ,	fee_type: 1, 	notify_url: @notify_url,	spbill_create_ip: request.remote_ip,	time_start: Time.now.strftime('%Y%m%d%H%m%S'),	time_expire: 1.hours.from_now.strftime('%Y%m%d%H%m%S'),	transport_fee: ,	product_fee: ,	input_charset: 'UTF-8'
    }.to_param
    @paySign_val = Digest::SHA1.hexdigest({appid: Settings.wx.appid, timestamp: @timestamp_val, noncestr: @noncestr_val, package: @package_val, appkey: Settings.wx.appsecret}.to_params)
  end
end