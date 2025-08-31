class ContainersController < ApplicationController
  before_action :set_container, only: %i[edit update destroy]

  def index
    @containers = company_scope(Container).includes(:products)
  end

  def new
    @container = Container.new
  end

  def create
    @container = Container.new(container_params)
    @container.company = current_company
    if @container.save
      redirect_to containers_path, notice: '容器を作成しました。'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @container.update(container_params)
      redirect_to containers_path, notice: '容器を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    if @container.products.exists?
      redirect_to containers_path, alert: 'この容器は商品で使用されているため削除できません。'
    else
      @container.destroy
      redirect_to containers_path, notice: '容器を削除しました。'
    end
  end

  private

  def set_container
    @container = company_scope(Container).find(params[:id])
  end

  def container_params
    params.require(:container).permit(:name)
  end
end