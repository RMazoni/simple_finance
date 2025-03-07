class DashboardController < ApplicationController
  def index
    # Definir o ano e o mês a partir dos parâmetros ou usar os valores atuais
    @year = params[:year] || Date.today.year
    @month = params[:month].presence

    # Caso o mês esteja presente, aplica o filtro para ele
    if @month
      @total_income = Transaction.where(month: @month, year: @year).where("amount > 0").sum(:amount)
      @total_expense = Transaction.where(month: @month, year: @year).where("amount < 0").sum(:amount)
      @balance = @total_income + @total_expense
    else
      # Caso contrário, mostra o total para o ano todo
      @total_income = Transaction.where(year: @year).where("amount > 0").sum(:amount)
      @total_expense = Transaction.where(year: @year).where("amount < 0").sum(:amount)
      @balance = @total_income + @total_expense
    end
  end
end
