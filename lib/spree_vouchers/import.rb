class SpreeVouchers::Import
  attr_reader   :count
  attr_accessor :name, :usage_limit, :description,
                :starts_at, :expires_at, :amount

  module VoucherFileParser
    extend self

    def each(io, &block)
      CSV(io.read).each {|row| yield(row.first)}
    end
  end

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
    VoucherFileParser.each(@io) do |code|
      @count += 1 if create_promo(attributes.merge(code: code))
    end

    @count > 0
  end

private
  def attributes
    @attributes ||= @params.slice(:name, :usage_limit, :description, :starts_at, :expires_at)
                           .merge(event_name: 'spree.checkout.coupon_code_added')
  end

  def create_promo(attributes)
    promotion = Spree::Promotion.create(attributes)
    create_action(promotion)

    promotion.valid?
  end

  def create_action(promotion)
    Spree::Promotion::Actions::CreateAdjustment.create({
      activator_id: promotion.id,
      calculator: Spree::Calculator::FlatRate.new(preferred_amount: @amount)}, without_protection: true)
  end
end
