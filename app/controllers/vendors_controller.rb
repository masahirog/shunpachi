class VendorsController < ApplicationController
  before_action :set_vendor, only: %i[edit update destroy]

  def index
    @vendors = company_scope(Vendor.all)
  end

  def new
    @vendor = Vendor.new
  end

  def create
    @vendor = Vendor.new(vendor_params)
    @vendor.company = current_company
    if @vendor.save
      redirect_to vendors_path, notice: '仕入れ業者を作成しました。'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @vendor.update(vendor_params)
      redirect_to vendors_path, notice: '仕入れ業者を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @vendor.destroy
    redirect_to vendors_path, notice: '仕入れ業者を削除しました。'
  end

  private

  def set_vendor
    @vendor = company_scope(Vendor).find(params[:id])
  end

  def vendor_params
    params.require(:vendor).permit(:name, :phone, :fax, :mail, :address, :trading_person_name, :trading_person_phone, :trading_person_mail, :memo, :unused_flag)
  end
end
