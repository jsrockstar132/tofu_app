class CommentsController < ApplicationController

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end


  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(params[:comment])

    @comment.id = Time.now.to_i

    recipient_ids = @comment.recipient_ids.split(",")

    respond_to do |format|
        format.json { render json: @comment, status: :created, location: @comment }

      # Constants
      if Rails.env == "development"
        realtime_server_pub_url = "http://lh:3001/publish"
      else
        realtime_server_pub_url = "http://tofuapp.cloudno.de/publish"
      end

      EM.run do
        http = EM::HttpRequest.new(realtime_server_pub_url).post :body => {"recipient_ids" => recipient_ids, "message" => @comment.to_json}
        http.callback {
          EM.stop
        }
        http.errback {
          EM.stop
        }
      end

    end
  end


end
