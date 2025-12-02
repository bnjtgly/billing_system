class ChargeChecklistsController < ApplicationController
  before_action :require_admin!, except: %i[index new show edit update]
  before_action :set_charge_checklist, only: %i[ show edit update destroy ]

  # GET /charge_checklists or /charge_checklists.json
  def index
    @charge_checklists = ChargeChecklist
                           .includes(:patient)
                           .joins(:patient)
                           .order(created_at: :desc)

    if params[:q].present?
      q = "%#{params[:q].downcase.strip}%"
      @charge_checklists = @charge_checklists.where(
        "LOWER(patients.first_name) LIKE :q
       OR LOWER(patients.last_name) LIKE :q
       OR LOWER(CONCAT(patients.first_name, ' ', patients.last_name)) LIKE :q
       OR LOWER(CONCAT(patients.last_name, ' ', patients.first_name)) LIKE :q",
        q: q
      )
    end
  end

  # GET /charge_checklists/1 or /charge_checklists/1.json
  def show
  end

  # GET /charge_checklists/new
  def new
    @charge_checklist = ChargeChecklist.new
    preload_catalog_and_build_lines
  end

  # GET /charge_checklists/1/edit
  def edit
    @charge_checklist = ChargeChecklist.find(params[:id])
    preload_catalog_and_build_lines
  end

  # POST /charge_checklists or /charge_checklists.json
  def create
    @charge_checklist = ChargeChecklist.new(charge_checklist_params)
    @charge_checklist.user_id ||= Current.user&.id

    if @charge_checklist.save
      respond_to do |format|
        format.html { redirect_to @charge_checklist, notice: "Charge checklist was successfully created." }
        format.json { render :show, status: :created, location: @charge_checklist }
      end
    else
      preload_catalog_and_build_lines
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @charge_checklist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /charge_checklists/1 or /charge_checklists/1.json
  def update
    if @charge_checklist.update(charge_checklist_params)
      respond_to do |format|
        format.html { redirect_to @charge_checklist, notice: "Charge checklist was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @charge_checklist }
      end
    else
      preload_catalog_and_build_lines
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @charge_checklist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /charge_checklists/1 or /charge_checklists/1.json
  def destroy
    @charge_checklist.destroy!

    respond_to do |format|
      format.html { redirect_to charge_checklists_path, notice: "Charge checklist was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_charge_checklist
      @charge_checklist = ChargeChecklist.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def charge_checklist_params
      params.require(:charge_checklist).permit(
        :patient_id, :performed_on, :notes,
        metadata: {},
        line_items_attributes: [:id, :charge_item_id, :medicine_id, :quantity, :unit_price_cents, :metadata, :_destroy]
      )
    end

    def preload_catalog_and_build_lines
      @categories = ChargeCategory.includes(:charge_items).order(:position)

      existing_ids = @charge_checklist.line_items.map(&:charge_item_id)
      ChargeItem.active.ordered.find_each do |item|
        next if existing_ids.include?(item.id)
        @charge_checklist.line_items.build(charge_item: item, quantity: 0, unit_price_cents: item.default_price_cents)
      end

      # Medicines data for select (only the essentials)
      @medicines = Medicine.active.order(:drug_name).select(:id, :item_code, :drug_name, :unit_price_cents, :form, :strength, :unit)

      # A single container ChargeItem for medicine rows we add dynamically
      med_cat = ChargeCategory.find_or_create_by!(name: "Medicines") { |c| c.position = (@categories.maximum(:position) || 0) + 1 }
      @medicine_charge_item_id =
        ChargeItem.find_or_create_by!(charge_category: med_cat, name: "Medicine (custom)") do |ci|
          ci.unit = "unit"
          ci.default_price_cents = 0
          ci.position = (med_cat.charge_items.maximum(:position) || 0) + 1
          ci.active = true
        end.id
    end
end
