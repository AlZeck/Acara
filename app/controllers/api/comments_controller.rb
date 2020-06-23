class Api::CommentsController < ApplicationController
   
	#POST su /api/events/:event_id/comments
	def create
		if user_signed_in?
		  event_id = params[:event_id]
		  if Event.exists?(event_id)
			# Check if event exists
			par = params[:comment].permit(:content, :previous_id)
	
			comment = Comment.new(content: par[:content], previous_id: par[:previous_id],
								  user_id: current_user.id, event_id: event_id)
	
			if comment.valid?
			  if comment.save
				#success
				render status: 200
			  else
				render status: 500
			  end
			else
			  render status: 400
			end
		  else
			render status: 404
		  end
		else
		  render status: 401
		end
	  end
	
	  #PATCH/PUT su /api/events/:event_id/comments/:id
	  def update
		if user_signed_in?
		  event_id = params[:event_id].to_i
		  comment = Comment.where(id: params[:id])[0]
	
		  if !comment.nil? && comment.event_id == event_id
			# check if the comment exist inside the event
			# a comment can only exists if the event that contains it exists
			if current_user.id == comment.user_id || current_user.admin
			  # check if the user is autorized to change the comment
			  content = params[:comment].permit(:content)[:content]
			  comment.assign_attributes(content: content)
			  if comment.valid?
				#check the validity of the comments
				if comment.save
				  #success
				  render status: 200
				else
				  render status: 500
				end
			  else
				render status: 400
			  end
			else
			  render status: 403
			end
		  else
			render status: 404
		  end
		else
		  render status: 401
		end
	  end
	
	  #DELETE su /api/events/:event_id/comments/:id
	  def destroy
		if user_signed_in?
		  event_id = params[:event_id].to_i
		  comment = Comment.where(id: params[:id])[0]
	
		  if !comment.nil? && comment.event_id == event_id
			# check if the comment exist inside the event
			# a comment can only exists if the event that contains it exists
			if current_user.id == comment.user_id || current_user.admin
			  # check if the user is autorized to change the comment
	
			  if comment.destroy
				#success
				render status: 200
			  else
				render status: 500
			  end
			else
			  render status: 403
			end
		  else
			render status: 404
		  end
		else
		  render status: 401
		end
	  end
	end
	