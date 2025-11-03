class PatientsController < ApplicationController
  before_action :set_patient, only: %i[ show edit update destroy ]

  # Lightweight async lookup for combobox
  def lookup
    q = params[:q].to_s.strip
    if q.length < 2
      render json: [] and return
    end

    like = "%#{q.downcase}%"
    patients = Patient
                 .where("LOWER(first_name) LIKE :q OR LOWER(last_name) LIKE :q OR LOWER(CONCAT(last_name,' ',first_name)) LIKE :q", q: like)
                 .order(:last_name, :first_name)
                 .limit(20)

    render json: patients.map { |p|
      subtitle_parts = []
      subtitle_parts << p.gender.to_s.titleize if p.gender.present?
      if p.date_of_birth.present?
        dob = p.date_of_birth
        now = Date.current
        age = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
        subtitle_parts << "#{age} yrs"
      end
      { id: p.id, label: "#{p.last_name}, #{p.first_name}", subtitle: subtitle_parts.join(' • ') }
    }
  end

  # GET /patients or /patients.json
  def index
    @patients = Patient.all
  end

  # GET /patients/1 or /patients/1.json
  def show
    @billings = @patient.billings.order(statement_date: :desc, created_at: :desc).limit(5)
    @checklists = @patient.charge_checklists.order(performed_on: :desc, created_at: :desc).limit(5)
  end

  # GET /patients/new
  def new
    @patient = Patient.new
  end

  # GET /patients/1/edit
  def edit
  end

  # POST /patients or /patients.json
  def create
    @patient = Patient.new(patient_params)

    respond_to do |format|
      if @patient.save
        format.html { redirect_to @patient, notice: "Patient was successfully created." }
        format.json { render :show, status: :created, location: @patient }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /patients/1 or /patients/1.json
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_to @patient, notice: "Patient was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @patient }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/1 or /patients/1.json
  def destroy
    @patient.destroy!

    respond_to do |format|
      format.html { redirect_to patients_path, notice: "Patient was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_patient
      @patient = Patient.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def patient_params
      params.expect(patient: [ :first_name, :last_name, :date_of_birth, :gender, :email, :phone_number, :address, :city ])
    end
end
