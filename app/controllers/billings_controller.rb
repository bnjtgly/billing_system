class BillingsController < ApplicationController
  before_action :set_billing, only: %i[show edit update destroy issue]

  def index
    @billings = Billing
                  .includes(:patient)
                  .joins(:patient)
                  .order(statement_date: :desc, created_at: :desc)

    if params[:q].present?
      q = "%#{params[:q].downcase}%"
      @billings = @billings.where(
        "LOWER(billings.statement_number) LIKE :q
       OR LOWER(patients.first_name) LIKE :q
       OR LOWER(patients.last_name) LIKE :q
       OR LOWER(CONCAT(patients.first_name, ' ', patients.last_name)) LIKE :q
       OR LOWER(CONCAT(patients.last_name, ' ', patients.first_name)) LIKE :q",
        q: q
      )
    end

    if params[:status].present?
      @billings = @billings.where(status: params[:status])
    end
  end

  def show
    @lines = @billing.billing_lines.order(:date, :id)
  end

  # Selection page (GET /billings/new?patient_id=...)
  def new
    @patients = Patient.order(:last_name, :first_name)
    @patient = Patient.find_by(id: params[:patient_id]) if params[:patient_id].present?
    @charge_checklists = @patient ? @patient.charge_checklists.order(performed_on: :desc) : []
    @billing = Billing.new(statement_date: Date.current, status: :draft)
  end

  def edit; end

  # Handles BOTH: (a) create-from-checklists, (b) plain create
  def create
    if params.dig(:billing, :checklist_ids).present?
      patient = Patient.find(params[:billing][:patient_id])
      checklist_ids = Array(params[:billing][:checklist_ids]).reject(&:blank?)
      checklists = patient.charge_checklists.where(id: checklist_ids).includes(line_items: [:charge_item])

      @billing = Billing.create!(
        patient: patient,
        statement_number: generate_statement_number,
        statement_date: Date.current,
        period_start: checklists.minimum(:performed_on),
        period_end: checklists.maximum(:performed_on),
        discount_cents: 0,
        status: :draft
      )
      @billing.populate_from_checklists!(checklists)
      redirect_to @billing, notice: "Billing created."
    else
      @billing = Billing.new(billing_params)
      if @billing.save
        @billing.recalc_totals!
        redirect_to @billing, notice: "Billing was successfully created."
      else
        # Re-hydrate selection lists if rendering new again
        @patients = Patient.order(:last_name, :first_name)
        @patient = Patient.find_by(id: params.dig(:billing, :patient_id))
        @charge_checklists = @patient ? @patient.charge_checklists.order(performed_on: :desc) : []
        render :new, status: :unprocessable_entity
      end
    end
  end

  def update
    if @billing.update(billing_params)
      @billing.recalc_totals!
      redirect_to @billing, notice: "Billing was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @billing.destroy!
    redirect_to billings_path, notice: "Billing was successfully destroyed.", status: :see_other
  end

  def issue
    @billing.update!(status: :issued, statement_date: Date.current)
    @billing.recalc_totals!
    redirect_to @billing, notice: "Billing marked as issued."
  end

  def new_from_checklists
    @patients = Patient.order(:last_name, :first_name)
    @patient = Patient.find_by(id: params[:patient_id]) if params[:patient_id].present?
    @charge_checklists = @patient ? @patient.charge_checklists.order(performed_on: :desc) : []
  end

  def create_from_checklists
    patient = Patient.find(params.require(:patient_id))
    selected_ids = Array(params[:checklist_ids]).reject(&:blank?)

    if selected_ids.empty?
      redirect_to new_from_checklists_billings_path(patient_id: patient.id), alert: "Please select at least one checklist." and return
    end

    checklists = patient
                   .charge_checklists
                   .where(id: selected_ids)
                   .includes(line_items: [:charge_item])

    billing = Billing.create!(
      patient: patient,
      statement_number: generate_statement_number,
      statement_date: Date.current,
      period_start: checklists.minimum(:performed_on),
      period_end: checklists.maximum(:performed_on),
      discount_cents: 0,
      status: :draft
    )

    billing.populate_from_checklists!(checklists)
    redirect_to billing_path(billing), notice: "Billing created."
  end

  private

  def set_billing
    @billing = Billing.includes(:patient, :billing_lines).find(params[:id])
  end

  def billing_params
    params.require(:billing).permit(
      :patient_id, :statement_number, :statement_date, :period_start, :period_end,
      :subtotal_cents, :discount_cents, :total_cents, :status, :notes, :metadata,
      billing_lines_attributes: [
        :id, :date, :category, :item_code, :name, :route, :frequency, :dosage, :unit,
        :quantity, :unit_price_cents, :amount_cents, :metadata,
        :charge_checklist_id, :charge_checklist_item_id, :_destroy
      ]
    )
  end

  def generate_statement_number
    loop do
      token = "BILL-#{SecureRandom.alphanumeric(8).upcase}"
      break token unless Billing.exists?(statement_number: token)
    end
  end
end