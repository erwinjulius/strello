class CardsController < ApplicationController
  before_filter :logged_in_clearance

  def new
    if @board = Board.find_by_id(params[:board_id])
      @card = Card.new
      render :new
    else
      flash[:errors] = "Board not fonud"
      redirect_to user_url(current_user)
    end
  end

  def create
    unless @board = Board.find_by_id(params[:board_id])
      flash[:errors] = "Board not fonud"
      redirect_to user_url(current_user)
    else

      @card = Card.new(params[:card])
      @card.board_id = @board.id

      params[:checklist_items].reject! { |v| v.all? { |_, v2| v2 == "" } }
      params[:checklist_items].each do |item_params|
        @card.checklist_items.build(item_params)
      end

      params[:participants].each do |participant_params|
        @card.participations.build(participant_params)
      end

      p @card.participations
      if @card.save
        redirect_to board_url(@board)
      else
        flash[:errors] = @card.errors.full_messages
        render :new
      end
    end
  end

  def show
    if @card = Card.includes(:checklist_items, :board).find_by_id(params[:id])
      @board = @card.board
      render :show
    else
      flash[:errors] = "Card not found"
      redirect_to user_url(current_user)
    end
  end

  def edit
    if @card = Card.includes(:checklist_items, :board, :participants).find(params[:id])
      @board = @card.board
      render :edit
    end
  end

  def update
    @card = Card.includes(
      :participations,
      :board,
      :checklist_items,
      :participants
    ).find(params[:id])
    @board = @card.board

    begin
      ActiveRecord::Base.transaction do
        params[:checklist_items].reject! { |v| v.all? { |_, v2| v2 == "" } }

        @card.update_attributes(params[:card])

        @checklist_items = params[:checklist_items].map do |item_params|
          if (item_params[:id])
            @item = ChecklistItem.find_by_id(item_params[:id])

            item_params[:id] = ""
            if item_params.all? { |_, v2| v2 == "" }
              item.destroy
              next nil
            end

            @item.update_attributes(item_params)
            @item
          else
            ChecklistItem.new(item_params)
          end
        end.compact

        @checklist_items.each do |item|
          unless item.id
            item.card_id = @card.id
            item.save
          end
        end

        @card.participations.each { |q| p q.user_id }
        params[:participants].each do |p_params|
          p p_params[:user_id].to_i
          unless @card.participations.any? { |p| p.user_id == p_params[:user_id].to_i }
            @card.participations.build(p_params)
          end
        end
        p @card.participations
        @card.save
        # @card.participations.map! do |participation|
        #   unless param[:participants].any? { |p| p[:user_id] == participation.id }
        #     participation.destroy
        #     nil
        #   else
        #     participation
        #   end
        # end.compact

        raise "invalid" unless @checklist_items.length > 0
        raise "invalid" unless @card.valid? && @checklist_items.all? { |item| item.valid? }
        raise "invalid" unless @card.participations.all? { |p| p.valid? }
      end

    rescue
      flash[:errors]  = @card.errors.full_messages
      flash[:errors] += @checklist_items.map(&:errors).map(&:full_messages).flatten
      render :edit
    else
      redirect_to board_url(@card.board_id)
    end
  end

  def destroy
    if @card = Card.find_by_id(params[:id])
      @card.destroy
    else
      flash[:errors] = "Card not found"
    end
    redirect_to user_url(current_user)
  end
end
