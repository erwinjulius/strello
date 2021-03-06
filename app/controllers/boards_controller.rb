class BoardsController < ApplicationController
  before_filter :logged_in_clearance, only: [:index, :new, :create]
  before_filter :member_clearance, only: [:show, :update]

  def index
    if !!params[:user_id]
      @user = User.find(params[:user_id])
    else
      @user = current_user
    end
    
    @boards = Board.includes(:members).select { |board| board.members.include?(@user) }
    render :index
  end

  def new
    @board = Board.new
    render :new
  end

  def create
    @board = current_user.created_boards.build(params[:board])
    if @board.save
      Membership.create(user_id: current_user.id, board_id: @board.id, admin: true)
      Catagory.create(board_id: @board.id, title: "To Do", sort_idx: 0)
      Catagory.create(board_id: @board.id, title: "Doing", sort_idx: 1)
      Catagory.create(board_id: @board.id, title: "Done", sort_idx: 2)
      redirect_to board_url(@board)
    else
      redirect_to root_url
    end
  end

  def show
    @board = Board.includes(:members, catagories: :cards).find(params[:id])
    render :show
  end
  
  def update
    @board = Board.find(params[:id])
    @board.update_attributes(params[:board])
    if request.xhr?
      render json: @board
    else
      redirect_to board_url(@board)
    end
  end
end
