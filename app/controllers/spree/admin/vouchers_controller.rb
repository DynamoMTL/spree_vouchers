module Spree
  module Admin
    class VouchersController < Spree::Admin::BaseController
      def new
        @voucher = SpreeVouchers::Import.new
      end

      def create
        @voucher = SpreeVouchers::Import.new(params[:voucher])
        if @voucher.save
          redirect_to(spree.admin_promotions_path, notice: t(:vouchers_created, count: @voucher.count))
        else
          render 'new'
        end
      end
    end
  end
end
