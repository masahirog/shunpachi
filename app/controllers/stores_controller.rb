class StoresController < ApplicationController
  before_action :set_store, only: %i[edit update destroy]

  def index
    @stores = Store.all
  end

  def new
    @store = Store.new
  end

  def create
    @store = Store.new(store_params)
    if @store.save
      redirect_to stores_path, notice: '店舗を作成しました。'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @store.update(store_params)
      redirect_to stores_path, notice: '店舗を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @store.destroy
    redirect_to stores_path, notice: '店舗を削除しました。'
  end

  private

  def set_store
    @store = Store.find(params[:id])
  end

  def store_params
    params.require(:store).permit(:name, :phone, :address, :unused_flag)
  end
end
