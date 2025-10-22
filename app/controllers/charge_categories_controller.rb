class ChargeCategoriesController < ApplicationController
  before_action :set_charge_category, only: %i[ show edit update destroy ]

  # GET /charge_categories or /charge_categories.json
  def index
    @charge_categories = ChargeCategory.all.sort_by(&:position)
  end

  # GET /charge_categories/1 or /charge_categories/1.json
  def show
  end

  # GET /charge_categories/new
  def new
    @charge_category = ChargeCategory.new
  end

  # GET /charge_categories/1/edit
  def edit
  end

  # POST /charge_categories or /charge_categories.json
  def create
    @charge_category = ChargeCategory.new(charge_category_params)

    respond_to do |format|
      if @charge_category.save
        format.html { redirect_to @charge_category, notice: "Charge category was successfully created." }
        format.json { render :show, status: :created, location: @charge_category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @charge_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /charge_categories/1 or /charge_categories/1.json
  def update
    respond_to do |format|
      if @charge_category.update(charge_category_params)
        format.html { redirect_to @charge_category, notice: "Charge category was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @charge_category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @charge_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /charge_categories/1 or /charge_categories/1.json
  def destroy
    @charge_category.destroy!

    respond_to do |format|
      format.html { redirect_to charge_categories_path, notice: "Charge category was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_charge_category
      @charge_category = ChargeCategory.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def charge_category_params
      params.expect(charge_category: [ :name, :key, :position ])
    end
end
