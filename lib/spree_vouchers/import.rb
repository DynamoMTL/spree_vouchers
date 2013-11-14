class SpreeVouchers::Import
  attr_reader   :count
  attr_accessor :name, :usage_limit, :description,
                :starts_at, :expires_at, :amount

  def initialize(params={})
    @params = params
    @name = params[:name]
    @usage_limit = params[:usage_limit] || 1
    @description = params[:description]
    @starts_at = params.key?(:starts_at) ? Date.parse(params[:starts_at]) : Date.today
    @expires_at = params.key?(:expires_at) ? Date.parse(params[:expires_at]) : 3.months.from_now
    @amount = params[:amount] || 0
    @io = params[:voucher_list]
    @count = 0
  end

  def save
    attributes = @params.slice(:name, :usage_limit, :description, :starts_at, :expires_at)
    attributes.merge!(event_name: 'spree.checkout.coupon_code_added')

    each_code do |code|
      promotion = Spree::Promotion.create(attributes.merge(code: code))
      action = Spree::Promotion::Actions::CreateAdjustment.new
      action.activator_id = promotion.id
      action.calculator = Spree::Calculator::FlatRate.new
      action.calculator.preferred_amount = @amount
      action.save
      @count += 1 if promotion.valid?
    end

    @count > 0
  end

private
  def each_code
    CSV(@io.read).each {|row| yield(row.first)}
  end
end
