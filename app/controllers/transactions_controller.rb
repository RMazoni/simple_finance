require "ofx-parser"
class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show edit update destroy ]

  # GET /transactions or /lost+found/
  def index
    @months = (1..12).map { |m| [ Date::MONTHNAMES[m], m ] }
    @years = (Transaction.minimum(:year) || Date.today.year)..Date.today.year

    @selected_month = params[:month].presence&.to_i || Date.today.month
    @selected_year = params[:year].presence&.to_i || Date.today.year

  @transactions = Transaction.where(month: @selected_month, year: @selected_year)
  end

  # GET /transactions/1 or /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, notice: "Transaction was successfully created." }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to @transaction, notice: "Transaction was successfully updated." }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy!

    respond_to do |format|
      format.html { head :no_content }  # Não redireciona nada no formato HTML
      format.json { head :no_content }
      format.turbo_stream {  # Responde com Turbo Stream para atualizar a visualização
        render turbo_stream: turbo_stream.remove(@transaction)
      }
    end
  end

  def import
    file = params[:file]
    return redirect_to transactions_path, alert: "Arquivo não enviado" unless file

    content = file.read.force_encoding("ISO-8859-1").encode("UTF-8", replace: "")
    ofx = OfxParser::OfxParser.parse(content)

    # Verifica se há uma conta bancária (BankAccount) ou de cartão de crédito (CreditAccount)
    account = ofx.bank_account || ofx.credit_card
    unless account
      return redirect_to transactions_path, alert: "Nenhuma conta encontrada no arquivo OFX"
    end

    # Pega os valores do formulário ou mantém os anteriores da sessão
    @selected_month = (params[:month] || session[:month] || Date.today.month).to_i
    @selected_year = (params[:year] || session[:year] || Date.today.year).to_i

    # Salva os filtros na sessão para que sejam mantidos na navegação
    session[:month] = @selected_month
    session[:year] = @selected_year

    @transactions = account.statement.transactions.map do |tx|
      {
        date: tx.date.strftime("%d/%m/%Y"),
        description: tx.memo,  # Alguns OFX usam `name` em vez de `memo`
        amount: tx.amount.to_f
      }
    end

    @categories = Category.all

    render :import
  end

  def save_import
    selected_month = params[:month].to_i
    selected_year = params[:year].to_i
    transactions = params[:transactions]
    params[:transactions].values.each do |tr|
      Transaction.create!(
        month: selected_month,
        year: selected_year,
        description: tr["description"],
        amount: tr["amount"].to_f,
        category_id: tr["category_id"]
      )
    end

    redirect_to transactions_path, notice: "Transações importadas com sucesso!"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.require(:transaction).permit(:description, :amount, :year, :month, :category_id).tap do |whitelisted|
      whitelisted[:year] = whitelisted[:year].to_i if whitelisted[:year].present?
      whitelisted[:month] = whitelisted[:month].to_i if whitelisted[:month].present?
    end
  end
end
