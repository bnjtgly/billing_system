class ChargeItemsController < ApplicationController
  before_action :require_admin!
  before_action :set_charge_item, only: %i[ show edit update destroy ]
  before_action :load_categories, only: [:new, :create, :edit, :update]

  # GET /charge_items or /charge_items.json
  def index
    @charge_items = ChargeItem.all.sort_by(&:charge_category_id)
  end

  # GET /charge_items/1 or /charge_items/1.json
  def show
  end

  # GET /charge_items/new
  def new
    @charge_item = ChargeItem.new
  end

  # GET /charge_items/1/edit
  def edit
  end

  # POST /charge_items or /charge_items.json
  def create
    @charge_item = ChargeItem.new(charge_item_params)

    respond_to do |format|
      if @charge_item.save
        format.html { redirect_to @charge_item, notice: "Charge item was successfully created." }
        format.json { render :show, status: :created, location: @charge_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @charge_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /charge_items/1 or /charge_items/1.json
  def update
    respond_to do |format|
      if @charge_item.update(charge_item_params)
        format.html { redirect_to @charge_item, notice: "Charge item was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @charge_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @charge_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /charge_items/1 or /charge_items/1.json
  def destroy
    @charge_item.destroy!

    respond_to do |format|
      format.html { redirect_to charge_items_path, notice: "Charge item was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_charge_item
      @charge_item = ChargeItem.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def charge_item_params
      params.expect(charge_item: [ :name, :charge_category_id, :unit, :default_price_cents, :position, :active, :metadata, :inventory_item_id ])
    end

    def load_categories
      @categories = ChargeCategory.order(:position, :name)
    end
end
